#!/usr/bin/env node
// AtomicParsley "12-how-i-became-the-sea.m4a" --textdata > ap-output.tags.txt
// AtomicParsley "12-how-i-became-the-sea.m4a" --test > ap-output.atoms.txt
// AtomicParsley "12-how-i-became-the-sea.m4a" --test | grep mdat

// TODO how are md5sums calculated in the C code? why are they different here?

// arguments to maybe support in the future:
// --with-md5sum
// --with-sha1sum
// --hash=[md5sum,sha1sum,sha224,sha256,sha384,sha512]
// --extract-art
// --extract-art-to=
// --verbose
// --literal
// --help
(function () {
  "use strict";

  var fs = require('fs')
    , exec = require('child_process').exec
    , crypto = require('crypto')
    , fullpath = process.argv[2]
    , mdatRegExp = /Atom mdat @ (\d+) of size: (\d+), ends @ (\d+)/
    , covrRegExp = /Atom covr @ \d+ of size: \d+, ends @ \d+\n\s*(Atom data @ \d+ of size: \d+, ends @ \d+\n*\s*)+/
    , covrDataRegExp = /Atom data @ (\d+) of size: (\d+), ends @ (\d+)/
    , fd
    ;

  function getArt(err, stdout, stderr) {
    var match
      , lines
      , art = []
      ;

    if (err) {
      console.log(JSON.stringify(err));
      return;
    }

    match = stdout.match(covrRegExp);

    if (!match) {
      console.log(JSON.stringify(new Error('No Cover Art')));
      return;
    }

    lines = match[0].split('\n');
    // lose the covr atom
    lines.shift();
    lines.forEach(function (line) {
      match = line.match(covrDataRegExp);
      if (!match) {
        return;
      }

      art.push({
          // TODO figure out if this is a constant 16 bytes off, 
          // or variable based on the embedded image type
          start: parseInt(match[1], 10) + 16
          // the last two bytes of the tested jpeg are ff d9
          // suggesting that the end is exactly correct
        , end: parseInt(match[3], 10)
      });
    });

    // TODO hex hash
    art.forEach(function (a) {
      fs.read(fd, new Buffer(a.end - a.start), 0, a.end - a.start, a.start, function (err, len, buf) {
        fs.writeFileSync('something.jpg', buf, 'binary');
      });
    });
  }

  function getMd5sum(err, stdout, stderr) {
    var match = stdout.match(mdatRegExp)
      , start
      , size
      , end
      , hash = crypto.createHash('md5')
      , rstream
      ;

    if (err) {
      console.log(JSON.stringify(err));
      return;
    }
    getArt(err, stdout, stderr);

    if (!match) {
      console.log(JSON.stringify(new Error("Could not find mdat atom")));
      return;
    }

    // parseInt - nodejs issue #2554
    // +8 - AtomicParsley simply counts wrong
    start = parseInt(match[1], 10) + 5;
    size = parseInt(match[2], 10);
    end = start + size - 16; //parseInt(match[3], 10);

    rstream = fs.createReadStream(fullpath, { encoding: 'binary', start: start, end: end });
    rstream.on('error', function (err) {
      console.log(JSON.stringify(err));
    });
    rstream.on('data', function (chunk) {
      //console.log('chunk:', chunk.slice(0, 16));
      hash.update(chunk);
    });
    rstream.on('end', function () {
      console.log(hash.digest('hex'));
    });
  }

  function parseToJson(err, stdout, stderr) {
    var lines
      , line
      , match
      , i
      , result
      , key
      , key2
      , val
      ;

    if (err) {
      err.file = fullpath;
      err.stderr = stderr;
      console.log(JSON.stringify(err));
      //console.error(fullpath);
      //console.error(stderr);
      return;
    }

    result = {};
    lines = stdout.split('\n');

    for (i = 0; i < lines.length; i += 1) {
      line = lines[i];
      match = line.match(/Atom\s*"(.*?)"\s*(\[.*?\]){0,1}\s*contains:\s*(.*)/);

      if (!match) {
        result[key] += '\n' + line;
        continue;
      }

      key = match[1];
      key2 = match[2];
      val = match[3];
      if (key2) {
        //key = key + ' ' + key2;
        key = key + key2.replace('com.apple.iTunes;', '');
      }

      result[key] = val;
    }

    if (result.covr) {
      result.covr = true;
    }

    console.log(JSON.stringify(result));
  }

  fs.open(fullpath, 'r', function (err, _fd) {
    if (err) {
      console.log(JSON.stringify(err));
      return;
    }

    fd = _fd;
  });

  // can't escape a single quoted string -- must break out, then escape, then go back in
  exec('AtomicParsley \'' + fullpath.replace(/'/g, "'\\''") + '\' --textdata', parseToJson);
  //exec('AtomicParsley \'' + fullpath + '\' --test', getMd5sum);
  //fs.readFile(fullpath, 'utf-8', parseToJson);
}());
