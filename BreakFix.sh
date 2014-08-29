#!/bin/bash

function usage(){
   echo "$0 Break | Check"
   echo "To start the Break Fix Exam, run the 'Break' command." 
   echo "To test / get the competion code then run the 'Check command!"
}

if [[ -n $1 ]]; then
    APP_URL=$(rhc app show training | awk '{print $3}' | head -n 1)
    if [[ $1 == "Break" ]]; then
        echo -n "The script is now breaking the application, "
        echo "once complete your application will show a 503 error in the browser. "
        echo "Your goal is to recover from this!"
        rhc ssh -a training --gears --command "jbosseap/bin/control stop" &> /dev/null
        echo "Use this script with the \"Check\" option to see if you have successfuly recovered and get a completion code"
        touch /tmp/.breakfix1
    elif [[ $1 == "Check" ]]; then
       TEST_RESULT=$(curl -ILs $APP_URL | head -n 1 | head -n 1 | awk '{print $2}')
       if [[ $TEST_RESULT  == "200" ]]; then 
           if [[ -f /tmp/.breakfix1 ]]; then
               echo "Congradulation!!"
               echo "Competion Code: CodeOnOpenShift"
           else
               echo "You must first break and then fix the application to get the completion code!"
           fi
       elif [[ $TEST_RESULT == "503" ]]; then
           echo "You have confirmed that you have broken enviornment!"
       else
           echo "Oppps ... somethings not acting line it should! Tell someone what that you got a $TEST_RESULT error!"
       fi
    elif [[ $1 == "Recover" ]]; then
        echo "You are recovering the application. If you run check following this you will not be given the completion code." 
        rhc app restart training &> /dev/null
        rm -f /tmp/.breakfix &> /dev/null
    elif [[ $1 == "LabCheck" ]]; then 
       TEST1=false
       TEST2=false
       TEST3=false
       if [[ $(sh variables-example/.test) == "PASS" ]]; then
           TEST1=true
       else
           echo "Variables TEST: FAIL"
       fi
       if [[ $(sh marker-example/.test) == "PASS" ]]; then
           TEST2=true
       else
           echo "Marker TEST: FAIL"
       fi
       if [[  $(sh cluster-example/.test) == "PASS" ]]; then 
           TEST3=true
       else
           echo "Cluster TEST: FAIL"
       fi
       if [[ TEST1 == true && TEST2 == true && TEST3 == true ]]; then
           echo "Completon Code: OpenShiftFUN!" 
       else 
           echo "Please Complete Lab Steps at $APP_URL" 
       fi 
    else
       usage
    fi 
else 
    usage
fi
