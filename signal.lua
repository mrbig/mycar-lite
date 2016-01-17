-- check if automatic signaling should be turned on
-- pos position of the steering wheel between -90 and 90
function autoSignal(pos)
    if (not signal.auto) then return end

    if (pos < signal.boundaries[1] + servo.center) then
        signal.enabled[1] = false
        signal.enabled[2] = true
        startSignal()
    elseif (pos > signal.boundaries[2] + servo.center) then
        signal.enabled[1] = true
        signal.enabled[2] = false
        startSignal()
    else
        stopSignal()
    end
end

-- start turn signals
-- if already started, then do nothing
function startSignal()
    if (signal.running) then return end

    signal.running = true
    signal.state = 1

    tmr.alarm(signal.tmr, signal.interval, 1, cbSignal)
    cbSignal() -- start inmediately
end

-- stop all turn signals
function stopSignal()
    tmr.stop(signal.tmr)
    signal.running = false
    signal.state = 0
    for i = 1,2 do
        signal.enabled[i] = false
        gpio.write(signal.pins[i], gpio.LOW)
    end
    for k,c in ipairs(server.conn) do
        c:send("signal1 0\nsignal2 0\n")
    end
end

-- signal timer callback
function cbSignal()
    local send = ""
    for i=1,2 do
        local on;
        if (signal.enabled[i]) then
            on = signal.state
        else
            on = gpio.LOW
        end
        gpio.write(signal.pins[i], on)
        send = send .. "signal"..i.." "..(on).."\n"
        
    end
    signal.state = 1-signal.state
    for k,c in ipairs(server.conn) do
        c:send(send)
    end
end
