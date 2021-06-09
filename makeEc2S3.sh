#! /usr/bin/bash

## INSTALL JQ TO EXTRACT THE INSTANCE ID
## FROM THE JSON DATA RETURNED UPON CREATING THE INSTANCE
sudo apt install jq

## CREATE THE USER DATA FILE 
touch ud.txt
echo "#! /usr/bin/bash
sudo apt update
sudo apt-get install apache2 -y
sudo service apache2 start
sudo systemctl enable apache2
echo Welcome to Saaspect from $(hostname -f) > /var/www/html/index.html" >> ud.txt


## LAUNCHING EC2 INSTANCE WITH UBUNTU LINUX AMI 
(aws ec2 run-instances --image-id ami-0c1a7f89451184c8b --count 1 --instance-type t2.micro \
--key-name EC2Tutorial2 --security-group-ids sg-xxxxxxxxxxxxxxxxx --user-data file://ud.txt)>>launchData.json

## REMOVING THE " FROM THE INSTANCE ID
INSTANCE_ID=$(jq .Instances[0].InstanceId launchData.json)
INSTANCE_ID=`sed -e 's/^"//' -e 's/"$//' <<<"$INSTANCE_ID" `

## DELETE THE USER DATA FILE AND JSON FILE
rm ud.txt
rm launchData.json

## ADDING TAG TO THE INSTANCE
aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=UbuntuInstance
aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Company,Value=Saaspect

echo ":) AWS EC2 instance created successfully"


## PINGING THE PUBLIC IP OF THE INSTANCE 
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
echo ":) Paste this public IP in brouwser: $PUBLIC_IP"
echo ":( If nothing lodes up, reload after a few minutes"


# ------------------------------------------------------------
# ------------------------------------------------------------


read -p "Enter the name of bucket you want to create (it muct be unique): " BUCKET_NAME

## CREATION OF S3 BUCKET
aws s3 mb s3://$BUCKET_NAME
aws s3 cp './makeEc2S3.sh' s3://$BUCKET_NAME 