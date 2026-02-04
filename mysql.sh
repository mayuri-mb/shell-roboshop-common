#!/bin/bash

source ./common.sh
app_name=mysql
check_root

dnf install mysql-server -y &>>$logs_file
validate $? "installing mysql"

systemctl enable mysqld &>> $logs_file
validate $? "enabling mysql"

systemctl start mysqld  &>> $logs_file
validate $? "starting mysql"

#get the password from user
mysql_secure_installation --set-root-pass RoboShop@1
validate $? "setup root password"

print_total_time