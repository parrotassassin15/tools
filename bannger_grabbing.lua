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

-- Function to grab banners
local function grab_banner(ip, port)
    local sock = socket.tcp()
    sock:settimeout(5)  -- Increased timeout

    print(string.format("Connecting to %s:%d...", ip, port))
    local success, err = sock:connect(ip, port)
    if not success then
        print(string.format("[ERROR] Connection failed: %s", err))
        return nil
    end

    -- Allow time for server to send banner
    print(string.format("[INFO] Connected to %s:%d, waiting for response...", ip, port))
    socket.sleep(2)  -- Wait 2 seconds before trying to read

    -- Attempt to receive banner
    local banner, recv_err = sock:receive(1024)
    sock:close()

    if banner then
        print(string.format("[SUCCESS] Banner received from %s:%d -> %s", ip, port, banner))
        return banner:gsub("[\r\n]", "")  -- Clean output
    else
        print(string.format("[INFO] No banner from %s:%d, error: %s", ip, port, recv_err or "None"))
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
