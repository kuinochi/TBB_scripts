#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long qw(GetOptions);


sub Usage{
    print "\nUsage: $0 -i INPUT ANNOVAR results -p output prefix\n";
    print "Print the variants based on the below criteria:\n";
    print "\t1. which is exonic or splicing\n";
    print "\t2. and not synonymous SNV\n";
    print "\t3. and refGene name is on the ACMG SF list\n";
    print "Using -s will show current list of ACMG SF gene.\n\n";
    exit;
}
!@ARGV && &Usage();

my $show;
my $prefix = 'out';
my $infile;
GetOptions('show' => \$show, 'infile=s' => \$infile, 'prefix=s' => \$prefix);

my @ACMG = qw(ACTA2 ACTC1 APC APOB ATP7B BMPR1A BRCA1 BRCA2 CACNA1S COL3A1 DSC2 DSG2 DSP FBN1 GLA 
              KCNH2 KCNQ1 LDLR LMNA MEN1 MLH1 MSH2 MSH6 MUTYH MYBPC3 MYH11 MYH7 MYL2 MYL3 NF2 OTC 
              PCSK9 PKP2 PMS2 PRKAG2 PTEN RB1 RET RYR1 RYR2 SCN5A SDHAF2 SDHB SDHC SDHD SMAD3 SMAD4 
              STK11 TGFBR1 TGFBR2 TMEM43 TNNI3 TNNT2 TP53 TPM1 TSC1 TSC2 VHL WT1);
my %ACMG_h = map {$_ => 1} @ACMG;

if ( $show ) {
    my $size = scalar @ACMG;
    print "Current ACMG list: Total $size genes\n";
    print "------------------------------------\n";
    for (my $i = 0; $i < $size; $i++) {
        if ( ($i+1) % 12 == 0 || $i+1 == $size) {
            print "$ACMG[$i]\n";
        } else {
            print "$ACMG[$i]\t";
        }
    }
    exit;
}


open IN, "<$infile";
open OUT, ">$prefix.acmg.sf.list";

my $first_line = <IN>;
chomp $first_line;
print OUT "$first_line\n";
my @header = split("\t", $first_line);

my ($number, $found) = (0)x2;
# my %hash;
my %fun_ref = ("exonic" => 1, "exonic;splicing" => 1 , "splicing" => 1);
my %ExonFun_ref = ("synonymous SNV" => 1);

while ( my $line = <IN> ) {
    chomp $line;
    my @a = split("\t", $line);
    my $idx = 0;
    # my %row = map {$_ => $a[$idx++] } split("\t", $first_line); slower
    my %row ; $row{$_} = $a[$idx++] foreach @header;
    #print "$_" for keys %row;

    # my $hash{"record".$number} = \%row;

    if ( exists $ACMG_h{$row{'Gene.refGene'}} ) { # refGene name is in ACMG SF list
        #if ( exists $fun_ref{$row{'Func.refGene'}} ) { # variant is exonic, splicing or exonic;splicing
            #if ( ! exists $ExonFun_ref{$row{'ExonicFunc.refGene'}}) { # variants is NOT synonymous
            if ($row{'CLINSIG'} =~ /pathogenic/i ) { # ClinVar report significance with pathogenic 
                print OUT "$line\n";
                $found++;
            }
        #}
    }
    $number++;
}



print STDERR "Total variant: $number\n";
print STDERR "Found ACMG SF: $found\n";

close IN;
close OUT;
exit; 

