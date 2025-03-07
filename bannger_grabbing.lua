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

    local success, err = sock:connect(ip, port)
    if not success then
        print(string.format("[%s:%d] Connection failed: %s", ip, port, err))
        return nil
    end

    -- Allow time for the server to send a banner
    socket.sleep(1.5)  -- Wait 1.5 seconds before trying to read

    -- Attempt to receive banner
    local banner, recv_err = sock:receive(1024)
    sock:close()

    if banner then
        return banner:gsub("[\r\n]", "")  -- Clean newlines
    else
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
    print("Scanning: " .. ip)
    for _, port in ipairs(ports) do
        local banner = grab_banner(ip, port)
        if banner then
            print(string.format("[+] %s:%d -> %s", ip, port, banner))
        end
    end
end
