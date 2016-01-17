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
    buff = ""
}

-- servo config
servo = {
    pin = 3,
    min = 65,
    max = 255
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
    pin = 7,
    on = 0
}

-- turn signal config
signal = {
    pins = {5, 8},    -- the pins used to for output
    tmr = 1,          -- timer id used for signaling
    enabled = {0, 0}, -- wich side is enabled
    state = 0,        -- how the active turns signals should be?
    auto = true,      -- wether auto signaling is enabled-
    boundaries = {-15, 15} -- boundaries for signaling
}
