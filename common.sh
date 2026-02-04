#!/bin/bash

userid=$(id -u)
logs_folder="/var/log/shell-roboshop-common"
logs_file="$logs_folder/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
script_dir=$PWD
mongodb_host=mongodb.daws-88s.online
MYSQL_HOST=mysql.daws-88s.online

start_time=$(date +%s)
mkdir -p $logs_folder

echo "$(date "+%y-%m-%d %H:%M:%S") | script started executing at: $(date)" | tee -a $logs_file

check_root () {
    if [ $userid -ne 0 ]; then  $logs_file
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

nodejs_setup () {
    dnf module disable nodejs -y &>> $logs_file
    validate $? "disabling nodejs default module"

    dnf module enable nodejs:20 -y &>> $logs_file
    validate $? "enabling nodejs 20"

    dnf install nodejs -y &>> $logs_file
    validate $? "installing nodejs"

    npm install &>> $logs_file
    validate $? "installing dependencies"
}

java_setup() {
    dnf install maven -y &>>$logs_file
    validate $? "installing maven"

    cd /app  
    mvn clean package &>>$logs_file
    validate $? "installing and building $app_name"

    mv target/$app_name-1.0.jar $app_name.jar 
    validate $? "moving and renaming $app_name"
}

python_setup() {
    dnf install python3 gcc python3-devel -y &>>$logs_file
    validate $? "installing Python"
    
    cd /app 
    pip3 install -r requirements.txt &>>$logs_file
    validate $? "installing dependencies"
}

app_setup() {
    id roboshop &>> $logs_file
    if [ $? -ne 0 ]; then
       useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $logs_file
       validate $? "Creating system user"
    else
       echo -e "Roboshop user already exist..$Y Skipping $N"
    fi  

#Downloading the app
    mkdir -p /app 
    validate $? "creating app directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>> $logs_file
    validate $? "downloading $app_name code"

    cd /app 
    validate $? "moving to app directory"

    rm -rf /app/*  &>> $logs_file
    validate $? "Removing existing code"

    unzip /tmp/$app_name.zip &>> $logs_file
    validate $? "Unzip $app_name code"
}

systemd_setup() {
    cp $script_dir/$app_name.service /etc/systemd/system/$app_name.service   &>> $logs_file
    validate $? "Created systemctl service"

    systemctl daemon-reload
    validate $? "Loading the service"

    systemctl enable $app_name
    systemctl start $app_name &>> $logs_file
    validate $? "enabling and starting the service"
}

app_restart() {
systemctl restart $app_name  &>> $logs_file
validate $? "restarting $app_name" 
}

print_total_time() {
    end_time=$(date +%s)
    total_time=$(( $end_time - $start_time ))
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") | Script executed in: $G$total_time seconds$N" | tee -a $logs_file
}