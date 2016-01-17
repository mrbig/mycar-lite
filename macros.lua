-- greeting after connection
function onConnect()
    signal.enabled[1] = true;
    signal.enabled[2] = true;
    signal.auto = false;
    startSignal()

    turn(servo.center)
    
    tmr.alarm(macro.tmr, signal.interval*3.5, 0, function() 
        stopSignal();
        signal.enabled[1] = false;
        signal.enabled[2] = false;
        signal.auto = true;
    end);
end

-- goodby after disconnect
function onDisconnect()
    signal.enabled[1] = true;
    signal.enabled[2] = true;
    signal.auto = false;
    startSignal()

    turn(servo.center)
    
    tmr.alarm(macro.tmr, signal.interval*1.5, 0, function() 
        stopSignal();
        signal.enabled[1] = false;
        signal.enabled[2] = false;
        signal.auto = true;

        stop()
        
    end);
end

--wifi connection has been set up
function onWifiConnected()

    signal.enabled[1] = true;
    signal.enabled[2] = true;
    signal.auto = false;
    startSignal()

    tmr.alarm(macro.tmr, signal.interval, 0, function() 
        stopSignal();
        signal.enabled[1] = false;
        signal.enabled[2] = false;
        signal.auto = true;

        toggleLights()

        tmr.alarm(macro.tmr, signal.interval, 0, function() 
            toggleLights()
        end);
        
    end);
end

-- stops everything
function stop()
    -- Turn off servo
    pwm.stop(servo.pin)
    gpio.write(servo.enable, gpio.HIGH)

    -- Turn off motor
    pwm.setduty(motor.pinA, 0)
    pwm.setduty(motor.pinB, 0)
end
