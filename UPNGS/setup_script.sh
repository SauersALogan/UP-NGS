########################################################################################
# This is a script associated with the paired transcriptome/metagenome pipeline 
# developed by Logan Sauers. The main goal of this script is to setup 
# the aliases for the other scripts allowing them to be called directly.
########################################################################################

#!/bin/bash 

help_message () {
	echo ""
	echo "This is the setup script for the UP-NGS pipeline mandatory parameters include"
	echo ""
	echo "Parameters:"
	echo ""
	echo "UPNGS_basefolder = <path/to/UP-NGS/folder> ENSURE THERE IS NO HYPHEN IN THE FOLDER and USE ABSOLUTE FILE PATH"
	echo "--overwrite <will optionally overwrite the existing aliases>"
	echo ""
}

# Default the script to not overwrite
overwrite=false

# Read arguments
parsed_options=$(getopt -o h --long help,overwrite,UPNGS_basefolder: -n 'setup_script' --  "$@")
if [ $? -ne 0 ]; then 
	help_message 
	exit 1 
fi

# Needed when using getopt
eval set -- "$parsed_options"

# Go through the options one at a time, using shift to discard the first argument so $2
# becomes $1 again.
while true;  do
    case "$1" in
        --overwrite)
            overwrite=true  
            shift;;
        --UPNGS_basefolder)
            UPNGS_basefolder="$2"
            shift 2 ;;
        --help)
	        help_message
		    exit 0 ;;
	--)
		shift
		break ;; 
        *)
            echo "Unknown option: $1"
            help_message
            exit 1 ;;
    esac
done

# Initial Reporting
# Check if parameters entered
missing_args=()
if [ -z "${UPNGS_basefolder:-}"; then 
	echo "Error: Missing mandatory arguments." 
	help_message 
	exit 1 
fi

# Update genome URL 
qc_script="${UPNGS_basefolder}/scripts/qc_script.sh" 
database_setup="${UPNGS_basefolder}/scripts/database_setup.sh" 

# Ensuring the paths exist before progressing
if [ ! -f "$qc_script" ]; then
	echo "Error: Script not found at $qc_script. Exiting to prevent alias breaking"
	exit 1
fi

if [ ! -f "$database_setup" ]; then
	echo "Error: Script not found at $database_setup Exiting to prevent alias breaking"
	exit 1
fi

# Ensure the scripts are executable 
chmod +x "$qc_script" 
chmod +x "$database_setup"

# Check if ~/.bashrc exists (or ~/.bash_profile for macOS) and add the necessary 
# command 
shell_rc="$HOME/.bashrc" # For Linux (bash) 
if [ ! -f "$shell_rc" ]; then 
	shell_rc="$HOME/.bash_profile" # For macOS 
fi 

# If no valid shell config file, then exit
if [ ! -f "$shell_rc" ]; then
	echo " Error: No shell configuration file found, exiting"
	exit 1
fi

# Check if the alias for qc_script is already present in the shell config 
add_or_overwrite_alias() {
	local alias_name=$1
	local alias_command=$2
	
	if grep -q "alias $alias_name=" "$shell_rc"; then
		if $overwrite; then
			echo "Overwriting the existing alias for $alias_name"
			sed -i "/alias $alias_name=/d" "$shell_rc"
			echo "alias $alias_name='$alias_command'" >> "$shell_rc"
		else
			echo "alias $alias_name already exists. Skipping (use --overwrite to replace this alias)"
		fi
	else
		echo "Adding alias for $alias_name"
		echo "alias $alias_name='$alias_command'" >> "$shell_rc"
	fi
}

# Add or overwrite these aliases
add_or_overwrite_alias "UPNGS_qc" "$qc_script" 
add_or_overwrite_alias "UPNGS_database_setup" "$database_setup"

# Source the shell config to apply the changes immediately 
echo "Sourcing $shell_rc to apply changes..." 
source "$shell_rc" 

# Inform the user that the setup is complete 
echo "Setup complete. You can now run 'UPNGS_qc' and 'UPNGS_database_setup' to execute the scripts."
