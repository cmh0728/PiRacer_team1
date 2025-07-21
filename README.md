# 🚗 PiRacer Team1 Repository

## 🛠️ Update Log

- **15.07.25**  
  ‣ Assembly Pi-car

- **16.07.25**  
  ‣ Install Ubuntu 22.04 LTS Server

- **17.07.25**  
  ‣ Control with Remote Controller

- **18.07.25**  
  ‣ Connect CAN communication (Arduino ↔ Raspberry Pi)  
  ‣ Upgrade Ubuntu Server → Ubuntu 22.04 LTS Desktop

---

## 🌐 Environment

- Ubuntu 22.04 LTS Desktop  
- Raspberry Pi 4  
- Arduino UNO  

---

## ▶️ How to Use

### ✅ Setting

```bash
cd PiRacer_team1
python3 -m venv venv
source venv/bin/activate
pip install piracer-py
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



