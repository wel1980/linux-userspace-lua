local sys = require("sys_ops")

local function print_help()
    print("Commands: ls, cd, cat, mkdir, mount, umount, pwd, help, exit")
end

local function cat(path)
    if not path then
        print("usage: cat <file>")
        return
    end
    local f = io.open(path, "r")
    if not f then
        print("cat: " .. path .. ": No such file")
        return
    end
    for line in f:lines() do
        print(line)
    end
    f:close()
end

local function ls(path)
    path = path or "."
    local files, err = sys.readdir(path)
    if not files then
        print("ls: " .. (err or "error"))
        return
    end
    table.sort(files)
    for _, name in ipairs(files) do
        if name ~= "." and name ~= ".." then
            local stat_info = sys.stat(path .. "/" .. name)
            if stat_info and stat_info.isdir then
                io.write(name .. "/  ")
            else
                io.write(name .. "  ")
            end
        end
    end
    print()
end

print("--- ULTIMATE LINUX SHELL (Lua Edition) ---")
print_help()

while true do
    local cwd = sys.getcwd() or "/"
    io.write("[" .. cwd .. "] # ")
    io.flush()

    local line = io.read()
    if not line then break end

    line = line:match("^%s*(.-)%s*$")  -- trim whitespace
    if line == "" then goto continue end

    local args = {}
    for word in line:gmatch("%S+") do
        table.insert(args, word)
    end
    local cmd = args[1]

    if cmd == "ls" then
        ls(args[2])

    elseif cmd == "cd" then
        local target = args[2] or "/"
        local result = sys.chdir(target)
        if result ~= 0 then
            print("cd: " .. sys.strerror(result))
        end

    elseif cmd == "cat" then
        cat(args[2])

    elseif cmd == "mkdir" then
        local path = args[2]
        if not path then
            print("usage: mkdir <path>")
        else
            local result = sys.mkdir(path, 493)  -- 0755 octal = 493 decimal
            if result ~= 0 then
                print("mkdir: cannot create '" .. path .. "' (" .. sys.strerror(result) .. ")")
            end
        end

    elseif cmd == "mount" then
        local source = args[2]
        local target = args[3]
        local fstype = args[4] or "ext4"
        if not source or not target then
            print("usage: mount <source> <target> [fstype]")
        else
            local result = sys.mount(source, target, fstype)
            if result == 0 then
                print("Mount " .. source .. " -> " .. target .. ": Success")
            else
                print("Mount " .. source .. " -> " .. target .. ": Error " .. result .. " (" .. sys.strerror(result) .. ")")
            end
        end

    elseif cmd == "umount" then
        local target = args[2]
        if not target then
            print("usage: umount <target>")
        else
            local result = sys.umount(target)
            if result == 0 then
                print("Unmount " .. target .. ": Success")
            else
                print("Unmount " .. target .. ": Error " .. result .. " (" .. sys.strerror(result) .. ")")
            end
        end

    elseif cmd == "pwd" then
        print(sys.getcwd() or "unknown")

    elseif cmd == "help" then
        print_help()

    elseif cmd == "exit" then
        break

    else
        print("Unknown command: " .. cmd)
    end

    ::continue::
end

print("Goodbye!")
