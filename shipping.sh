#!/bin/bash

source ./common.sh
app_name=shipping
check_root
app_setup
java_setup
systemd_setup

dnf install mysql -y  &>>$logs_file
validate $? "installing mysql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'
if [ $? -ne 0 ]; then

   mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$logs_file
   mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$logs_file
   mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$logs_file
   validate $? "Loaded data into mysql"
else
   echo -e "Data is already loaded, $Y Skipping $N"
fi   

app_restart
print_total_time