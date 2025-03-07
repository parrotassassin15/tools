local socket = require("socket")

-- ANSI color codes
local colors = {
    reset = "\27[0m",
    red = "\27[31m",
    green = "\27[32m",
    blue = "\27[34m",
    yellow = "\27[33m"
}

-- Define the list of target ports
local ports = {22, 80, 111, 443, 8003, 9100, 23, 904, 1010, 9000, 623, 5900}

-- Read IPs from file
local function read_ips(filename)
    local ips = {}
    local file = io.open(filename, "r")
    if not file then
        print(colors.red .. "[ERROR] Could not open " .. filename .. colors.reset)
        return {}
    end
    for line in file:lines() do
        table.insert(ips, line)
    end
    file:close()
    return ips
end

-- Function to grab banners with improved timeout handling
local function grab_banner(ip, port)
    local sock = socket.tcp()
    sock:settimeout(5)  -- Allow 5 seconds (same as Netcat)

    print(colors.blue .. string.format("[INFO] Connecting to %s:%d...", ip, port) .. colors.reset)
    local success, err = sock:connect(ip, port)
    if not success then
        print(colors.red .. string.format("[ERROR] Connection failed: %s", err) .. colors.reset)
        return nil
    end

    -- Wait 2.5 seconds before reading (since Netcat takes ~2.1s)
    print(colors.blue .. string.format("[INFO] Connected to %s:%d, waiting for banner...", ip, port) .. colors.reset)
    socket.sleep(2.5)

    -- Read data incrementally, like Netcat
    local banner = ""
    while true do
        local chunk, recv_err = sock:receive(1)  -- Read byte-by-byte
        if not chunk then break end
        banner = banner .. chunk
    end

    sock:close()

    if banner ~= "" then
        print(colors.green .. string.format("[SUCCESS] Banner received from %s:%d -> %s", ip, port, banner) .. colors.reset)
        return banner:gsub("[\r\n]", "")
    else
        print(colors.yellow .. string.format("[WARNING] No banner received from %s:%d", ip, port) .. colors.reset)
        return "No response"
    end
end

-- Main execution
local ips = read_ips("ip.txt")
if #ips == 0 then
    print(colors.red .. "[ERROR] No IPs found in ip.txt" .. colors.reset)
    return
end

for _, ip in ipairs(ips) do
    print("\n=============================")
    print(colors.blue .. "Scanning: " .. ip .. colors.reset)
    for _, port in ipairs(ports) do
        grab_banner(ip, port)
    end
end
