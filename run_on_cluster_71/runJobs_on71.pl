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
for (my $i = $opt_s-1; $i < $opt_e; $i++ ){
    my $running_job = &countJob();
    if ($running_job < 8){
        printf (STDOUT "Sample %s: %s, from line: %d\n", $i, $idlist[$i], $i+1 );
        if ( $i % 8 <= 5){
            execute("qsub -q long2 callBySentieon_hg19.sh -N VC_$idlist[$i] -l walltime=48:00:00,nodes=1:ppn=20 -v SampleName=$idlist[$i],CPU_Number=20");
        } else {
            execute("qsub -q large callBySentieon_hg19.sh -N VC_$idlist[$i] -l walltime=48:00:00,nodes=1:ppn=40 -v SampleName=$idlist[$i],CPU_Number=40");
        }
    } else {
        printf (STDOUT "There are already %d running jobs.\nWait 1,200 seconds until next check.\nWaiting sample: %s\n", $running_job, $idlist[$i]);
        sleep 1200;
        redo;
    }
}


sub execute {
    my $cmd = shift;
    print "$cmd\n";
    system($cmd);
}

sub countJob {
    my $check_num_cmd = "qstat -a | grep VC_NGS| wc -l";
    my $jobnum = qx[$check_num_cmd];
    return $jobnum;
}
