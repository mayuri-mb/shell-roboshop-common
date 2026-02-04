#!/bin/bash

userid=$(id -u)
logs_folder="/var/log/shell-roboshop-common"
logs_file="$logs_folder/$0.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
start_time=$(date +%s)
mkdir -p $logs_folder

echo "$(date "+%y-%m-%d %H:%M:%S") | script started executing at: $(date)" | tee -a $logs_file

check_root () {
    if [ $userid -ne 0 ]; then
       echo -e "$R Please run this script with root access $N" | tee -a $logs_file
       exit 1
    fi
}

validate() {
    if [ $1 -ne 0 ]; then
     echo -e "$(date "+%y-%m-%d %H:%M:%S") | $2 $R failed $N"  | tee -a $logs_file
       exit 1
    else
       echo -e "$(date "+%y-%m-%d %H:%M:%S") | $2 $G success $N" | tee -a $logs_file
    fi
}

print_total_time() {
    end_time=$(date +%s)
    total_time=$( $end_time - $start_time )
    echo -e "Script executed in: $G $total_time seconds $N" | tee -a $logs_file"
}