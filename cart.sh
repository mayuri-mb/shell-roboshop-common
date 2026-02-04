#!/bin/bash

source ./common.sh
check_root
app_name=cart

dnf module disable redis -y &>> $logs_file
dnf module enable redis:7 -y &>> $logs_file
validate $? "enabling redis:7"

dnf install redis -y &>> $logs_file
validate $? "installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
validate $? "Allowing remote connections"

systemctl enable redis &>> $logs_file
systemctl start redis  
validate $? "enabled and started redis"

print_total_time