# SEA:ME-DES Team1 
This is SEA:ME-Team1's repository for distributed embedded system project of SEA:ME 

**Project : <ins>[SEA:ME - DES](https://github.com/SEA-ME/SEA-ME-course-book/tree/main/DistributedEmbeddedSystems)</ins>**

**member : <ins>[Kevin Choi](https://github.com/cmh0728)</ins> , <ins>[James Jang](https://github.com/jjangddung)</ins>**

<!-- 목차 및 소개  -->
# Distributed embedded systems

### Contents
<!-- - <ins>[Software Setting]()</ins> -->
- <ins>[PiRacer Assembly](https://github.com/cmh0728/SEA-ME-DES/blob/main/mdFiles/PiRacer.md)</ins>

- <ins>[Cluster](https://github.com/cmh0728/SEA-ME-DES/blob/main/mdFiles/Cluster.md)</ins>

- <ins>[Head Unit](https://github.com/cmh0728/SEA-ME-DES/blob/main/mdFiles/HeadUnit.md)</ins>


## DEMO 

### ✅ Software Setting
If you want to run our code, follow this scripts.


```bash
#bash

# config file setting for Raspbery pi
git clone https://github.com/cmh0728/SEA-ME-DES.git

cd ~/SEA-ME-DES//src/board

# copy this file
nano config.txt 

#paste to here and save
sudo nano /boot/firmware/config.txt 

# Interface option --> activate I2C, Camera, DSI
sudo raspi-config

sudo reboot

# To setting Apt installing dependencies
cd SEA-ME-DES/

bash bootstrap-apt.sh

# to set pip install 
cd SEA-ME-DES/

python3 -m venv venv

source venv/bin/activate

pip install -r requirements.txt
```

## Run
```bash
# bash

cd SEA-ME-DES/

# activate venv
source venv/bin/activate 

# Run all codes.
python3 launch.py 
```

### 🎮 Remote Control 
you have to check your remote control key mapping 

- **Steering** : Left joystick  
- **Throttle** : 

      Press `A` ->  move front
    
      Press `X` ->  move rear
      
      Press `Y` ->  parking system activate

### 📽️ Camera Stream 

- connect to http::[your car ip address]:8080


<!-- 개발 로그 및 할 일들  -->

## Development Log 
- <ins>[Development Log Update](https://github.com/cmh0728/SEA-ME-DES/blob/main/mdFiles/log.md)</ins>


