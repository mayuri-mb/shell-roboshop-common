#!/bin/bash

source ./common.sh
app_name=catalogue

check_root
app_setup
nodejs_setup
systemd_setup

#Loading data into mongodb
cp $script_dir/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>> $logs_file

index=$(mongosh --host $mongodb_host --quiet -eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $index -le 0 ]; then
   mongosh --host $mongodb_host </app/db/master-data.js  &>>$logs_file
   validate $? "Loading Products"
else
   echo -e "$(date "+%y-%m-%d %H:%M:%S") |Product already loaded..$Y Skipping $N" 
fi

app_restart
print_total_time

