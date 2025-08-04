# SEA:ME-DES Team1 
This is SEA:ME-Team1's repository for distributed embedded system project of SEA:ME 

**Project : <ins>[SEA:ME - DES](https://github.com/SEA-ME/SEA-ME-course-book/tree/main/DistributedEmbeddedSystems)</ins>**

**member : <ins>[Kevin Choi](https://github.com/cmh0728)</ins> , <ins>[James Jang](https://github.com/jjangddung)</ins>**

<!-- 목차 및 소개  -->
# Distributed embedded systems

### Contents
<!-- - <ins>[Software Setting]()</ins> -->
- <ins>[PiRacer Assembly](https://github.com/cmh0728/SEA-ME-DES/blob/main/PiRacer.md)</ins>

- <ins>[Cluster](https://github.com/cmh0728/SEA-ME-DES/blob/main/Cluster.md)</ins>

- <ins>[Head Unit](https://github.com/cmh0728/SEA-ME-DES/blob/main/HeadUnit.md)</ins>


## DEMO 

### ✅ Software Setting
If you want to run our code, follow this scripts.


```bash
#bash

# config file setting for Raspbery pi
git clone https://github.com/cmh0728/PiRacer_team1.git
cd ~/PiRacer_team1/src/board
nano config.txt # copy this file
sudo nano /boot/firmware/config.txt #paste to here

# to set pip install 
cd PiRacer_team1
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Run
If you want to run our code, try this.
```bash
# bash

cd PiRacer_team1

# activate venv
source venv/bin/activate 

# Run all codes.
python3 launch.py 
```

### 🎮 Remote Control 

- **Steering** : Left joystick  
- **Throttle** : 

      Press `A` ->  move front
    
      Press `X` ->  move rear

### 📽️ Camera Stream 

- connect to http::[your car ip address]:8080

## 🔗 CAN BUS Communication Test

```bash
# bash

# Arduino upload
src/Arduino/can_speed.ino

cd src/cluster
python3 can_rpm.py
```

## To automize CAN setting 
```bash
# bash

# create new service file
sudo nano /etc/systemd/system/can0.service 
```
```bash
# paste this file 
[Unit]
Description=Setup CAN interface can0
Wants=network.target
After=network.target

[Service]
Type=oneshot
ExecStart=/sbin/ip link set can0 up type can bitrate 500000 restart-ms 100
ExecStop=/sbin/ip link set can0 down
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```
```bash
# save file & activate
sudo systemctl daemon-reload
sudo systemctl enable can0.service
```
```bash
# reboot and check 
sudo reboot
candump can0
```


## check the battery voltage
```bash
# bash
sudo apt install i2c-tools
i2cget -y 1 0x41 0x02 w
```

<!-- 개발 로그 및 할 일들  -->

## 🛠️ Development Log 
- <ins>[Development Log Update](https://github.com/cmh0728/SEA-ME-DES/blob/main/log.md)</ins>


## References


