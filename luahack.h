

#define LUA_REGISTRYINDEX       (-10000)
#define LUA_ENVIRONINDEX        (-10001)
#define LUA_GLOBALSINDEX        (-10002)
#define lua_upvalueindex(i)     (LUA_GLOBALSINDEX-(i))

typedef void lua_State;
typedef int (*lua_CFunction) (lua_State *L);
void (*lua_getfield)(lua_State *, int, const char *);
void (*lua_setfield)(lua_State *, int, const char *);
#define lua_setglobal(L,s)      lua_setfield(L, LUA_GLOBALSINDEX, (s))
#define lua_getglobal(L,s)      lua_getfield(L, LUA_GLOBALSINDEX, (s))
void (*lua_getfield)(lua_State *, int, const char *);
void (*lua_pushcclosure)(lua_State *, lua_CFunction, int);
#define lua_pushcfunction(L,f)  lua_pushcclosure(L, (f), 0)
void (*lua_setfield)(lua_State *, int, const char *);
void (*lua_settop)(lua_State *, int);
#define lua_pop(L,n)            lua_settop(L, -(n)-1)

lua_CFunction luaopen_love;

lua_State * (*luaL_newstate)();
void (*luaL_openlibs)(lua_State *);

void (*lua_createtable)(lua_State *, int, int);
#define lua_newtable(L)         lua_createtable(L, 0, 0)
void (*lua_pushstring)(lua_State *, const char *);
void (*lua_rawseti)(lua_State *, int, int);
void (*lua_call)(lua_State *, int, int);
void (*lua_pushboolean)(lua_State *, int);
int (*lua_isnumber)(lua_State *, int);
float (*lua_tonumber)(lua_State *, int);
int (*luaL_loadfile) (lua_State *, const char *);
int (*lua_pcall) (lua_State *, int, int, int);

#define LUA_MULTRET     (-1)
void (*lua_close)(lua_State *);
#define luaL_dofile(L, fn) \
        (luaL_loadfile(L, fn) || lua_pcall(L, 0, LUA_MULTRET, 0))

void (*love_SDL_SetMainReady)();
void (*love_SDL_iPhoneSetEventPump)(BOOL);


// ok. im doing it this really sketch way because i suck at compiling shit.
// i couldnt link it properly for some reason so im just doing it the shitty way
// of dlopening it and looking up all of the functions. sue me
#define SET(x) x = dlsym(lib, #x)
void load_liblove()
{
    void *lib = dlopen("/usr/lib/libloveboard.dylib", RTLD_NOW);
    if(lib == NULL) {
        Log(@"the lib is fucking NULL");
    } else {
        Log(@"the lib is chill");
    }
    SET(lua_getfield);
    SET(lua_setfield);
    SET(lua_getfield);
    SET(lua_pushcclosure);
    SET(lua_setfield);
    SET(lua_settop);
    SET(luaopen_love);
    SET(luaL_newstate);
    SET(luaL_openlibs);
    SET(lua_createtable);
    SET(lua_pushstring);
    SET(lua_rawseti);
    SET(lua_call);
    SET(lua_pushboolean);
    SET(lua_isnumber);
    SET(lua_tonumber);
    SET(lua_close);
    SET(luaL_loadfile);
    SET(lua_pcall);

    SET(love_SDL_SetMainReady);
    SET(love_SDL_iPhoneSetEventPump);
}
