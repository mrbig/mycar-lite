# myCar lite #

NodeMCU software to be used in wifi rc cars.

This work is influenced by (RoboRemo wifi RC car project)[http://www.roboremo.com/esp8266-wifi-rc-car.html].

Features:
 - PWM motor control in both directions
 - servo steering
 - lighting control
 - automatic/manual turn signals

For remote control use the (RoboRemo application)[https://play.google.com/store/apps/details?id=com.hardcodedjoy.roboremo].

Tested on Lolin V3 board.

Required modules:
 - node
 - file
 - gpio
 - wifi
 - net
 - pwm
 - tmr
 - adc [INIT_107 should be set to ESP_INIT_DATA_ENABLE_READADC]
 - uart
