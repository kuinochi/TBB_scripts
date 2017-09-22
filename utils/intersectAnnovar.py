#!/usr/bin/python
# -*- coding: utf-8 -*-
import re
import csv
import itertools
import argparse

def get_args():
    """
    Get the args and/or show the help message.
    TODO: Aadd filter option.
    """
    parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter, description="""
        Annovar result analysis

        usage: python3 intersec_annovar.py Input Output_prefix

        Input file is a tab delimited to asscociate phenotype with annovar result files.

        Note: Need at least ONE sample for each Phenotype.

        For input:
        Column 1: Phenotype (POSITIVE: for Patient or Child, NEGATIVE: for Normal or Parent)
        Column 2: SampleID (for distinguish sample, unique per sample)
        Column 3: Annovar results file names. (Filename should NOT contain white spaces.)
        """)
    parser.add_argument('Input', help='The input file')
    # parser.add_argument('Output',
    # help='The output prefix string of filtered outfile, i.e. given "Sample1", the output file will be Sample1.filtered.tsv')
    args = parser.parse_args()
    return args

def parse_input_library(input_file):
    """
    Parse Library List file
    """
    avr_lib = {}
    with open(input_file, 'r') as fh:
        for line in fh:
            if not line.strip():
                continue
            sample = line.strip().split()
            if not (sample[0] == "POSITIVE" or sample[0] == "NEGATIVE"):
                raise Exception("Unrecognized phenotype: " + sample[0])

            avr_lib[sample[1]] = {
                'Type': sample[0],
                'Name': sample[1],
                'File': sample[2],}
    return avr_lib


def read_record(input_file):
    """
    Read file
    """
    record_dict = {}
    with open(input_file, 'r') as in_fh:
        reader = csv.reader(in_fh, delimiter='\t')
        header = next(reader)
        record_dict['header'] = header
        for row in reader:
            key = '_'.join(row[0:5])
            record_dict[key] = row
        # for line in in_fh:
        #     if re.match(r'^Chr\sStart\sEnd\sRef\sAlt', line):
        #         record_dict['header'] = line
        #     else:
        #         for row in csv.reader(in_fh, delimiter='\t'):
        #             key = '_'.join(row[0:5])
        #             # print(key)
        #             record_dict[key] = row
    return record_dict


def compare_record(input_dict_1, input_dict_2):
    """
    Read two dict and output three dict: shared, unique_1 and unique_2
    """
    shared_dict = {}
    shared_keys = input_dict_1.keys() & input_dict_2.keys()
    for shared_key in shared_keys:
        shared_dict[shared_key] = {
            'sample_1': input_dict_1[shared_key],
            'sample_2': input_dict_2[shared_key]
        }
    unique_1_dict, unique_2_dict = {}, {}

    unique_1_keys = input_dict_1.keys() - input_dict_2.keys()
    for u1_key in unique_1_keys:
        unique_1_dict[u1_key] = input_dict_1[u1_key]

    unique_2_keys = input_dict_2.keys() - input_dict_1.keys()
    for u2_key in unique_2_keys:
        unique_2_dict[u2_key] = input_dict_2[u2_key]

    # return (shared_dict, unique_1_dict, unique_2_dict)
    return shared_dict


def natural_sort(input_list):
    convert = lambda text: int(text) if text.isdigit() else text.lower()
    alphanum_key = lambda key: [convert(c) for c in re.split('([0-9]+)', key)]
    return sorted(input_list, key=alphanum_key)


def main():
    """ Entry point of main function, execute the program"""
    args = get_args()
    sample_libs = parse_input_library(args.Input)
    neg_dict, pos_dict = {}, {}

    for key, value in sorted(sample_libs.items()):
        sample_name, sample_pheno, sample_file = str(key), value['Type'], value['File']
        if sample_pheno == 'NEGATIVE':
            neg_dict[sample_name] = read_record(sample_file)
        elif sample_pheno == 'POSITIVE':
            pos_dict[sample_name] = read_record(sample_file)

    pos_v_list = []
    for sample_p in list(sorted(pos_dict.keys())):
        pos_v_list.append(list(pos_dict[sample_p].keys()))
    share_v_pos = list(set.intersection(*map(set, pos_v_list)))

    neg_v_list = []
    for sample_n in list(sorted(neg_dict.keys())):
        neg_v_list.append(list(neg_dict[sample_n].keys()))
    union_v_neg = list(set.union(*map(set, neg_v_list)))

    uniq_v_in_pos = set(share_v_pos) - set(union_v_neg)

    for sample_p in pos_dict.keys():
        fname = "{0}.intersected.tsv".format(sample_p)
        with open(fname, 'w') as result_fh:
            out_writer = csv.writer(result_fh, delimiter='\t', escapechar='\t')
            # print(type(neg_dict[sample_n]['header']))
            out_writer.writerow(pos_dict[sample_p]['header'])
            for key in natural_sort(uniq_v_in_pos):
                out_writer.writerow(pos_dict[sample_p][key])


if __name__ == '__main__':
    main()

