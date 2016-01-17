-- incializalas
function init()
   servo.step = (servo.max-servo.min)/180

   -- servo setup
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
   gpio.write(lights.pin, gpio.HIGH);

   initServer()
end

-- server inicializalasa
function initServer()
    server.instance = net.createServer(net.TCP, 28800)
    server.instance:listen(server.port, function(conn)
        print("RoboRemo connected")

        turn(0)

        conn:on("receive", receiveData)
        
        conn:on("disconnection", function(c)
            print("RoboRemo disconnected")
            stop()
        end)
    end)
end

-- parancsok ertelmezese
function parseCmd(str, conn)
    local start, finish, cmd, value = string.find(str, "(%w+) (-?[.%d]+)")

    if (start ~= 1 or finish < string.len(str)-1) then
        print ("Invalid input: "..str)
        return
    end

    value = tonumber(value)

    local ret = nil

    if (cmd == "turn")      then
        turn(value * -8.9) -- turn ertek -10 es + 10 kozott jon
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

-- uzenet jott
-- az inputot mindaddig osszerakjuk, amig egy sortorest nem talalunk
-- ezutan a sortores elotti stringet atadjuk az execCmd-nek
-- ha tobb enter is jott, akkor azokat egyesevel feldolgozzuk
function receiveData(conn, data)
    server.buff = server.buff .. data

    local a, b = string.find(server.buff, "\n", 1, true)
    while a do 
        parseCmd( string.sub(server.buff, 1, a-1), conn )
        server.buff = string.sub(server.buff, a+1, string.len(server.buff))
        a, b = string.find(server.buff, "\n", 1, true)
    end
    
end

-- Mozgas adott poziciora
-- pos: a kivant pozicio -90 es +90 fok kozott
function turn(pos) 
    if (pos < -90 or pos > 90) then
        return
    end

    local target = math.floor((pos + 90) * servo.step + servo.min)
    
    pwm.setduty(servo.pin, target)
    
end

-- sebesseg beallitasa
-- speed: a kivant sebesseg 0 es 100 kozott
function setSpeed(speed)
    if (speed > 100 or speed < 0) then
        return
    end

    --utana a bekapcsolasok
    local val = math.floor(1023 / 100 * math.abs(speed))
    pwm.setduty(motor.pwm, val)
    
end

-- hatramenet / eloremenet kozotti kapcsolas
-- reverse: ha 1, akkor hatramenetbe kapcsolunk
function setReverse(reverse)
    pwm.setduty(motor.pwm, 0)
    if (reverse == 1) then
        motor.pwm = motor.pinB
    else
        motor.pwm = motor.pinA
    end
end

-- vilagitas ki/be kapcsolasa
-- elso hivasra be, masodikra kikapcsolja a vilagitast
function toggleLights(value)
    lights.on = 1 - lights.on
    
    gpio.write(lights.pin, 1 - lights.on)

    return "lights "..lights.on.."\n"
end

-- mindent leallit
function stop()
    turn(0)
    pwm.stop(servo.pin)
    pwm.setduty(motor.pinA, 0)
    pwm.setduty(motor.pinB, 0)
end

init()
