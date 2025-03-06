local socket = require("socket")

-- Function to check TTL value using ping
function get_ttl(ip)
    local ping_cmd = "ping -c 1 -W 1 " .. ip .. " 2>/dev/null | grep ttl= | awk -F'ttl=' '{print $2}' | awk '{print $1}'"
    local handle = io.popen(ping_cmd)
    local result = handle:read("*a")
    handle:close()

    result = tonumber(result)
    if result then
        if result >= 128 then
            return "Windows (TTL ~128)"
        elseif result >= 64 then
            return "Linux/MacOS (TTL ~64)"
        elseif result >= 255 then
            return "Cisco/Networking Device (TTL ~255)"
        else
            return "Unknown OS (TTL value: " .. result .. ")"
        end
    else
        return "TTL detection failed"
    end
end

-- Function to grab service banners from common ports
function grab_banner(ip, port)
    local sock = socket.tcp()
    sock:settimeout(2)
    
    local success, err = sock:connect(ip, port)
    if success then
        sock:send("HEAD / HTTP/1.1\r\n\r\n")  -- Basic request
        local banner = sock:receive("*l")
        sock:close()
        return banner or "No banner received"
    else
        return "Port closed or unreachable"
    end
end

-- Function to detect OS based on banners
function detect_os_from_banner(banner)
    if banner:match("Microsoft") then
        return "Windows Server"
    elseif banner:match("OpenSSH") then
        return "Linux-based OS (OpenSSH detected)"
    elseif banner:match("Apache") then
        return "Linux-based OS (Apache Web Server)"
    elseif banner:match("nginx") then
        return "Linux-based OS (nginx Web Server)"
    else
        return "Unknown OS (banner: " .. banner .. ")"
    end
end

-- Main function
function detect_os(ip)
    print("Scanning: " .. ip .. "\n")
    
    -- TTL-based detection
    local ttl_result = get_ttl(ip)
    print("[+] TTL-based OS detection: " .. ttl_result)
    
    -- Port banner detection
    local ports = {22, 80, 443, 3389}
    for _, port in ipairs(ports) do
        print("[*] Checking port " .. port .. "...")
        local banner = grab_banner(ip, port)
        print("    - Banner: " .. banner)

        if banner ~= "Port closed or unreachable" then
            local os_guess = detect_os_from_banner(banner)
            print("    - OS Guess: " .. os_guess)
        end
    end
end

-- Get target from command line
if #arg < 1 then
    print("Usage: lua os_detect.lua <target_ip>")
    os.exit(1)
end

detect_os(arg[1])

