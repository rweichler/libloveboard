#include <substrate.h>
#include <Foundation/Foundation.h>
#include <dlfcn.h>
#include "luahack.h"

#define Log(format, ...) NSLog(@"LoveBoard: %@", [NSString stringWithFormat: format, ## __VA_ARGS__])

static int love_preload(lua_State *L, lua_CFunction f, const char *name)
{
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "preload");
    lua_pushcfunction(L, f);
    lua_setfield(L, -2, name);
    lua_pop(L, 2);
    return 0;
}

//pretty much copied from love.cpp
static int runlove(int argc, char **argv)
{
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

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
int (*orig_main)(int argc, char *argv[], void *, void *);
int hook_main(int argc, char *argv[], void *lol, void *wut)
{
    int i;

    /* store arguments */
    forward_argc = argc;
    forward_argv = (char **)malloc((argc+1) * sizeof(char *));
    for (i = 0; i < argc; i++) {
        forward_argv[i] = malloc( (strlen(argv[i])+1) * sizeof(char));
        strcpy(forward_argv[i], argv[i]);
    }
    forward_argv[i] = NULL;

    Log(@"hooked main");
    return orig_main(argc, argv, lol, wut);
}

BOOL (*orig_app_finished_launching)(id self, SEL _cmd, id app);
BOOL hook_app_finished_launching(id self, SEL _cmd, id app)
{
    BOOL result = orig_app_finished_launching(self, _cmd, app);

    if(SDL_SetMainReady != NULL) {
        SDL_SetMainReady();
    } else {
        Log(@"set main ready is NULL");
    }

    if(SDL_iPhoneSetEventPump != NULL) {
        SDL_iPhoneSetEventPump(1);
    } else {
        Log(@"set event pump is NULL");
    }

    load_liblove();
    runlove(forward_argc, forward_argv);


    if(SDL_iPhoneSetEventPump != NULL) {
        SDL_iPhoneSetEventPump(0);
    } else {
        Log(@"set event pump is NULL");
    }

    return result;
}

MSInitialize {
    MSHookFunction(dlsym(RTLD_DEFAULT, "UIApplicationMain"), hook_main, (void **)&orig_main);
    MSHookMessageEx(NSClassFromString(@"SpringBoard"), @selector(applicationDidFinishLaunching:), (IMP)&hook_app_finished_launching, (IMP *)&orig_app_finished_launching);
}
