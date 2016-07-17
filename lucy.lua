#!/usr/bin/env luajit
local ffi = require 'ffi'
ffi.cdef[[
int read(int handle, void *buffer, int nbyte);
int write(int handle, const char *buffer, int nbyte);
void printf(const char *fmt, ...);
void (*signal(int sig, void (*func)(int)))(int);
bool isprint(int c);
]]
local locy = ffi.load("/usr/lib/liblucy.dylib")
ffi.cdef[[
void *l_ipc_create_port(const char *name);
const char *l_ipc_send_data(void *port, const char *cmd, bool should_recieve);
bool l_toggle_noncanonical_mode();
]]
local ffi_string = ffi.string
do
    local port = locy.l_ipc_create_port("com.r333d.loveboard.console.server")
    local send_data = locy.l_ipc_send_data
    local NULL = ffi.NULL
    function SEND_DATA(cmd, should_recieve)
        if should_recieve == nil then
            should_recieve = true
        end
        local result = send_data(port, cmd, should_recieve)
        if not (result == NULL) then
            return ffi_string(result)
        end
    end
    function EXIT(code)
        locy.l_toggle_noncanonical_mode()
        os.exit(code or 0)
    end
    STDIN_FD = 0
    STDOUT_FD = 1
    STDRERR_FD = 2
    SIGINT = 2
end

local C = ffi.C

is_piping = not locy.l_toggle_noncanonical_mode()

if is_piping then -- just process the inputs, no pretty shell needed
    for line in io.input():lines() do
        print(SEND_DATA(line))
    end
    return
end

function run_command()
    if command == "exit" then
        EXIT()
    end
    if #command > 0 then
        PRINT(SEND_DATA(command))
        command = ""
        PROMPT()
    else
        PROMPT(true)
    end
end

C.signal(SIGINT, function()
    PRINT("^C")
    PROMPT()
    command = ""
end)

function PRINT(str)
    C.write(STDOUT_FD, str, #str)
end

function MAGENTA_PRINT(str)
    PRINT("\x1B[1;34m")
    PRINT(str)
    PRINT("\x1B[0m")
end

function BELL()
    PRINT("\a")
end

function GREEN_PRINT(str)
    PRINT("\x1B[32m")
    PRINT(str)
    PRINT("\x1B[0m")
end

function PROMPT(no_newline)
    local p = "\x1B[1;31m".."l".."\x1B[33m".."u".."\x1B[32m".."c".."\x1B[34m".."y".."\x1B[35m".."#".."\x1B[0m "
    if no_newline then
        PRINT(p)
    else
        PRINT('\n'..p)
    end
end

command = ""
buffer = ffi.new("char[3]")
PROMPT(true)
while true do
    local count = C.read(STDIN_FD, buffer, 3)
    if count == 0 then
        return
    elseif count == 1 then
        local c = buffer[0]
        if C.isprint(c) then
            local s = string.char(c)
            PRINT(s)
            command = command..s
        end
        if c == 0x0A then --enter
            PRINT("\n")
            run_command()
        elseif c == 0x04 then -- ^D
            if #command == 0 then
                PRINT("^D\n")
                EXIT()
            else
                BELL()
            end
        elseif c == 0x08 or c == 0x7f then --backspace/delete
            if #command == 0 then
                BELL()
            else
                command = string.sub(command, 1, #command - 1)
                PRINT("\b \b")
            end
        end
    end
end

