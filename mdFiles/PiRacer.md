# 🚗 PiRacer Assembly
### Hardware
<!-- <p align="center"> -->
<img width="434" height="414" alt="Image" src="https://github.com/user-attachments/assets/f147b15e-b7f0-4ab0-b1ad-8b48a1bc4163" />
<!-- </p> -->

### System Architecture
<!-- <p align="center"> -->
<img width="761" height="504" alt="Image" src="https://github.com/user-attachments/assets/642350d7-2cb5-4ff1-9345-c6043824acd4" />
<!-- </p> -->

### Hardware Components
-  <ins>[PiRacer AI kit](https://www.waveshare.com/wiki/PiRacer_AI_Kit)</ins>
- Raspberry Pi 4B
- SD 64GB

### Assembly & Setting
Please refer to the following official manual for quick assembly. 

- <ins>[PiRacer Assembly manual](https://www.waveshare.com/wiki/PiRacer_Assembly_Manual)</ins>

- <ins>[software setting](https://github.com/twyleg/piracer_py)</ins>

## 🎮 Check Remote Control 
you have to check your remote control key mapping
```bash
# bash

cd SEA-ME-DES/src/control

#run
python3 remote_control.py
```
 

**Steering** : Left Joystick 


**Throttle** : 

      Press `A` ->  move front
    
      Press `X` ->  move rear
      
      Press `Y` ->  parking system activate

## 📽️ Check Camera Stream 
```bash
# bash

cd SEA-ME-DES/src/camera_stream

#run
python3 camera_web.py

# connect to "http::[your car ip address]:8080"
```



## 🖥️ Show Interface  
**Voltage , Electic Current , Power , IP_address**

```bash
# bash
cd display
sudo nano install_display_service.sh

******* CHANGE PATH *******
```



