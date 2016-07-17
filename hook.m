#define Log(format, ...) NSLog(@"LoveBoard: %@", [NSString stringWithFormat: format, ## __VA_ARGS__])
#include <substrate.h>
#include <Foundation/Foundation.h>
#include <dlfcn.h>
#include "luahack.h"
#include <CoreGraphics/CoreGraphics.h>

#define GAME_PATH "/var/mobile/LoveBoard"

// pilfered from love.cpp
static int love_preload(lua_State *L, lua_CFunction f, const char *name)
{
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "preload");
    lua_pushcfunction(L, f);
    lua_setfield(L, -2, name);
    lua_pop(L, 2);
    return 0;
}

const char *lua_preload =
"package.path = '"GAME_PATH"/?.lua;'..package.path"
"GAME_PATH = '"GAME_PATH"'"
;


static lua_State *THE_STATE;
const char *run_lua_code(const char *code)
{
    lua_State *L = THE_STATE;
    if(luaL_loadstring(L, code) != 0) {
        return "syntax error";
    } else {
        lua_pcall(L, 0, 1, 0);
        lua_getglobal(L, "tostring");
        lua_pushvalue(L, -2);
        lua_pcall(L, 1, 1, 0);
        return lua_tostring(L, -1);
    }
}

// pilfered from love.cpp
static int runlove(int argc, char **argv)
{
    if(luaopen_love == NULL) {
        Log(@"luaopen_love is NULL");
    } else {
        Log(@"ok so dlopen fucking works");
    }
    Log(@"%d", argc);
    for(char **arg = argv; *arg != NULL; arg++) {
        Log(@"%s", *arg);
    }
    lua_State *L = luaL_newstate();
    THE_STATE = L;
    luaL_openlibs(L);

    luaL_dostring(L, lua_preload);

    // Add love to package.preload for easy requiring.
    love_preload(L, luaopen_love, "love");

    // Add command line arguments to global arg (like stand-alone Lua).
    {
        lua_newtable(L);

        if (argc > 0)
        {
            lua_pushstring(L, argv[0]);
            lua_rawseti(L, -2, -2);
        }

        lua_pushstring(L, "embedded boot.lua");
        lua_rawseti(L, -2, -1);

        for (int i = 1; i < argc; i++)
        {
            lua_pushstring(L, argv[i]);
            lua_rawseti(L, -2, i);
        }

        lua_setglobal(L, "arg");
    }

    // require "love"
    lua_getglobal(L, "require");
    lua_pushstring(L, "love");
    lua_call(L, 1, 1); // leave the returned table on the stack.

    // Add love._exe = true.
    // This indicates that we're running the standalone version of love, and not
    // the library version.
    {
        lua_pushboolean(L, 1);
        lua_setfield(L, -2, "_exe");
    }

    // Pop the love table returned by require "love".
    lua_pop(L, 1);

    // require "love.boot" (preloaded when love was required.)
    lua_getglobal(L, "require");
    lua_pushstring(L, "love.boot");
    lua_call(L, 1, 1);

    // Call the returned boot function.
    lua_call(L, 0, 1);

    int retval = 0;
    if (lua_isnumber(L, -1))
        retval = (int) lua_tonumber(L, -1);

    lua_close(L);

    return retval;
}

static int forward_argc;
static char **forward_argv;
static int (*orig_main)(int argc, char *argv[], void *, void *);
static int hook_main(int argc, char *argv[], void *lol, void *wut)
{
    // inspiration for this code: 
    // https://github.com/spurious/SDL-mirror/blob/master/src/video/uikit/SDL_uikitappdelegate.m
    int i;

    /* store arguments */
    forward_argc = argc + 1;
    int inserted_game = 0;
    forward_argv = (char **)malloc((forward_argc + 1) * sizeof(char *));
    for (i = 0; i < forward_argc; i++) {
        if(i == 1 && !inserted_game) {
            forward_argv[i] = GAME_PATH;
            inserted_game = 1;
            continue;
        }
        forward_argv[i - inserted_game] = malloc( (strlen(argv[i])+1) * sizeof(char));
        strcpy(forward_argv[i - inserted_game], argv[i]);
    }
    forward_argv[i] = NULL;

    Log(@"hooked main");
    return orig_main(argc, argv, lol, wut);
}

void loveboard_run()
{
    // inspiration for this code: 
    // https://github.com/spurious/SDL-mirror/blob/master/src/video/uikit/SDL_uikitappdelegate.m

    if(love_SDL_iPhoneSetEventPump != NULL) {
        love_SDL_iPhoneSetEventPump(1);
    } else {
        Log(@"set event pump is NULL");
    }

    int err = runlove(forward_argc, forward_argv); // AKA SDL_main

    Log(@"runlove: %d", err);


    if(love_SDL_iPhoneSetEventPump != NULL) {
        love_SDL_iPhoneSetEventPump(0);
    } else {
        Log(@"set event pump is NULL again");
    }
}


static SEL postFinishLaunch_sel;// = @selector(sdoifjaoiimahugefaggotsjfoiadsjf);
static const float DELAY = 0.5;
static const unsigned int MAX_TRIES = 10;
static unsigned int _num_tries = 0;
static id postFinishLaunch(id self, SEL _cmd)
{
    _num_tries++;
    Log(@"boutta start try %d", _num_tries);
    if(_num_tries > MAX_TRIES) return self;

    if(_num_tries == 1) {
        Log(@"first try");
        [self performSelector:postFinishLaunch_sel withObject:nil afterDelay:0];
    } else if(access( GAME_PATH"/main.lua", F_OK ) == -1) { // not found
        Log(@"couldnt find file after %d try", _num_tries);
        [self performSelector:postFinishLaunch_sel withObject:nil afterDelay:DELAY];
    } else {
        Log(@"running loveboard");
        loveboard_run();
    }

    return self;
}
static void loveboard_bootstrap(id self)
{
    postFinishLaunch(self, postFinishLaunch_sel);
}

static BOOL (*orig_app_finished_launching)(id self, SEL _cmd, id app);
static BOOL hook_app_finished_launching(id self, SEL _cmd, id app)
{
    BOOL result = orig_app_finished_launching(self, _cmd, app);

    // inspiration for this code: 
    // https://github.com/spurious/SDL-mirror/blob/master/src/video/uikit/SDL_uikitappdelegate.m
    if(love_SDL_SetMainReady != NULL) {
        love_SDL_SetMainReady();
    } else {
        Log(@"set main ready is NULL");
    }
    loveboard_bootstrap(self);

    return result;
}

static BOOL(*orig_secure)(id self, SEL _cmd);
static BOOL hook_secure(id self, SEL _cmd)
{
    orig_secure(self, _cmd);
    return true;
}

MSInitialize
{
    load_liblove();
    postFinishLaunch_sel = @selector(sdoifjaoiimahugefaggotsjfoiadsjf);
    Class SpringBoard = objc_getClass("SpringBoard");
    class_addMethod(SpringBoard, postFinishLaunch_sel, (IMP)postFinishLaunch, "@:@");
    MSHookFunction(dlsym(RTLD_DEFAULT, "UIApplicationMain"), hook_main, (void **)&orig_main);
    MSHookMessageEx(SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&hook_app_finished_launching, (IMP *)&orig_app_finished_launching);

    Class Window = objc_getClass("SDL_uikitwindow");
    Log(@"window: %@", Window);
    MSHookMessageEx(Window, @selector(_shouldCreateContextAsSecure), (IMP)&hook_secure, (IMP *)&orig_secure);
}
