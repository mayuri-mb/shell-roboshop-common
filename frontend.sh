#!/bin/bash

source ./common.sh
app_name=frontend

check_root

dnf module disable nginx -y  &>>$logs_file
dnf module enable nginx:1.24 -y &>>$logs_file
dnf install nginx -y  &>>$logs_file
validate $? "Installing nginx"

systemctl enable nginx  &>>$logs_file
systemctl start nginx  
validate $? "enabled and started nginx"

rm -rf /usr/share/nginx/html/*   &>>$logs_file
validate $? "Remove existing data"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip  &>>$logs_file
cd /usr/share/nginx/html  &>>$logs_file
unzip /tmp/frontend.zip  &>>$logs_file
validate $? "downloaded and unzipped frontend"

rm -rf /etc/nginx/nginx.conf

cp $script_dir/nginx.conf /etc/nginx/nginx.conf  &>>$logs_file
validate $? "copied nginx conf file"

systemctl restart nginx &>>$logs_file
validate $? "restarting nginx"

print_total_time