-- checks the current battery voltage
function readVcc()
    local value = adc.read(vccmonitor.adc) * 6/859
    if (value > 7) then value = 0 end

    for k,c in ipairs(server.conn) do
        c:send("vcc "..value.."\n")
    end
end

-- starts the vcc monitor
function startVccMonitor()
   tmr.alarm(vccmonitor.tmr, vccmonitor.interval, 1, readVcc) 
end

-- stop vcc reporting
function stopVccMonitor()
    tmr.stop(vccmonitor.tmr)
end
