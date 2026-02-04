#!/bin/bash

source ./common.sh
app_name=rabbitmq
check_root

cp $script_dir/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$logs_file
validate $? "added rabitmq repo"

dnf install rabbitmq-server -y &>>$logs_file
validate $? "installing rabbitmq"

systemctl enable rabbitmq-server &>>$logs_file
systemctl start rabbitmq-server &>>$logs_file
validate $? "enabled and started rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>>$logs_file
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>>$logs_file
validate $? "created users and given permissions" 

print_total_time