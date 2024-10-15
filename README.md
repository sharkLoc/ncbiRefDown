# ncbiRefDown
perl script for download genome file from NCBI ftp site

```bash
perl ncbiRefDown.pl

USAGE: ncbiRefDown.pl [OPTIONS]

OPTIONS:
    -i, --input   <String>    Set accession id, can't use with option --list
    -l, --list    <String>    Accession id list file, one id per line and no blankline, can't use with option --input
    -a, --all     <Flag>      If specified, download all files
    -o, --outdir  <String>    Set output dir, default: [/home/demo/work/microNGS]
    -h, --help    <Flag>      Show this help
    -v, --version <Flag>      Show version
```
