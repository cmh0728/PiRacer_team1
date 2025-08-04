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

# To setting Apt installing dependencies
git clone https://github.com/cmh0728/SEA-ME-DES.git
cd SEA-ME-DES/
bash bootstrap-apt.sh

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


<!-- 개발 로그 및 할 일들  -->

## Development Log 
- <ins>[Development Log Update](https://github.com/cmh0728/SEA-ME-DES/blob/main/log.md)</ins>


## References

update later


