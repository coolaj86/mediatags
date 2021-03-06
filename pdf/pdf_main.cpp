/*
********************************************************************************
**
**   PDFTAGS.CPP: Extracts tags from a PDF file
**                and displays it in JSON format
**   AUTHOR:      smaniam@ymail.com
**   LICENSE:     GNU GPL version 3
**
**
********************************************************************************
*/
#include <stdio.h>
#include <iostream>
#include <string>
#include <getopt.h>

#include "pdf_jdefs.h"
#include "pdftagjson.h"


using std::string;
using std::cout;
using std::cerr;
using std::endl;

/*
** SOME USEFUL STUFF FOR THE PROGRAM TO FUNCTION
*/


#define USAGE "Usage:\n\tpdftags [--literal [ --with-md5sum ] [ --with-sha1sum ]] [ --verbose ] [[ --with-md5sum ] [ --with-sha1sum ]] <pdf-file>\n\n"
//#define USAGE "Usage:\n\timgtags --literal=[e|x|i] <img-media-file>\n\n"

class PdfTagsCfg 
{
public:
    int            mode;
    bool           md5sum;
    bool           sha1sum;
    PdfTagsCfg() {
        mode           = PDF_MODE_INVALID;
        md5sum         = false;
        sha1sum        = false;
    }
    ~PdfTagsCfg() {}
    int getMode()  { return mode; }
    bool getMD5()  { return md5sum; }
    bool getSHA1() { return sha1sum; }
    bool getLit() { return ((mode & PDF_MODE_LITERAL) != 0); };
    bool getVer() { return ((mode & PDF_MODE_VERBOSE) != 0); };
};


/*
********************************************************************************
**
**
**     Main Function:
**          Parses Command line Arguments and Displays requested Tag Information
**
**
********************************************************************************
*/

int
main (int argc, char **argv)
{
    int                  c;
    char *pdffile =      NULL;
    PdfTagsCfg           cfg;


    while (1)
    {
        static struct option long_options[] =
        {
            {"literal",        no_argument,       0, 'l'},
            {"verbose",        no_argument,       0, 'v'},
            {"with-md5sum",    no_argument,       0, 'm'},
            {"with-sha1sum",   no_argument,       0, 's'},
            {"output",         required_argument, 0, 'o'},
            {"help",           no_argument,       0, 'h'},
            {"test",           no_argument,       0, 't'},
            {0, 0, 0, 0}
        };
        /* getopt_long stores the option index. */
        int option_index = 0;

        c = getopt_long (argc, argv, ":o:lvhtms",
               long_options, &option_index);

        /* Detect the end of the options. */
        if (c == -1)
            break;

        switch (c)
        {
            case 0:
                /* Is mode set ? */
                if (long_options[option_index].flag != 0)
                    break;
                printf ("option %s", long_options[option_index].name);
                if (optarg)
                    printf (" with arg %s", optarg);
                printf ("\n");
                break;

            case 'l':
                cfg.mode |= PDF_MODE_LITERAL;
                break;

            case 'v':
                cfg.mode |= PDF_MODE_VERBOSE;
                break;

            case 't':
                cfg.mode |= PDF_MODE_TESTING;
                break;

            case 'm':
                cfg.md5sum  = true;
                break;

            case 's':
                cfg.sha1sum = true;
                break;

            case 'o':
                printf ("option -o with value `%s'\n", optarg);
                printf ("Not Yet Supported.....\n");
                return 20;

            case 'h':
                printf ("\n%s", USAGE);
                return 0;

            case '?':
                /* getopt_long already printed an error message. */
                return 20;

            default:
                fprintf (stderr, "Invalid Option\n%s\n", USAGE);
                return 30;
        }
    }

    if ((((cfg.getMode() & PDF_MODE_LITERAL) != 0) &&
        ((cfg.getMode() & PDF_MODE_VERBOSE) != 0)) ||
        (((!cfg.getLit()) && (!cfg.getVer())) &&
        ((!cfg.getMD5()) && (!cfg.getSHA1()))))
    {
        fprintf(stderr, "%s: select either --verbose or --literal\n", argv[0]);
        fprintf(stderr, "\t or select --with-md5sum and/or --with-sha1sum\n");
        fprintf(stderr, "%s\n", USAGE);
        return 2;
    }
    if ((cfg.getMode() == PDF_MODE_VERBOSE) && (cfg.getMD5() || cfg.getSHA1()))
    {
        fprintf(stderr, "%s: checksum not supported in --verbose mode\n",
            argv[0]);
        fprintf(stderr, "%s\n", USAGE);
        return 3;
    }

    /* Grab File names*/
    if (optind < argc)
    {
        /*  For Later Use only one for now
        while (optind < argc)
        {
            printf ("%s ", argv[optind++]);
        }
        */
        pdffile = argv[optind];
    }
    else
    {
        fprintf(stderr, "No Files specified\n%s", USAGE);
        return 1;
    }


    PdfTagJson tags(pdffile);
    tags.setMD5(cfg.getMD5());
    tags.setSHA1(cfg.getSHA1());

    if (cfg.getLit()) return tags.literal();
    else if (cfg.getMode() == PDF_MODE_VERBOSE) return tags.verbose();
    else if (cfg.getMD5() || cfg.getSHA1()) return tags.checksum();

    return 4;
}
