#!/usr/bin/env node
// AtomicParsley "/Users/coolaj86/TODO2/coolaj86/Music/iTunes/iTunes Media/Music/Owl City/All Things Bright and Beautiful/12 How I Became the Sea.m4a" --textdata > ap-output.tags.txt
// AtomicParsley "/Users/coolaj86/TODO2/coolaj86/Music/iTunes/iTunes Media/Music/Owl City/All Things Bright and Beautiful/12 How I Became the Sea.m4a" --test > ap-output.atoms.txt
// AtomicParsley "/Users/coolaj86/TODO2/coolaj86/Music/iTunes/iTunes Media/Music/Owl City/All Things Bright and Beautiful/12 How I Became the Sea.m4a" --test | grep mdat
// /Atom mdat @ (\d+) of size: (\d+), ends @ (\d+)/

// TODO how are md5sums calculated in the C code? why are they different here?
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
      console.log('No Cover Art');
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

      console.log('cover art:', match[1], match[3]);
    });

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
      console.log(JSON.stringify({ error: { message: "Could not find mdat atom" } }));
      return;
    }

    // parseInt - nodejs issue #2554
    // +8 - AtomicParsley simply counts wrong
    start = parseInt(match[1], 10) + 16;
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

  function parseToJson(err, txt) {
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
      console.log(JSON.stringify(err));
      return;
    }

    result = {};
    lines = txt.split('\n');

    for (i = 0; i < lines.length; i += 1) {
      line = lines[i];
      match = line.match(/Atom\s*"(.*?)"\s*(\[.*?\]){0,1}\s*contains:\s*(.*)/);
      if (!match) {
        result[key] += '\n' + line;
        continue;
      }
      //console.log(match);
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

    console.log(JSON.stringify(result, null, '  '));
  }

  fs.open(fullpath, 'r', function (err, _fd) {
    if (err) {
      console.log(JSON.stringify(err));
      return;
    }

    fd = _fd;
  });
  exec('AtomicParsley \'' + fullpath + '\' --textdata', parseToJson);
  //exec('AtomicParsley \'' + fullpath + '\' --test', getMd5sum);
  //fs.readFile(fullpath, 'utf-8', parseToJson);
}());
