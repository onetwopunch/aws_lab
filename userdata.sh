#!/bin/bash

# Install Golang
sudo yum install -y git
export ARTIFACT=go1.11.5.linux-amd64.tar.gz
curl -o /tmp/$ARTIFACT "https://dl.google.com/go/$ARTIFACT"
tar -C /usr/local -xzf /tmp/$ARTIFACT
export GOPATH=/opt
export PATH=/usr/local/go/bin:$PATH

# Install our server
go get github.com/onetwopunch/s3_ip_server

# Create a systemd service to get it to run in the background
cat << 'SVC' > /etc/systemd/system/lab.service
[Unit]
Description=Distributed Password Guessing Scenario
After=network.target

[Service]
Type=simple
User=ec2-user
ExecStart=/opt/bin/s3_ip_server
Restart=on-failure
Environment=PATH=$PATH:/usr/local/go/bin
Environment=GOPATH=/opt

## EDIT THESE ##
Environment=AWS_REGION=${region}
Environment=AWS_BUCKET=${bucket}
Environment=AWS_OBJECT=${object}
################

[Install]
WantedBy=multi-user.target

SVC

systemctl daemon-reload
systemctl start lab
