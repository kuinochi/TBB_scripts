#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
import sys
import csv
import argparse


def get_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter, description="""
        Given List to parse
        """)
    parser.add_argument('Answer', help='The ')
    parser.add_argument('List', help='The given gene ID list.')
    parser.add_argument('Output', help='The output prefix string of filtered outfile, \
                                        i.e. given "Sample1", the output file will be Sample1.filtered.tsv')
    args = parser.parse_args()
    return args


def open_answer(infile):
    with open(infile) as fh:


def main():
    args = get_args()
    grep_gene_id(args.Input, args.List, args.Output)


if __name__ == '__main__':
    main()
