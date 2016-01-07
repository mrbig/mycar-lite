-- check if automatic signaling should be turned on
-- pos position of the steering wheel between -90 and 90
function autoSignal(pos)
    if (not signal.auto) then return end

    if (-1 * pos < signal.boundaries[1]) then
        signal.enabled[1] = true
        signal.enabled[2] = false
        startSignal()
    elseif (-1 * pos > signal.boundaries[2]) then
        signal.enabled[1] = false
        signal.enabled[2] = true
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

    tmr.alarm(signal.tmr, 400, 1, cbSignal)
    cbSignal() -- start inmediately
end

-- stop all turn signals
function stopSignal()
    tmr.stop(signal.tmr)
    signal.running = false
    signal.state = 0
    for i = 1,2 do
        signal.enabled[i] = false
        gpio.write(signal.pins[i], gpio.HIGH)
        for k,c in ipairs(server.conn) do
            c:send("signal"..i.." 0\n")
        end
    end
end

-- signal timer callback
function cbSignal()
    for i=1,2 do
        local on;
        if (signal.enabled[i]) then
            on = 1-signal.state
        else
            on = gpio.HIGH
        end
        gpio.write(signal.pins[i], on)
        for k,c in ipairs(server.conn) do
            c:send("signal"..i.." "..(1-on).."\n")
        end
    end
    signal.state = 1-signal.state
end