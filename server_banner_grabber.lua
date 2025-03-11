local socket = require("socket")
local http = require("socket.http")
local ltn12 = require("ltn12")

-- Define target ports, excluding 22, 23, and 111
local ports = {80, 443, 8003, 9100, 904, 1010, 9000, 623, 5900}

-- Function to read target IPs from ip.txt
local function read_targets(filename)
    local targets = {}
    local file = io.open(filename, "r")
    if file then
        for line in file:lines() do
            table.insert(targets, line)
        end
        file:close()
    end
    return targets
end

-- Function to fetch and extract the Server header
local function fetch_server_header(host, port)
    local response_body = {}
    local url = "http://" .. host .. ":" .. port .. "/"
    local res, code, headers = http.request {
        url = url,
        method = "GET",
        sink = ltn12.sink.table(response_body)
    }
    
    if headers and headers["server"] then
        print("Host " .. host .. " Port " .. port .. " - Server: " .. headers["server"])
    else
        print("Host " .. host .. " Port " .. port .. " - No Server header found")
    end
end

-- Read target IPs
local targets = read_targets("ip.txt")

-- Iterate over each target and each port
for _, target_host in ipairs(targets) do
    for _, port in ipairs(ports) do
        fetch_server_header(target_host, port)
    end
end
