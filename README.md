# 🚗 Team1 PiRacer Repository
- **This repository is SEA:ME team1's repository.**
- **Project : [SEA:ME - DES](https://github.com/SEA-ME/SEA-ME-course-book/tree/main/DistributedEmbeddedSystems)**
- **member : [Kevin Choi](https://github.com/cmh0728) , [James Jang](https://github.com/jjangddung)**
## System architecture
 - **Raspberry pi 4b**
 - **Arduino uno**
 - **python venv**
 - **Waveshare 7.9inch LCD-DSI**
 - **Raspberry pi OS 64 bit**
 - **Qt**

## 🛠️ Log Update 

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

- **22.07.25**  
  ‣ Kernel update  for using DSI -> FAIL
  ‣ reinstall Raspberry pi OS
---

## 📋 To do
  ‣ Qt Design for Head Unit  
  ‣ Control with CPP 

---

## 🌐 Environment

- Ubuntu 22.04 LTS Desktop  
- Raspberry Pi 4  
- Arduino UNO  

---

## ▶️ DEMO 

### ✅ Software Setting
If you want to run our code, you have to do this.

```bash
# config file setting for Raspbery pi
cd ~/PiRacer_team1/src/board
nano config.txt # copy this file
sudo nano /boot/firmware/config.txt #paste to here

# to set pip install 
cd PiRacer_team1
python3 -m venv venv
source venv/bin/activate
pip install piracer-py
pip install flask
pip install -r requirements.txt
```
### Run code
If you want to run our code, try this.
```bash
cd PiRacer_team1
source venv/bin/activate 
python3 launch.py
```

### 🎮 Remote Control

- **Control steering**: Left stick  
- **Throttle**: Press `A` → Move

```bash
cd src/control  
python3 remote_control.py
```

### 🖥️ Display Interface  
- **V,I,P,IP_address**

```bash
cd display
sudo nano install_display_service.sh
```

```bash
******* CHANGE PATH *******
```

### 🔧 CAN Communication Test

```Arduino upload
src/Arduino/can_speed.ino

```bash
cd src/cluster
python3 can_rpm.py



