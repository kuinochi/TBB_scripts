#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
import sys
import csv
import argparse

def get_args():
    """
    Get the args and/or show the help message.
    TODO: Add filter option.
    """
    parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter, description="""
        filter ANNOVAR output files.
        """)
    parser.add_argument('Input', help='The original ANNOVAR.outfile')
    # parser.add_argument('Output', help='The output prefix string of filtered outfile, \
    #                                    i.e. given "Sample1", the output file will be Sample1.filtered.tsv')
    args = parser.parse_args()
    return args


def read_files(input_file): #, output_file):
    """
    Read ANNOVAR files, return a filtered.
    """
    # Counter
    number_all, number_exonic, number_af = 0, 0, 0
    number_nonsyn, number_syn, number_unknown = 0, 0, 0
    number_truncate, number_nonframeshift_indel = 0, 0
    all_exon, all_truncate, all_nonsyn = 0, 0, 0

    #ftemp = "._tempAN.txt"
    with open(input_file, 'r') as in_file: #, open(ftemp, 'w') as temp_file:
        reader = csv.DictReader(in_file, delimiter='\t', quoting=csv.QUOTE_NONE, restkey=None)
        for row in reader:
            number_all += 1
            if row['Func.refGene'] in ['exonic', 'splicing', 'exonic;splicing']:
                all_exon += 1
            if row['ExonicFunc.refGene'] in ['frameshift insertion', 'frameshift deletion', 'stopgain', 'stoploss'] :
                all_truncate += 1
            if row['ExonicFunc.refGene'] == 'nonsynonymous SNV' :
                all_nonsyn += 1
            if (row['esp6500siv2_all'] == '.' and row['1000g2015aug_all'] == '.' and \
                row['ExAC_ALL'] == '.' and row['cg69'] == '.' and \
                row['Kaviar_AF'] == '.' and row['tbbaf'] == '.'):
                number_af += 1
                if row['Func.refGene'] in ['exonic', 'splicing', 'exonic;splicing']:
                    number_exonic += 1
                    if row['ExonicFunc.refGene'] == 'synonymous SNV':    # row['ExonicFunc.knownGene'] != 'synonymous SNV'
                        number_syn += 1
                        continue
                    elif row['ExonicFunc.refGene'] == 'nonsynonymous SNV':
                        number_nonsyn += 1
                        continue
                    elif row['ExonicFunc.refGene'] in ['frameshift insertion', 'frameshift deletion', 'stopgain', 'stoploss']:
                        number_truncate += 1
                        continue
                    elif row['ExonicFunc.refGene'] in ['nonframeshift insertion', 'nonframeshift deletion']:
                        number_nonframeshift_indel += 1
                        continue
                    elif row['ExonicFunc.refGene'] in  ['unknown', '.']:
                        number_unknown += 1
                        #print(row)
                        continue


    #print("Sample: {}".format(output_file), file=sys.stderr)
    print("Total variants:      {}".format(number_all), file=sys.stderr)
    print("No allele frequency: {}".format(number_af), file=sys.stderr)
    print("Exonic or Splicing:  {}".format(number_exonic), file=sys.stderr)
    print("Synonymous SNV:      {}".format(number_syn), file=sys.stderr)
    print("Nonsynonymous SNV:   {}".format(number_nonsyn), file=sys.stderr)
    print("Truncate (fs/lof):   {}".format(number_truncate), file=sys.stderr)
    print("Nonframeshift_indel: {}".format(number_nonframeshift_indel), file=sys.stderr)
    print("Unknown:             {}".format(number_unknown), file=sys.stderr)
    print("------", file=sys.stderr)
    print("Location: {}".format(all_exon), file=sys.stderr)
    print("Truncated: {}".format(all_truncate), file=sys.stderr)
    print("Nonsynonymous SNV: {}".format(all_nonsyn), file=sys.stderr)
    return


def main():
    args = get_args()
    read_files(args.Input) 


if __name__ == '__main__':
    main()

