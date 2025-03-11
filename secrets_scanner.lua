local lfs = require("lfs")

-- Define patterns for common secrets
local secret_patterns = {
    "api[_-]?key[%s=:]+[%S]+",
    "secret[%s=:]+[%S]+",
    "password[%s=:]+[%S]+",
    "pass[%s=:]+[%S]+",
    "token[%s=:]+[%S]+",
    "auth[%s=:]+[%S]+",
    "bearer[%s=:]+[%S]+",
    "client[_-]?id[%s=:]+[%S]+",
    "client[_-]?secret[%s=:]+[%S]+",
    "access[_-]?key[%s=:]+[%S]+"
}

-- Function to scan a file for secrets
local function scan_file(filepath)
    local file = io.open(filepath, "r")
    if not file then return end
    
    print("Scanning file: " .. filepath)
    for line in file:lines() do
        for _, pattern in ipairs(secret_patterns) do
            if string.match(line, pattern) then
                print("[POTENTIAL SECRET] " .. filepath .. " -> " .. line)
            end
        end
    end
    file:close()
end

-- Function to recursively scan a directory
local function scan_directory(directory)
    for file in lfs.dir(directory) do
        if file ~= "." and file ~= ".." then
            local full_path = directory .. "/" .. file
            local attr = lfs.attributes(full_path)
            if attr.mode == "file" then
                scan_file(full_path)
            elseif attr.mode == "directory" then
                scan_directory(full_path)
            end
        end
    end
end

-- Set the target directory (local system root or specific path)
local target_directory = "."  -- Change this if needed
scan_directory(target_directory)
