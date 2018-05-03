#!/usr/bin/perl
use strict;
use warnings;
#use autodie;
use Getopt::Std;
use vars qw($opt_i $opt_s $opt_e);
getopts("i:s:e:");

sub Usage {
print  <<EOF;

Usage: $0 -i ID-File -s Start -e End
    -i ID-File: the File contain Sample ID
    -s Start: From which lines (sample).
    -e End: To which lines (sample).

EOF
exit;
}


if(!$opt_i || !$opt_s || !$opt_e){
  &Usage();
}


# Read FILE
open FH, "<", "$opt_i" or die "$!";
my @idlist;
while(my $line = <FH>){
    chomp $line;
    push (@idlist, $line);
}
close FH;

# Run Jobs
# TBB_hg19_sentieon.sh <SampleName> <CPU_Number>
for (my $i = $opt_s-1; $i < $opt_e; $i++ ){
    my @tmp = split('\t', $idlist[$i]);
    my $type = $tmp[0];
    my $sample = $tmp[1];
    my $read1 = $tmp[2];
    my $read2 = $tmp[3];

    my $running_job = &countJob();
    if ($running_job < 8){
        printf (STDOUT "Sample %s: %s, from line: %d\n", $i+1, $sample, $i+1 );
        execute("bsub -q 48G -J wgs2rdd.$sample \"bash ./run_Sentieon.sh 24 $type $sample $read1 $read2\"");
    } else {
        printf (STDOUT "There are already %d running jobs.\nWait 600 seconds until next check.\nWaiting sample: %s\n", $running_job, $sample);
        sleep 600;
        redo;
    }
}


sub execute {
    my $cmd = shift;
    print "$cmd\n";
    system($cmd);
}

sub countJob {
    #my $check_num_cmd = "qstat -a | grep VC_NGS| wc -l";
    my $check_num_cmd = "bjobs -l | grep wgs2rdd|wc -l";
    my $jobnum = qx[$check_num_cmd];
    return $jobnum;
}
