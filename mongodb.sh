#!/bin/bash

source ./common.sh

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "copying mongo repo"

dnf install mongodb-org -y &>>$logs_file
validate $? "Installing mongodb server"

systemctl enable mongod &>>$logs_file
validate $? "Enable mongodb"

systemctl start mongod &>>$logs_file
validate $? "Start mongodb"
 
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf 
validate $? "Allowing remote connections"

systemctl restart mongod
validate $? "Restarted mongodb"

print_total_time
