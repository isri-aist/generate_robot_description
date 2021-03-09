#!/usr/bin/env python

import sys
import yaml
import re


if __name__ == "__main__":
    # Check arguments
    if len(sys.argv) < 3:
        print("usage: {} [urdf_path] [mimic_path]".format(sys.argv[0]))
        exit(1)

    # Load a urdf file
    urdf_path = sys.argv[1]
    with open(urdf_path) as urdf_file:
        urdf_lines = urdf_file.readlines()

    # Load a mimic information file
    mimic_path = sys.argv[2]
    with open(mimic_path) as mimic_file:
        mimic_info_list = yaml.safe_load(mimic_file)

    # Add lines for mimic joints
    i = 0
    while i < len(urdf_lines):
        for mimic_info in mimic_info_list:
            # If the current line corresponds to mimic target joint
            if re.match("\s+<joint\s+name=\"{}\"\s+type=.*?>s*\n".format(mimic_info["trg_joint"]), urdf_lines[i]):
                # Add a line for the mimic joint specification below the current line
                mimic_line = "    <mimic joint=\"{}\"".format(mimic_info["src_joint"])
                for mimic_prop in mimic_info["properties"]:
                    mimic_line += " {}=\"{}\"".format(mimic_prop, mimic_info["properties"][mimic_prop])
                mimic_line += " />\n"
                urdf_lines.insert(i+1, mimic_line)
                i += 1 # Skip a newly added line
                break
        i += 1

    # Save a urdf file with mimic joint specifications
    with open(urdf_path, mode="w") as urdf_file_out:
        urdf_file_out.writelines(urdf_lines)
