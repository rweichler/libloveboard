#!/usr/bin/env luajit

KEY = {}
KEY[1] = {}
KEY[2] = {}
KEY[3] = {}

--enter
KEY[1][0x0A] = function()
    PRINT("\n")
    run_command()
end
--ctrl-D
KEY[1][0x04] = function()
    if #command == 0 then
        PRINT("^D\n")
        EXIT()
    else
        BELL()
    end
end
--backspace
KEY[1][0x08] = function()
    if #command == 0 then
        BELL()
    else
        command = string.sub(command, 1, #command - 1)
        if cursor_pos then
            cursor_pos = cursor_pos - 1
        end
        BACKSPACE(1)
    end
end
--delete
KEY[1][0x7f] = KEY[1][0x08]

--up arrow
KEY[3][0x41] = function()
    if not history_idx then
        history_idx = #history
    else
        history_idx = history_idx - 1
    end
    if history_idx < 1 then
        history_idx = 1
        BELL()
        return
    end
    if command then
        if cursor_pos then
            CURSOR_RIGHT(#command + 1 - cursor_pos)
            cursor_pos = nil
        end
        BACKSPACE(#command)
    end
    command = history[history_idx]
    PRINT(command)
end

--down arrow
KEY[3][0x42] = function()
    if not history_idx then
        BELL()
        return
    end
    
    history_idx = history_idx + 1
    if cursor_pos then
        CURSOR_RIGHT(#command + 1 - cursor_pos)
        cursor_pos = nil
    end
    BACKSPACE(#command)
    if history_idx > #history then
        history_idx = nil
        command = ""
    else
        command = history[history_idx]
        PRINT(command)
    end
end

--right arrow
KEY[3][0x43] = function()
    if not cursor_pos then cursor_pos = #command + 1 end
    cursor_pos = cursor_pos + 1
    if cursor_pos > #command + 1 then
        BELL()
        cursor_pos = #command + 1
    else
        CURSOR_RIGHT(1)
    end
end

--left arrow
KEY[3][0x44] = function()
    if not cursor_pos then cursor_pos = #command + 1 end
    cursor_pos = cursor_pos - 1
    if cursor_pos < 1 then
        BELL()
        cursor_pos = 1
    else
        CURSOR_LEFT(1)
    end
end

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
    local string_ptr = ffi.typeof("char *[1]")
    function SEND_DATA(cmd, should_recieve)
        local result = nil
        if not (should_recieve == false) then
            result = ffi.new(string_ptr)
        end
        send_data(port, cmd, result) 
        if result and not (result[0] == NULL) then
            return ffi_string(result[0])
        end
    end
    function EXIT(code)
        lucy.l_toggle_noncanonical_mode()
        os.exit(code or 0)
    end
end

local C = ffi.C

STDIN_FD = 0
STDOUT_FD = 1
STDRERR_FD = 2
SIGINT = 2

is_piping = not lucy.l_toggle_noncanonical_mode()

if is_piping then -- just process the inputs, no pretty shell needed
    for line in io.input():lines() do
        print(SEND_DATA(line))
    end
    return
end

function string.trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function run_command()
    if command == "exit" then
        EXIT()
    end
    local result
    if #string.trim(command) > 0 then
        result = SEND_DATA(command)
        if result then
            PRINT(result)
        end
        table.insert(history, command)
    end
    history_idx = nil
    PROMPT(result or false)
end

C.signal(SIGINT, function()
    PRINT("^C")
    PROMPT()
end)

function PRINT(str)
    C.write(STDOUT_FD, str, #str)
end

function CURSOR_RIGHT(n)
    PRINT("\x1B["..n.."C")
end

function CURSOR_LEFT(n)
    PRINT("\x1B["..n.."D")
end

function MAGENTA_PRINT(str)
    PRINT("\x1B[1;34m")
    PRINT(str)
    PRINT("\x1B[0m")
end

function BACKSPACE(n)
    for i=1,n do
        PRINT("\b \b")
    end
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
    if newline == nil then newline = true end

    command = ""
    if newline then
        PRINT('\n')
    end
    PRINT(prompt_text)
    cursor_pos = nil
end

function PRINT_BUFFER()
    local c = buffer[0]
    if C.isprint(c) then
        local s = string.char(c)
        PRINT(s)
        if cursor_pos then
            cursor_pos = cursor_pos + 1
        end
        command = command..s
    end
end

buffer = ffi.new("char[3]")
history = {}
PROMPT(false)
while true do
    local count = C.read(STDIN_FD, buffer, 3)
    if count == 0 then return end

    if count == 1 then
        PRINT_BUFFER()
    end

    local f = KEY[count][buffer[count - 1]]
    if f then f() end
end

