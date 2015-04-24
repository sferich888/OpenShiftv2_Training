#!/bin/bash

TMP_DIR="/home/openshift/.tmp/openshift"
bold=`tput bold`
normal=`tput sgr0`

function usage(){
    echo "$0 Lab# [Break | Check | Reset]"
    echo "Lab numbers are as follows 1 2 3" 
    echo "Break - Sets up the VM for the Lab."
    echo "Check - Checks the status of the VM to see if the Lab has been completed."
    echo "Reset - Reverts the 'Break' setup, so the vm should be in working order." 
}

function Lab1Break(){
    echo "Setting up Break Fix Lab1"
    sudo cp /etc/openshift/broker.conf $TMP_DIR/bf1.break
    sudo sed -i 's/MONGO_USER="openshift"/#Original Setting: MONGO_USER="openshift"\nMONGO_USER="shifter"/' /etc/openshift/broker.conf
    sudo service openshift-broker restart &> /dev/null
    echo 
    echo "There is now an issue with the OSE VM, and the Broker does not seem to be responding."
    echo "Run ${bold}rhc server${normal} to see the issue."
    echo "Then use your troubleshooting skills to identify the issue and resolve it."
}
function Lab1Check(){
    if [[ -e $TMP_DIR/bf1.break ]]; then
        rhc server &> /dev/null
        if [[ $? -eq 0 ]]; then 
            echo "Completion Code: ${bold}Mongo${normal}"
        else
            echo "It looks like you are still haveing a problem."
            echo "Try looking at ${bold}/var/log/openshift/broker/httpd/error_log${normal} for clues to what is broken." 
        fi
    else
        echo "You must first setup the Break Fix Lab before you try and get the completion code."
    fi
}
function Lab1Reset(){
    if [[ -e $TMP_DIR/bf1.break ]]; then
        sudo cp $TMP_DIR/bf1.break /etc/openshift/broker.conf 
        sudo service openshift-broker restart &> /dev/null
        sudo rm $TMP_DIR/bf1.break
    fi
    rhc server &> /dev/null
    if [[ $? -eq 0 ]]; then 
        echo "The Lab is not currently broken."
    fi
}
LAB2_CONFIG_FILE="/usr/libexec/openshift/cartridges/php/bin/install"
LAB2_APP_NAME=bflab2
function Lab2Break(){
    echo "Setting up Break Fix Lab2"
    if [[ -e $LAB2_CONFIG_FILE ]]; then
        grep sleep $LAB2_CONFIG_FILE &> /dev/null
        if [[ $? -eq 1 ]]; then
            sudo bash -c "echo sleep 190 >> $LAB2_CONFIG_FILE"
            sudo service ruby193-mcollective restart &> /dev/null 
        fi
    fi
    echo 
    echo "There is now an issue with the OSE VM, and the php-5.4 applications are not being created."
    echo -n "Run ${bold}rhc app create $LAB2_APP_NAME php-5.4${normal} to see the issue. "
    echo "The 'Check' script will check to see if this app is created. "
    echo "Then use your troubleshooting skills to identify the issue and resolve it."

}
function Lab2Check(){
    echo "LAB2 Check"
    grep sleep $LAB2_CONFIG_FILE &> /dev/null
    if [[ $? -eq 0 ]]; then
        #echo "Config in Place"
        rhc app show $LAB2_APP_NAME &> /dev/null 
        if [[ $? -eq 0 ]]; then 
            echo "Completion Code" ${bold}Timeout${normal} 
        else
            echo -n "It looks like you are still haveing a problem. " 
            echo "We do not see the ${bold}$LAB2_APP_NAME${normal} created on VM."
            echo "Try looking at ${bold}/var/log/openshift/broker/production.log${normal} for clues to what is broken."
            if [[ $1 == "hint" ]]; then
                echo -n "Hint: "
                echo "https://access.redhat.com/documentation/en-US/OpenShift_Enterprise/2/html/Administration_Guide/Component_Timeout_Value_Locations.html"
            fi
        fi
    fi
}
function Lab2Reset(){
    grep sleep $LAB2_CONFIG_FILE &> /dev/null
    if [[ $? -eq 0 ]]; then
        sudo sed -i 's/sleep 250//' /var/lib/openshift/.cartridge_repository/redhat-php/0.0.15/bin/install
        sudo service ruby193-mcollective restart &> /dev/null 
    fi
    echo "The Lab is not currently broken."
}
LAB3_APP_NAME=bflab3
function Lab3Break(){
    rhc app show $LAB3_APP_NAME &> /dev/null
    if [[ $? -eq 0 ]]; then
        echo "Lab is alreayd Broken."
    else    
        echo "Setting up Break Fix Lab3"
        rhc app create $LAB3_APP_NAME python-2.7 --no-git --no-dns
        sleep 1
        rhc ssh $LAB3_APP_NAME "dd if=/dev/zero of=/tmp/data_file bs=2048" &> /dev/null
        echo 
        echo "There is now an issue with the $LAB3_APP_NAME application."
        echo -n "Run ${bold}rhc app ssh $LAB3_APP_NAME ${normal} to see the issue. "
        echo "The 'Check' script will check to see if this app issue is corrected. "
    fi
}
function Lab3Check(){
    echo "LAB3 Check"
    rhc app show $LAB3_APP_NAME &> /dev/null
    if [[ $? -eq 0 ]]; then
        rhc ssh $LAB3_APP_NAME "quota" &> /dev/null
        if [[ $? -eq 0 ]]; then
            echo "Completion Code" ${bold}Quota${normal} 
        else
            echo -n "It looks like you are still haveing a problem. " 
            echo "Try looking at what is going on with the gear using ${bold}rhc ssh $LAB3_APP_NAME ${normal}."
        fi 
    else
        echo "Please setup the Lab with the 'Break' command."   
    fi 
}
function Lab3Reset(){
    rhc app show $LAB3_APP_NAME &> /dev/null
    if [[ $? -eq 0 ]]; then
        rhc app delete $LAB3_APP_NAME --confirm &> /dev/null
    fi
    echo "The Lab is not currently broken."
}

if [[ -n $1 ]]; then
    if [[ -n $2 ]]; then 
        if [[ $1 == "Lab1" ]] && [[ $2 == "Break" ]]; then
             Lab1Break
        fi
        if [[ $1 == "Lab2" ]] && [[ $2 == "Break" ]]; then
             Lab2Break
        fi
        if [[ $1 == "Lab3" ]] && [[ $2 == "Break" ]]; then
             Lab3Break
        fi
        if [[ $1 == "Lab1" ]] && [[ $2 == "Check" ]]; then
             Lab1Check
        fi
        if [[ $1 == "Lab2" ]] && [[ $2 == "Check" ]]; then
             if [[ $3 == "hint" ]]; then 
                 Lab2Check "hint" 
             else 
                 Lab2Check 
             fi 
        fi
        if [[ $1 == "Lab3" ]] && [[ $2 == "Check" ]]; then
             Lab3Check
        fi
        if [[ $1 == "Lab1" ]] && [[ $2 == "Reset" ]]; then
             Lab1Reset
        fi
        if [[ $1 == "Lab2" ]] && [[ $2 == "Reset" ]]; then
             Lab2Reset
        fi
        if [[ $1 == "Lab3" ]] && [[ $2 == "Reset" ]]; then
             Lab3Reset
        fi
    else
        echo "You must supply a Lab Command"
        usage
    fi 
else
    echo "You must first supply a Lab"
    usage
fi 

