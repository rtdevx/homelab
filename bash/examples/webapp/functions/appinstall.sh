#!/usr/bin/env bash

java_configure() {

# Create folders for java app
sudo mkdir -p /opt/java
sudo chown java:java /opt/java

# Copy .jar file
sudo cp ./files/helloworld.jar /opt/java/
sudo chown java:java /opt/java/helloworld.jar
sudo chmod +x /opt/java/helloworld.jar

# Copy java.service
sudo cp ./files/java.service /etc/systemd/system/java.service

# Enable java service
sudo systemctl daemon-reload
sudo systemctl enable --now java
sudo systemctl status java

}