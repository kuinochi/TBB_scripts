#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $show_list;
my $prefix = 'out';
my $infile;

GetOptions('showlist' => \$show_list, 'infile=s' => \$infile, 'prefix=s' => \$prefix);

=cut
my $usage = 
"Usage:\t--infile:\tinput_File.
       \t--prefix:\tOut_prefix, default: out.
       \t--showlist:\tprint current ACMG list. \n";
=cut

# ACMG List
# Adopted from  ACMG SF v2.0 (PubMed 27854360) Table 1.

my @ACMG = qw(ACTA2 ACTC1 APC APOB ATP7B BMPR1A BRCA1 BRCA2 CACNA1S COL3A1 DSC2 DSG2 DSP FBN1 GLA 
              KCNH2 KCNQ1 LDLR LMNA MEN1 MLH1 MSH2 MSH6 MUTYH MYBPC3 MYH11 MYH7 MYL2 MYL3 NF2 OTC 
              PCSK9 PKP2 PMS2 PRKAG2 PTEN RB1 RET RYR1 RYR2 SCN5A SDHAF2 SDHB SDHC SDHD SMAD3 SMAD4 
              STK11 TGFBR1 TGFBR2 TMEM43 TNNI3 TNNT2 TP53 TPM1 TSC1 TSC2 VHL WT1);
my %ACMG_h = map {$_ => 1} @ACMG;

if ( $show_list ) {
    my $size = scalar @ACMG;
    print "Current ACMG list: Total $size genes\n";
    for (my $i = 0; $i < $size; $i++) {
        if ( ($i+1) % 12 == 0 || $i+1 == $size) {
            print "$ACMG[$i]\n";
        } else {
            print "$ACMG[$i]\t";
        }
    }
    exit;
}


#  Generate gene.gff

open IN, "<$infile" or die "$!";
open OUT, ">$prefix.gene.gff" or die "$!";
while ( my $line = <IN> ) {
   chomp $line;
   
   if ($line =~ /^#/) {
       print OUT "$line\n" ; 
       next; 
   } 
   my @a = split('\t', $line);
   my $feature = defined($a[2]) ? $a[2]: "";
   if ($feature eq 'gene') {
      print OUT "$line\n";
   }
}
close IN;
close OUT;

# Generate ACMG list gff

open IN, "<$prefix.gene.gff" or die "$!";
open OUT, ">$prefix.acmg.gff" or die "$!";
while (my $line = <IN> ) {
    chomp $line;

    if ($line =~ /^#/) {
        #print OUT "$line\n";
        next;
    } 
    my @temp = split('\t', $line);
    next if ( $temp[0] !~ /^NC|^chr/);
    my $at = defined $temp[8] ? $temp[8]: "";
    my @a  = split(';', $at);
    my %attribute = map { my ($key, $value) = split('=', $_, 2) } @a;
    my $name;
    if (exists $attribute{'gene'} ) {
        $name = 'gene';
    } elsif (exists $attribute{'gene_name'} ) {
        $name = 'gene_name';
    } else {
        die "check attribute name.";
    }
    # if ( exists($ACMG_h{$attribute{'gene'}}) || exists($ACMG_h{$attribute{'gene_name'}}) ){ 
    if ( exists ($ACMG_h{$attribute{$name}} ) ) {
        print OUT "$line\n";
    }
}
close IN;
close OUT;
exit;

