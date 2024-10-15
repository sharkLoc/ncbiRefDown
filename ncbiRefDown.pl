#!/usr/bin/env perl

use strict;
use warnings;
use Cwd qw/getcwd/;
use Getopt::Long;
use Net::FTP;
use feature 'say';

my @argv = @ARGV;
my $version = "0.1.0";
my $outdir ||= getcwd();
my ($input,$list,$all,$help,$ver);

my $HOST = "ftp.ncbi.nlm.nih.gov";
&usage() unless  GetOptions(
        "i|input=s" =>\$input,
        "l|list=s" => \$list,
        "a|all" => \$all,
        "o|outdir=s" =>\$outdir,
        "h|help" => \$help,
        "v|version" => \$ver,
);


sub usage{
        say <<USAGE;

USAGE: $0 [OPTIONS]

OPTIONS:
    -i, --input   <String>    Set accession id, can't use with option --list
    -l, --list    <String>    Accession id list file, one id per line and no blankline, can't use with option --input
    -a, --all     <Flag>      If specified, download all files
    -o, --outdir  <String>    Set output dir, default: [$outdir]
    -h, --help    <Flag>      Show this help
    -v, --version <Flag>      Show version
USAGE
        exit -1;
}


&usage() if $help || @argv == 0;
say "Version: $version"  if defined $ver;
die "Error: option --input can't use with option --list\n" if $input && $list;
say "Info: the output directory:[$outdir] does not exist, building...\n" unless -e $outdir;

unless(-e $outdir){
        mkdir $outdir;
}


my $ftp = Net::FTP->new($HOST);
$ftp->login() or die "Cannot login \n", $ftp->message;

if($input){
        chdir $outdir;
        &download($input, $all);
}

if($list){
        open F,"$list" || die "can't open file $list";
        chdir $outdir;
        while(<F>){
                chomp;
                next if /^\s*$/;
                &download($_, $all);
        }
        close F;
}


sub download {
        my $input = shift;
        my $all = shift;
        my $url = &get_url($input);

        my @acc_dirs = $ftp->ls($url);
        my $last_version = $acc_dirs[-1];
        my $pre = (split /_/,$last_version)[-1];
        say $pre;
        my $fna = $pre."_genomic.fna.gz";
        my $gff = $pre."_genomic.gff.gz";

        my @all = $ftp->ls($last_version);
        my @select = $all ? @all : grep {$_ =~/($fna|$gff)$/ } @all;
        foreach my $k(@select){
                say "downloading ... $k";
                $ftp->get($k) or die "get failed", $ftp->message;
        }

        $ftp->quit;
}


sub get_url {
        my $name = shift;
        my ($gcty, $gcid) = (split /_/,$name)[0,1];
        my ($id, $subid) = (split /\./,$gcid)[0,1];
        my @part_num = $id =~/\d{3}/g;
        my $url = "/genomes/all/$gcty/". join("/",@part_num);

        return $url
}
