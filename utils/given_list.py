#!/usr/bin/python
# -*- coding: utf-8 -*-
import re
import argparse

def get_args():
    """
    Get the args and/or show the help message.
    TODO: Aadd filter option.
    """
    parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter, description="""
        Given List to parse
        """)
    parser.add_argument('Input', help='The original ANNOVAR.outfile.')
    parser.add_argument('List', help='The given gene ID list.')
    parser.add_argument('Output', help='The output prefix string of filtered outfile, \
                                        i.e. given "Sample1", the output file will be Sample1.filtered.tsv')
    args = parser.parse_args()
    return args


def grep_gene_id(in_file, in_id, out_name):
    """
    grep gene_id occur in given list.
    """
    out_file = "{0}.filterList.tsv".format(out_name)
    search_list = []
    with open(in_id, 'r') as fid:
        fid.readline() # Skip first line, header

        for line in fid:
            line = line.strip()

            if not line: # blank line
                continue

            arr = line.strip().split('\t')
            search_list.append(arr[0])
            for syn in arr[1].split(', '):
                if syn != 'No synonym':
                    search_list.append(syn)
    reg_list = []
    for raw_reg in search_list:
        reg_list.append(re.compile(raw_reg, re.IGNORECASE))

    with open(in_file, 'r') as fi:
        header = fi.readline().strip()
        write = []
        for line in fi:
            line = line.strip()
            # print(line)
            for compile_reg in reg_list:
                if compile_reg.search(line):
                    # print(line)
                    write.append(line)

    if write:
        with open(out_file, 'w') as fo:
            print(header, file=fo)
            for line in write:
                print(line, file=fo)

    return


def main():
    args = get_args()
    grep_gene_id(args.Input, args.List, args.Output)


if __name__ == '__main__':
    main()
