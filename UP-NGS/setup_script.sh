########################################################################################
# This is a script associated with the paired transcriptome/metagenome pipeline 
# developed by Logan Sauers. The main goal of this script is to setup 
# the aliases for the other scripts allowing them to be called directly.
########################################################################################

#!/bin/bash 

# Define the path to the qc_script 
UP-NGS_basefolder="/path/to/downloaded/folder" # Replace with the actual path 
qc_script="${UP-NGS_basefolder}/scripts/qc_script.sh" 
database_setup="${UP-NGS_basefolder}/scripts/database_setup.sh" 

# Default the script to not overwrite
overwrite=false

# Parse command-line arguments 
while [[ "$#" -gt 0 ]]; do 
	case $1 in 
		--overwrite) 
			overwrite=true ;; 
		*) echo "Unknown option: $1" && exit 1 ;; 
	esac 
	shift 
done

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
add_or_overwrite_alias "UP-NGS_qc" "$qc_script" 
add_or_overwrite_alias "UP-NGS_database_setup" "$database_setup"

# Source the shell config to apply the changes immediately 
echo "Sourcing $shell_rc to apply changes..." 
source "$shell_rc" 

# Inform the user that the setup is complete 
echo "Setup complete. You can now run 'TRANS_qc' to execute the scripts."
