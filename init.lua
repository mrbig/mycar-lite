gpio.mode(4, gpio.OUTPUT);
gpio.write(4, gpio.HIGH);
dofile("config.lua")
dofile("signal.lc")
dofile("macros.lua")
dofile("mycar.lc")

