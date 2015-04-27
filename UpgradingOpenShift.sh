#!/bin/sh
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

function upgrade_check(){
        echo "Checking for successful upgrade. This may take a few minutes..."
        release_out=`cat /etc/openshift-enterprise-release`
        release_code=`grep "2.2.*" /etc/openshift-enterprise-release &> /dev/null; echo $?`
        if [[ $release_code == 0 ]]; then
                echo "OpenShift Version: $release_out"
                echo "    ${bold}Note${normal}: This may not be 100% correct!"
                # Checking Vhost
                vhost_code=`sudo grep -io vhost /etc/openshift/node.conf &> /dev/null; echo $?`
                if [[ $vhost_code == 0 ]]; then
                    echo "vhost pass!"
                else
                    echo "vhost check failed." 
                    echo "  Please follow ${bold}https://access.redhat.com/documentation/en-US/OpenShift_Enterprise/2/html-single/Administration_Guide/index.html#Changing_Front-end_HTTP_Server_Plug-in_Configuration${normal} to complete this step."
                    exit 1
                fi
                diag_out=`sudo oo-diagnostics`
                diag_code=`echo $?`
                if [[ $diag_code == 0 ]]; then
                        echo "Diagnostics pass!"
                        print_code "upgrade_check"
                else
                        echo "Diagnostics failed: run ${bold}oo-diagnostics${normal} to see errors."
                        exit 1
                fi
        else
                echo "OpenShift version is not 2.2:"
                echo "$release_out"
        fi
}

function print_code(){
	if [[ $1 == "upgrade_check" ]]; then
		echo "Completion Code: ${bold}Openshift4ever${normal}"
	fi
}

if [[ -n $1 ]]; then
	upgrade_check
else
	usage
fi
exit 0

if [[ -n $1 ]]; then
	arg=`echo $1 | tr '[:upper:]' '[:lower:]'`
	if [[ $arg == "check" ]]; then
		arg2=`echo $2 | tr '[:upper:]' '[:lower:]'`
		if [[ $arg2 == "upgrade" ]]; then
			upgrade_check	
		else
			echo "Unrecognized check argument."
		fi
	else
		echo "Unrecognized argument"
	fi
else
	echo "Please provide an argument"
	usage
fi
