-- wifi config
wifi.setmode(wifi.STATION)
wifi.sta.config("yourssid", "yourpassword");

-- optional, but wifi is set up quicker
-- if you use static config
wifi.sta.setip({
  ip="192.168.1.81",
  netmask="255.255.255.0",
  gateway="192.168.1.254"
});
net.dns.setdnsserver("192.168.1.254");

-- server config
server = {
    port = 9876,
    instance = nil,
    buff = "",
    conn = {}
}

-- servo config
servo = {
    pin = 8,
    enable = 4,
    min = 65,
    max = 255,
    center = -10.4, -- these values have to be set to your system. This is the center of the servo in degress
    korrB = -2.7    -- this is the multiplication factor (endpoints)
}

-- motor config
motor = {
    pinA = 1,
    pinB = 2,
    reverse = 0,
    pwm = nil -- this pin is being controlled
}

-- lights config
lights = {
    pin = 6,
    on = 0
}

-- turn signal config
signal = {
    pins = {5, 7},    -- the pins used to for output
    tmr = 1,          -- timer id used for signaling
    enabled = {0, 0}, -- wich side is enabled
    state = 0,        -- how the active turns signals should be?
    running = false,  -- is signaling running
    auto = true,      -- wether auto signaling is enabled-
    boundaries = {-15, 15}, -- boundaries for signaling (grad)
    interval = 400    -- signal interval
}

-- monitor battery voltage
vccmonitor = {
    adc = 0,          -- adc used to read vcc
    tmr = 3,          -- timer used for reporting
    interval = 3000   -- report interval
}

-- macro config
macro = {
    tmr = 2
}
