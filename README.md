# 🚗 SEA:ME-DES Team1 
**This is SEA:ME Team1's repository.**

**Project : <ins>[SEA:ME - DES](https://github.com/SEA-ME/SEA-ME-course-book/tree/main/DistributedEmbeddedSystems)</ins>**

**member : <ins>[Kevin Choi](https://github.com/cmh0728)</ins> , <ins>[James Jang](https://github.com/jjangddung)</ins>**

<!-- 목차 및 소개  -->
# Distributed embedded systems
This repository is the repository for the distributed embedded systems project of SEA:ME.

If you would like to refer to the parent project, see <ins>[Distributed embedded systems](https://github.com/SEA-ME/SEA-ME-course-book/tree/main/DistributedEmbeddedSystems)</ins>

- <ins>[PiRacer Assembly](#PiRacer-Assembly)</ins>
- <ins>[Cluster](#cluster)</ins>
- <ins>[Head Unit](#head-unit)</ins>

<!-- piracer assembly부분 -->
# PiRacer Assembly
<img width="1276" height="1218" alt="Image" src="https://github.com/user-attachments/assets/f34aab97-945f-4665-9ab7-21c01cdb7119" />

### System Architecture
<img width="761" height="504" alt="Image" src="https://github.com/user-attachments/assets/642350d7-2cb5-4ff1-9345-c6043824acd4" />

### Components
-  <ins>[PiRacer AI kit](https://www.waveshare.com/wiki/PiRacer_AI_Kit)</ins>
- Raspberry Pi 4B
- SD 64GB

### Assembly & Setting
Please refer to the following official manual for quick assembly. 

- <ins>[PiRacer Assembly manual](https://www.waveshare.com/wiki/PiRacer_Assembly_Manual)</ins>

If you want to quickly set up and test the software, please refer to the following GitHub.

- <ins>[software setting](https://github.com/twyleg/piracer_py)</ins>

### 🖥️ Show Interface  
- **V,I,P,IP_address**

```bash
cd display
sudo nano install_display_service.sh
```

```bash
******* CHANGE PATH *******
```



<!-- cluster 부분 -->
# Cluster
<img width="1276" height="397" alt="Image" src="https://github.com/user-attachments/assets/7978a139-d85e-47fb-96e7-0c468c9e55b5" />

##

<img width="1276" height="1016" alt="Image" src="https://github.com/user-attachments/assets/cab1a7c0-655e-4ef5-b601-cc5cbc3ee628" />

### Hardware components
- **Raspberry Pi 4B**
- **Arduino uno**
- **Waveshare 7.9inch LCD-DSI**
- **Speed sensor**
- **Can shield & Can hat**

### System architecture
 - **Raspberry pi OS aarch64**
 - **python venv**
 - **python 3.10.x**
 - **Qt 6.9.1**
  - **python multiprocessing**


## DEMO 

### ✅ Software Setting
If you want to run our code, you have to try this.


```bash
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
cd PiRacer_team1
source venv/bin/activate 
python3 launch.py
```
## 🎮 Remote Control

- **Steering** : Left joystick  
- **Throttle** : 

      Press `A` ->  move front
    
      Press `X` ->  move rear
## 📽️camera stream check

- connect to http::[your car ip address]:8080

## 🔗 CAN BUS Communication Test

```Arduino upload
src/Arduino/can_speed.ino

```bash
cd src/cluster
python3 can_rpm.py
```

## To automize CAN setting 
```bash
#create new service file
sudo nano /etc/systemd/system/can0.service 
```
```bash
#paste this file 
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



<!-- Head unit 부분 -->
## Head Unit
### update later

<!-- 개발 로그 및 할 일들  -->

## 🛠️ Development Log Update 

- **15.07.25**  
  ‣ Assembly Pi-car

- **16.07.25**  
  ‣ Install Ubuntu 22.04 LTS Server

- **17.07.25**  
  ‣ Control with Remote Controller

- **18.07.25**  
  ‣ Connect CAN communication (Arduino ↔ Raspberry Pi)  
  ‣ Upgrade Ubuntu Server → Ubuntu 22.04 LTS Desktop


- **21.07.25**  
  ‣ CAN communication with Speed Sensor   

- **25.07.25**  
  ‣ Complete UI  


- **28.07.25**  
  ‣ UI connect ↔ CAN data  

- **30.07.25**  
  ‣ System Architecture 1.0  


- **01.08.25**  
  ‣ update Arduino code  

## 📋 Future To do
  ‣ ~~Qt Design for Cluster~~  
  ‣ ~~Control with CPP~~  
  ‣ update System Architecture



## check the battery voltage
``` 
#bash
sudo apt install i2c-tools
i2cget -y 1 0x41 0x02 w
```

