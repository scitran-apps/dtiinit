#! /usr/bin/env python

# Parse a config file and create a dtiInit params json file.
def parse_config(input_file, output_file, input_dir, output_dir):
    import json

    # Read the config json file
    with open(input_file, 'r') as jsonfile:
        config = json.load(jsonfile)

    # Rename the config key to params
    config['params'] = config.pop('config')

    # Combine to build the dwOutMm array ( This can be removed once support for arrays is added in the schema. )
    dwOutMm = [config['params']['dwOutMm-1'], config['params']['dwOutMm-2'], config['params']['dwOutMm-3']]
    config['params']['dwOutMm'] = dwOutMm

    # Remove the other dwOutMm fields
    del config['params']['dwOutMm-1']
    del config['params']['dwOutMm-2']
    del config['params']['dwOutMm-3']

    # Add input directory for dtiInit
    config['input_dir'] = input_dir
    config['output_dir'] = output_dir

    # Write out the modified configuration
    with open(output_file, 'w') as config_json:
        json.dump(config, config_json)

if __name__ == '__main__':

    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('--input_file', default='/flwywheel/v0/config.json', help='Full path to the input file.')
    ap.add_argument('--output_file', default='/flywheel/v0/json/dtiinit_params.json', help='Full path to the output file.')
    ap.add_argument('--input_dir', default='/flwywheel/v0/input', help='Full path to the input file.')
    ap.add_argument('--output_dir', default='/flywheel/v0/output', help='Full path to the output file.')
    args = ap.parse_args()

    parse_config(args.input_file, args.output_file, args.input_dir, args.output_dir)
