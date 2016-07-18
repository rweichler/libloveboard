#!/usr/bin/env luajit
local ffi = require 'ffi'
ffi.cdef[[
int read(int handle, void *buffer, int nbyte);
int write(int handle, const char *buffer, int nbyte);
void printf(const char *fmt, ...);
void (*signal(int sig, void (*func)(int)))(int);
bool isprint(int c);
]]
local lucy = ffi.load("/usr/lib/liblucy.dylib")
ffi.cdef[[
void *l_ipc_create_port(const char *name);
void l_ipc_send_data(void *port, const char *cmd, char **result);
bool l_toggle_noncanonical_mode();
]]
local ffi_string = ffi.string
do
    local port = lucy.l_ipc_create_port("com.r333d.loveboard.console.server")
    local send_data = lucy.l_ipc_send_data
    local NULL = ffi.NULL
    function SEND_DATA(cmd, should_recieve)
        if should_recieve == nil then
            should_recieve = true
        end
        local result = should_recieve and ffi.new("char *[1]") or nil
        send_data(port, cmd, result) 
        if result and not (result[0] == NULL) then
            return ffi_string(result[0])
        end
    end
    function EXIT(code)
        lucy.l_toggle_noncanonical_mode()
        os.exit(code or 0)
    end
    STDIN_FD = 0
    STDOUT_FD = 1
    STDRERR_FD = 2
    SIGINT = 2
end

local C = ffi.C

is_piping = not lucy.l_toggle_noncanonical_mode()

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
    local result
    if #command > 0 then
        result = SEND_DATA(command) -- this errors
        if result then
            PRINT(result)
        end
    end
    PROMPT(result or false)
end

C.signal(SIGINT, function()
    PRINT("^C")
    PROMPT()
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

prompt_text = "\x1B[1;31m".."l".."\x1B[33m".."u".."\x1B[32m".."c".."\x1B[34m".."y".."\x1B[35m".."#".."\x1B[0m "
function PROMPT(newline)
    command = ""
    if newline == false then
        PRINT('\n')
    end
    PRINT(prompt_text)
end

buffer = ffi.new("char[3]")
PROMPT(false)
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

