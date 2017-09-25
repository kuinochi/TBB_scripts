#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
import sys
import csv
import argparse

def get_args():
    """
    Get the args and/or show the help message.
    TODO: Aadd filter option.
    """
    parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter, description="""
        filter ANNOVAR output files.
        """)
    parser.add_argument('Input', help='The original ANNOVAR.outfile')
    parser.add_argument('Output', help='The output prefix string of filtered outfile, \
                                        i.e. given "Sample1", the output file will be Sample1.filtered.tsv')
    args = parser.parse_args()
    return args


def read_files(input_file, output_file):
    """
    Read ANNOVAR files, return a filtered.
    """
    number_all, number_exonic, number_af, number_nonsyn, number_sift_poly2 = 0, 0, 0, 0, 0
    ftemp = "._tempAN.txt"
    with open(input_file, 'r') as in_file, open(ftemp, 'w') as temp_file:
        reader = csv.DictReader(in_file, delimiter='\t', quoting=csv.QUOTE_NONE, restkey=None)
        wfieldnames = list(reader.fieldnames)
        wfieldnames.append(None)
        writer = csv.DictWriter(temp_file, delimiter='\t', fieldnames=wfieldnames,
                                extrasaction='raise', doublequote=False,
                                quoting=csv.QUOTE_NONE,
                                quotechar='', escapechar='\\')
        writer.writeheader()
        for row in reader:
            number_all += 1
            if row['esp6500siv2_all'] == '.' or float(row['esp6500siv2_all']) < 0.05:
                if row['1000g2015aug_all'] == '.' or float(row['1000g2015aug_all']) < 0.05:
                    if row['ExAC_ALL'] == '.' or float(row['ExAC_ALL']) < 0.05:
                        number_af += 1
                        if row['Func.refGene'] in ['exonic', 'splicing', 'exonic;splicing']:
                            number_exonic += 1
                            if row['ExonicFunc.refGene'] != 'synonymous SNV':
                                number_nonsyn += 1
                                if((row['SIFT_score'] == '.' or float(row['SIFT_score']) < 0.05) or
                                   (row['Polyphen2_HDIV_score'] == '.' or float(row['Polyphen2_HDIV_score']) > 0.909)):
                                    number_sift_poly2 += 1
                                    row[None] = '\t'.join(row[None])
                                    # print(row)
                                    writer.writerow(row)

            # if row['Func.refGene'] not in ['exonic', 'splicing', 'exonic;splicing']:
            #     continue
            # else:
            #     number_exonic+=1
            #     if row['esp6500siv2_all'] == '.' or float(row['esp6500siv2_all']) < 0.05:
            #         if row['1000g2015aug_all'] == '.' or float(row['1000g2015aug_all']) < 0.05:
            #             if row['ExAC_ALL'] == '.' or float(row['ExAC_ALL']) < 0.05:
            #                 number_af+=1
            #                 if row['ExonicFunc.refGene'] != 'synonymous SNV': # row['ExonicFunc.knownGene'] != 'synonymous SNV'
            #                     number_nonsyn+=1
            #                     if((row['SIFT_score'] == '.' or float(row['SIFT_score']) < 0.05) or # SIFT score < 0.05
            #                        (row['Polyphen2_HDIV_score'] == '.' or float(row['Polyphen2_HDIV_score']) > 0.909)): #  polyphen2 > 0.909
            #                         # print (['{}'.format(row[col]) for col in wfieldnames], sep='\t')
            #                         # print(row[None])
            #                         number_sift_poly2 += 1
            #                         row[None] = '\t'.join(row[None])
            #                         # row[None] = row[None].replace('~','')
            #                         writer.writerow(row)
            #                         print(row)

    fname = "{0}.filtered.tsv".format(output_file)
    with open(ftemp, 'r') as fdel, open(fname, 'w') as fout:
        for line in fdel:
            fout.write(line.rstrip().replace('\\', '')+"\n")

    os.remove(ftemp)
    #print("Total variants: {:10d}\nIn Exonic or Splicing: {}\nAllele frequency < 0.05: {}\nNonsynonymous: {}\nSIFT < 0.05 or polyphen2 > 0.909: {}".format(number_all, number_exonic, number_af, number_nonsyn, number_sift_poly2))
    print("Sample: {}".format(output_file)   , file=sys.stderr)
    print("Total variants: {}".format(number_all), file=sys.stderr)
    print("Allele frequency: {}".format(number_af), file=sys.stderr)
    print("Exonic or Splicing: {}".format(number_exonic), file=sys.stderr)
    print("Nonsynonymous: {}".format(number_nonsyn), file=sys.stderr)
    print("SIFT or polyphen2: {}".format(number_sift_poly2), file=sys.stderr)

    return



def main():
    args = get_args()
    read_files(args.Input, args.Output)


if __name__ == '__main__':
    main()

