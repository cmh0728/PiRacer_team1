<!-- cluster 부분 -->
# Instrument Cluster

### Cluster GUI
<!-- <p align="center"> -->
<img width="1276" height="397" alt="Image" src="https://github.com/user-attachments/assets/7978a139-d85e-47fb-96e7-0c468c9e55b5" />
<!-- </p> -->

### Hardware
<!-- <p align="center"> -->
<img width="630" height="502" alt="Image" src="https://github.com/user-attachments/assets/75017de1-eb9d-4e1a-8a69-e72a90c90cb2" />
<!-- </p> -->

### Hardware components
- **Raspberry Pi 4B**
- **Arduino uno**
- **Waveshare 7.9inch LCD-DSI**
- **Speed sensor**
- **Can shield & Can hat**

### Software architecture
 - **Raspberry pi OS aarch64**
 - **python venv**
 - **python 3.10.x**
 - **Qt 6.9.1**
  - **python multiprocessing**

### System architecture
<!-- 동민이형꺼 받아서 변경  -->
<img width="1264" height="754" alt="Image" src="https://github.com/user-attachments/assets/8711852e-1a17-4f99-919e-a4552924e7db" />


## 🔗 CAN BUS Communication Test

```bash
# bash

# Upload Arduino Ide
src/Arduino/can_speed.ino

# for can test
cd src/board
python3 can_rpm.py 

or 

candump can0
```

## To automize CAN setting 
If you want to automize CAN setting , follow down.
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


## 🔋 check the battery voltage
```bash
# bash
sudo apt install i2c-tools
i2cget -y 1 0x41 0x02 w
```
