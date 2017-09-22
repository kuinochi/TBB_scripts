#!/usr/bin/perl
use strict;
use warnings;
use autodie;

sub Usage{
    print "\nUSAGE: $0 <TRUE_VCF> <EVAL_VCF>\n\n";
    exit 1;
}

Usage() if scalar @ARGV != 2;

##25  14906   AX-11414507     A       G       .       .       .       GT      1/1
##25  15043   AX-11414509     G       A       .       .       .       GT      0/0
##25  15204   AX-83536040     T       C       .       .       .       GT      0/0

my ($numP, $numN, $numTP, $numFP, $numFN, $numTN) = (0)x6;

my ( %hashMap );
open my $FILE, "$ARGV[0]" or die "Can not open $ARGV[0].\n";
while (my $in = <$FILE>) {
    next if $in =~ m/^#/;
    chomp $in;
    my @a = split('\t', $in);
    next if ($a[3] eq 'N' || $a[4] eq 'N' );
    my ($chr, $pos, $ref, $alt, $vid) = ($a[0], $a[1], $a[3], $a[4], "$a[0]_$a[1]");
    ${hashMap}{$vid}{'REF'} = $ref;
    ${hashMap}{$vid}{'ALT'} = $alt; 
}
close $FILE;
$numP = keys %hashMap;


my (%hashEvl);
open my $EFILE, "$ARGV[1]" or die "Can not open $ARGV[1].\n";
while (my $in = <$EFILE>) {
     next if $in =~ m/^#/;
     chomp $in;
     my @a = split('\t', $in);
     next if ($a[3] eq 'N' || $a[4] eq 'N' );
     my ($chr, $pos, $ref, $alt, $vid) = ($a[0], $a[1], $a[3], $a[4], "$a[0]_$a[1]");
     ${hashEvl}{$vid}{'REF'} = $ref;
     ${hashEvl}{$vid}{'ALT'} = $alt;
 }
close $EFILE;
my $numV = keys %hashEvl;

foreach my $locus (keys %{hashMap}){
    if (exists ${hashEvl}{$locus}){
       my $Tref = ${hashMap}{$locus}{'REF'};
       my $Talt = ${hashMap}{$locus}{'ALT'};
       my $Eref = ${hashEvl}{$locus}{'REF'};
       my $Ealt = ${hashEvl}{$locus}{'ALT'};
       my ($rTref, $rTalt) = ($Tref, $Talt);
       $rTref =~ tr/ATCGatcg/TAGCtagc/;
       $rTalt =~ tr/ATCGatcg/TAGCtagc/;
       #print "$locus\t$Tref\t$Eref\t$Talt\t$Ealt\t$rTref\t$rTalt\n";
       if ( ($Tref eq $Eref) and ($Talt eq $Ealt) ){
           $numTP += 1;
       } 
       elsif ( ($rTref eq $Eref) and ($rTalt eq $Ealt) ){
           $numTP += 1;
       }
       else {
           $numN += 1;
       }
    }
    else {
       $numFN += 1;
    }
}

foreach my $elocus (keys %{hashEvl}){
    if (!exists ${hashMap}{$elocus}){
        $numFP +=1;
    }
}

my ($TPR, $PPV) = ( $numTP/($numTP+$numFN), $numTP/($numTP+$numFP) );

print "Sites in $ARGV[0]:  $numP\n";
print "Site in $ARGV[1]: $numV\n";
print "Different result:   $numN\n";
print "True Positive:      $numTP\n";
print "False Positive:     $numFP\n";
print "False Negative:     $numFN\n";
#print "True Negative:      $numTN\n";
print "TPR [ TP/(TP+FN) ]: $TPR\n";
print "PPV [ TP/(TP+FP) ]: $PPV\n";




exit;



=begin comment

True Positive (TP):  The number of variants in the Query VCF file that match the Truth VCF file
False Positive (FP): The number of variants in the Query VCF file that do not match the Truth VCF file
False Negative (FN): The number of variants in the Truth VCF file that do not match the Query VCF file
Precision:           True Positive / (True Positive + False Positive)
Recall:              True Positive / (True Positive + False Negative)

=cut

