-- incializalas
function init()
   servo.step = (servo.max-servo.min)/180

   -- servo setup
   -- we do some cheating here: frequency is set be the double than
   -- required by the servo. So we send out two signals in one period.
   -- My servo safely ignores the second pulse, and this way we get
   -- double precion on the pulse length
   pwm.setup(servo.pin, 100, (servo.max + servo.min) / 2)
   pwm.start(servo.pin)

   -- motor setup
   motor.pwm = motor.pinA
   pwm.setup(motor.pinA, 100, 0)
   pwm.setup(motor.pinB, 100, 0)
   pwm.start(motor.pinA)
   pwm.start(motor.pinB)

   -- lights setup
   gpio.mode(lights.pin, gpio.OUTPUT);
   gpio.write(lights.pin, gpio.LOW);

   -- turn signal setup
   for i=1,2 do
       gpio.mode(signal.pins[i], gpio.OUTPUT)
       gpio.write(signal.pins[i], gpio.LOW)
   end

   wifi.sta.eventMonReg(wifi.STA_GOTIP, onWifiConnected)
   wifi.sta.eventMonStart()

   initServer()

   startVccMonitor()
end

-- server initialization
function initServer()
    server.instance = net.createServer(net.TCP, 28800)
    server.instance:listen(server.port, function(conn)
        print("RoboRemo connected")

        table.insert(server.conn, conn)

        onConnect()

        -- Turn on servo
        gpio.write(servo.enable, gpio.LOW)

        conn:on("receive", receiveData)
        
        conn:on("disconnection", function(conn)
            print("RoboRemo disconnected")
            for i=table.getn(server.conn), 1, -1 do
                if (conn == server.conn[i]) then
                    table.remove(server.conn, i)
                end
            end

            onDisconnect()

        end)
    end)
end

-- parse commands
function parseCmd(str, conn)
    local start, finish, cmd, value = string.find(str, "(%w+) (-?[.%d]+)")

    if (start ~= 1 or finish < string.len(str)-1) then
        print ("Invalid input: "..str)
        return
    end

    value = tonumber(value)

    local ret = nil

    if (cmd == "turn")      then
        if (value < -8) then value = -8
        elseif (value > 8) then value = 8
        end
        turn(value * servo.korrB + servo.center) -- this value is between -10 and + 10 (sent by roboremo)
    elseif (cmd == "speed") then setSpeed(value)
    elseif (cmd == "reverse") then setReverse(value)
    elseif (cmd == "lights") then ret = toggleLights(value)
    else
        print ("Invalid command: "..cmd)
    end

    if (ret) then
        conn:send(ret)
    end
end

-- new message has been received
-- concatenate all input until a newline character has been received
-- then the string before the newline is handed to parseCmd
-- if there where multiple newlines in one data packet
-- then each of them has to be handled
function receiveData(conn, data)
    server.buff = server.buff .. data

    local a, b = string.find(server.buff, "\n", 1, true)
    while a do 
        parseCmd( string.sub(server.buff, 1, a-1), conn )
        server.buff = string.sub(server.buff, a+1, string.len(server.buff))
        a, b = string.find(server.buff, "\n", 1, true)
    end
    
end

-- Move servo to a given position
-- pos: the requested servo position between -90 and 90 degrees
function turn(pos) 
    if (pos < -90 or pos > 90) then
        return
    end

    local target = math.floor((pos + 90) * servo.step + servo.min)
    
    pwm.setduty(servo.pin, target)

    autoSignal(pos)
    
end

-- set the speed
-- speed: the desired speed between 0 and 100
function setSpeed(speed)
    if (speed > 100) then
        speed = 100
    elseif (speed < 10) then
        speed = 0 -- too low values would just stress the motor, but won't be able to turn it
    end

    --utana a bekapcsolasok
    local val = math.floor(1023 / 100 * math.abs(speed))
    pwm.setduty(motor.pwm, val)
    
end

-- switch between forward and reverse
-- reverse: if true then we will go reversed
function setReverse(reverse)
    pwm.setduty(motor.pwm, 0)
    if (reverse == 1) then
        motor.pwm = motor.pinB
    else
        motor.pwm = motor.pinA
    end
end

-- turn the lighting on/off
-- first call turn on the lighting, the second turns it off
function toggleLights(value)
    lights.on = 1 - lights.on
    
    gpio.write(lights.pin, lights.on)

    return "lights "..lights.on.."\n"
end


init()
