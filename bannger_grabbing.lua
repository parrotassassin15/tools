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

-- Function to grab banners with protocol-specific probes
local function grab_banner(ip, port)
    local sock = socket.tcp()
    sock:settimeout(5) -- Increased timeout

    local success, err = sock:connect(ip, port)
    if not success then
        print(string.format("[%s:%d] Connection failed: %s", ip, port, err))
        return nil
    end

    -- Send protocol-specific probes
    local probes = {
        [22] = "\r\n",  -- SSH (usually responds with version info)
        [23] = "\r\n",  -- Telnet
        [80] = "GET / HTTP/1.1\r\nHost: example.com\r\n\r\n", -- HTTP
        [443] = "GET / HTTP/1.1\r\nHost: example.com\r\n\r\n", -- HTTPS (though SSL handshake is needed)
        [5900] = "\r\n",  -- VNC
        [9100] = "\r\n",  -- JetDirect printer
        [8003] = "\r\n",  -- Custom service
        [111] = "\r\n",  -- RPC
        [904] = "\r\n",  -- Misc ports
        [1010] = "\r\n",
        [9000] = "\r\n",
        [623] = "\r\n",
    }

    -- Send probe if available
    if probes[port] then
        sock:send(probes[port])
    else
        sock:send("\r\n")  -- Default probe
    end

    -- Receive banner
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
