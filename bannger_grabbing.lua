local socket = require("socket")

-- Define the list of target ports
local ports = {22, 80, 111, 443, 8003, 9100, 23, 904, 1010, 9000, 623, 5900}

-- Read IPs from file
local function read_ips(filename)
    local ips = {}
    local file = io.open(filename, "r")
    if not file then
        print("Error: Could not open " .. filename)
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

    print(string.format("Connecting to %s:%d...", ip, port))
    local success, err = sock:connect(ip, port)
    if not success then
        print(string.format("[ERROR] Connection failed: %s", err))
        return nil
    end

    -- Wait 2.5 seconds before reading (since we saw Netcat takes ~2.1s)
    print(string.format("[INFO] Connected to %s:%d, waiting for banner...", ip, port))
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
        print(string.format("[SUCCESS] Banner received from %s:%d -> %s", ip, port, banner))
        return banner:gsub("[\r\n]", "")
    else
        print(string.format("[INFO] No banner from %s:%d", ip, port))
        return "No response"
    end
end

-- Main execution
local ips = read_ips("ip.txt")
if #ips == 0 then
    print("No IPs found in ip.txt")
    return
end

for _, ip in ipairs(ips) do
    print("\n=============================")
    print("Scanning: " .. ip)
    for _, port in ipairs(ports) do
        grab_banner(ip, port)
    end
end
