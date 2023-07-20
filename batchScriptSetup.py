import sys
import os
import argparse

# batchScriptSetup.py <experiment_name> <mapping_file>

def replace_text(in_file, out_file, source_text, target_text):    
    if isinstance(source_text, str) and isinstance(target_text, str):
        source_text, target_text = [source_text], [target_text]

    # Write a submission file according to the number of Slurm Arrays required
    with open(in_file, 'r') as f: fdata = f.read()

    for source, target in zip(source_text, target_text):
        fdata = fdata.replace(source, target)

    if os.path.exists(out_file): os.remove(out_file)
    with open(out_file, 'w') as f: f.write(fdata)

def create_arg_parser():
    def is_valid_file(parser, arg):
        if not os.path.isfile(arg):
            parser.error(f'File {arg} not found.')
        else:
            return arg

    parser = argparse.ArgumentParser(description='Set up batch script for mosquito model')
    parser.add_argument('-n', '--experiment_name', dest='experimentName', action='store', required=True)
    parser.add_argument('-m', '--mapping_filename', dest='mappingFilename', action='store',
                        type=lambda x: is_valid_file(parser, x), required=True)

    return parser


def main():
    # Argument Parsing
    parser = create_arg_parser()
    args = parser.parse_args()

    # Hardcoded Arguments
    mappingDir = 'slurmArrayMapping'
    hpusPerArray = 50

    # print(args.experimentName)

    # Read in list of HPUs to run
    with open(args.mappingFilename, 'r') as f:
        hpuList = [line.rstrip() for line in f]
    hpuList = sorted(hpuList)

    # Split HPU list into different jobs
    slurmArrays = [hpuList[hpusPerArray*i:hpusPerArray*(i+1)] for i in range(len(hpuList) // hpusPerArray)] + [hpuList[-(len(hpuList) % hpusPerArray):]]

    # Delete all files in mapping directory
    for toDelete in os.listdir(mappingDir):
        os.remove(os.path.join(mappingDir, toDelete))

    # Write each job to a file for the array to serially run
    for i, arr in enumerate(slurmArrays):    
        with open(os.path.join(mappingDir, f'{i}.txt'), 'a') as f:
            for hpuID in arr:
                f.write(str(hpuID)+'\n')

    # Write the number of arrays needed into submission file
    replace_text(in_file='mosquitoPopSubmissionTemplate.sh',
                out_file=f'mosquitoPopSubmission_{args.experimentName}.sh',
                source_text='INSERT_ARRAYS',
                target_text=f'0-{len(slurmArrays)-1}')

if __name__=='__main__':
    main()