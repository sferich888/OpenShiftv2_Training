#!/bin/sh
TMP_DIR="/home/openshift/.tmp/openshift"
bold=`tput bold`
normal=`tput sgr0`

function usage(){
#	echo "$0 [ break | check {upgrade | break}]"
	echo "$0 check"
	echo "  Checks to ensure the upgrade completed successfully"
#	echo "break - Breaks the environment as though an issue occured during the upgrade"
#	echo "check - Checks one of the following:"
#	echo "  upgrade - Checks to ensure the upgrade completed successfully"
#	echo "  break   - Checks to ensure the problem introduced by 'break' is resolved"
	echo "  Prints a completion code upon success."
}

function break_upgrade(){
	echo "Breaking the environment to simulate an upgrade issue..."
}

function upgrade_check(){
	echo "Checking for successful upgrade. This may take a few minutes..."
	release_out=`cat /etc/openshift-enterprise-release`
	release_code=`grep "2.2.*" /etc/openshift-enterprise-release &> /dev/null; echo $?`
	if [[ $release_code == 0 ]]; then
		echo "OpenShift Version: $release_out"
		diag_out=`sudo oo-diagnostics 2>1`
		diag_code=`echo $?`
		if [[ $diag_code == 0 ]]; then
			echo "Diagnostics pass!"
			print_code "upgrade_check"
		else
			echo "Diagnostics failed:"
			echo $diag_out
			exit 1
		fi
	else
		echo "OpenShift version is not 2.2:"
		echo "$release_out"
	fi
}

function break_check(){
	echo "Checking for resolution of issue introduced by 'break'..."
}

function print_code(){
	if [[ $1 == "upgrade_check" ]]; then
		echo "Completion Code: ${bold}Openshift5ever${normal}"
	elif [[ $1 == "break_check" ]]; then
		echo "Completion Code: ${bold}CloudFoundryIsLame${normal}"
	fi
}

if [[ -n $1 ]]; then
	upgrade_check
else
	usage
fi
exit 0

# Ignored
if [[ -n $1 ]]; then
	arg=`echo $1 | tr '[:upper:]' '[:lower:]'`
	if [[ $arg == "check" ]]; then
		arg2=`echo $2 | tr '[:upper:]' '[:lower:]'`
		if [[ $arg2 == "upgrade" ]]; then
			upgrade_check	
		elif [[ arg2 == "break" ]]; then
			break_check
		else
			echo "Unrecognized check argument."
		fi
	elif [[ arg == "break" ]]; then
		break_upgrade
	else
		echo "Unrecognized argument"
	fi
else
	echo "Please provide an argument"
	usage
fi
