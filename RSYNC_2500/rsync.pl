#!/usr/bin/perl 

=head1 Name

  $0.pl  -- 

=head1 Description

  Use:

=head1 Version

  Author: LiLinji, lilinji@genomics.cn
  Version: 1.0,  Date: 2013-09-12

=head1 Usage
  % $0  [option] <pos_file> <seq_file>
  --verbose           output verbose information to screen  
  --help              output help information to screen  

=head1 Exmple
 perl   rsync.pl  -input1 old.txt   -input2 new.txt 

=cut

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use Data::Dumper;
use Cwd;
#use PerlIO::gzip;## gunzip file # "<:gzip",
my %config;
my ($input1,$input2,$Flank5,$Flank3);
my ($Verbose,$Help);
GetOptions(
        "input1:s"   =>\$input1,
       "input2:s"   =>\$input2,
        "verbose!"  =>\$Verbose,
        "help!"     =>\$Help
);
my $Type ||= "hehe";
die `pod2text $0` if (defined $Help);
die `pod2text $0` if (!defined $input1);
#################################################################
my $output||='';                                                #
my $dir1=$input1;                                              #
my $dir2=$input2;
                                        #
#my $dir2=`perl $config{absolute_dir} $ARGV[3]`;                #
open IN,"$dir1" or die "can't open $dir1";                      #
&showtime("start");                                             #                                                               #
my @tmp=();                                                     #
my %hash=();                                                    #
#################################################################
######################################Initialize variables
while (<IN>){
   chomp;
@tmp=split /\s+/,$_;
$hash{$tmp[0]}++;
#print "$tmp[0]\n";
}
close IN;
######################################Initialize variables2
my @new_tmp=();
my %hash2=();
open IN1,"$dir2" or die "can't open $dir2";
while (<IN1>){
   chomp;
@new_tmp=split /\s+/,$_;
#print "$new_tmp[0]\n";
if (exists  $hash{$new_tmp[0]}){
}else{

print "$new_tmp[0]\n";
#printf   IN3  "#\!\/bin\/sh\n";
system "rm -r  /data/TJ_D177/dir_A/ && mkdir -p  /data/TJ_D177/dir_A/$new_tmp[0]";
open IN3, ">/data/TJ_D177/dir_A/$new_tmp[0]/ok" or die "can't open $new_tmp[0]";
print IN3 "please rsync\n";
close IN3;
}
}
#####################################Hash_to_processing
foreach my $key (sort desc_sort_hash keys  %hash){
      #  print "\t% -20s%5d\n",$key,$hash{$key};
  }
sub desc_sort_hash{
   $hash{$b}<=>$hash{$a};
 #  $hash{$b} cmp $hash{$a};
}
sub showtime {
        my ($info) = @_;
        my @times = localtime; # sec, min, hour, day, month, year
        print STDERR sprintf("[%d-%02d-%02d %02d:%02d:%02d] %s\n", $times[5] + 1900, $times[4] + 1, $times[3], $times[2], $times[1], $times[0], $info);
}
my ($a1,$a2,$b1,$b2);
sub ab {
        if ($a=~/(\S+)\s+(\S+)/){

         $a1=$1;
         $a2=$2;
        }
        if ($b=~/(\S+)\s+(\S+)/){

         $b1=$1;
         $b2=$2;
        }
  $a1<=>$b1 ;  $a2 cmp $b2;
}
