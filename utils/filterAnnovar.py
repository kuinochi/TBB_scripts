#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
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
            # print(row)
            if row['Func.refGene'] not in ['exonic', 'splicing', 'exonic;splicing']:
                continue
            else:
                if row['esp6500siv2_all'] == '.' or float(row['esp6500siv2_all']) < 0.05:
                    if row['1000g2015aug_all'] == '.' or float(row['1000g2015aug_all']) < 0.05:
                        if row['ExAC_ALL'] == '.' or float(row['ExAC_ALL']) < 0.05:
                            if row['ExonicFunc.refGene'] != 'synonymous SNV': # row['ExonicFunc.knownGene'] != 'synonymous SNV'
                                if((row['SIFT_score'] == '.' or float(row['SIFT_score']) < 0.05) or
                                   (row['Polyphen2_HDIV_score'] == '.' or float(row['Polyphen2_HDIV_score']) > 0.995)):
                                    # print (['{}'.format(row[col]) for col in w_fieldnames], sep='\t')
                                    #print(row[None])
                                    row[None] = '\t'.join(row[None])
                                    # row[None] = row[None].replace('~','')
                                    # print(row)
                                    writer.writerow(row)
    fname = "{0}.filtered.tsv".format(output_file)
    with open(ftemp, 'r') as fdel, open(fname, 'w') as fout:
        for line in fdel:
            fout.write(line.rstrip().replace('\\', '')+"\n")

    os.remove(ftemp)
    return



def main():
    args = get_args()
    read_files(args.Input, args.Output)


if __name__ == '__main__':
    main()

