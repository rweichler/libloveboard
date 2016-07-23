

#define LUA_REGISTRYINDEX       (-10000)
#define LUA_ENVIRONINDEX        (-10001)
#define LUA_GLOBALSINDEX        (-10002)
#define lua_upvalueindex(i)     (LUA_GLOBALSINDEX-(i))

/*
** basic types
*/
#define LUA_TNONE               (-1)

#define LUA_TNIL                0
#define LUA_TBOOLEAN            1
#define LUA_TLIGHTUSERDATA      2
#define LUA_TNUMBER             3
#define LUA_TSTRING             4
#define LUA_TTABLE              5
#define LUA_TFUNCTION           6
#define LUA_TUSERDATA           7
#define LUA_TTHREAD             8

#define lua_isfunction(L,n)     (lua_type(L, (n)) == LUA_TFUNCTION)
#define lua_istable(L,n)        (lua_type(L, (n)) == LUA_TTABLE)
#define lua_islightuserdata(L,n)        (lua_type(L, (n)) == LUA_TLIGHTUSERDATA)
#define lua_isnil(L,n)          (lua_type(L, (n)) == LUA_TNIL)
#define lua_isboolean(L,n)      (lua_type(L, (n)) == LUA_TBOOLEAN)
#define lua_isthread(L,n)       (lua_type(L, (n)) == LUA_TTHREAD)
#define lua_isnone(L,n)         (lua_type(L, (n)) == LUA_TNONE)
#define lua_isnoneornil(L, n)   (lua_type(L, (n)) <= 0)


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
void (*lua_pushvalue)(lua_State *, int);

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
int (*luaL_loadstring) (lua_State *, const char *);
int             (*lua_type) (lua_State *L, int idx);

size_t          (*lua_objlen) (lua_State *L, int idx);

const char * (*lua_tolstring)(lua_State *, int, size_t *);
#define lua_tostring(L,i)       lua_tolstring(L, (i), NULL)

#define luaL_dostring(L, s) \
        (luaL_loadstring(L, s) || lua_pcall(L, 0, LUA_MULTRET, 0))

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
static void load_liblove()
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
    SET(luaL_loadstring);

    SET(love_SDL_SetMainReady);
    SET(love_SDL_iPhoneSetEventPump);
    SET(lua_tolstring);
    SET(lua_pushvalue);
    SET(lua_objlen);
    SET(lua_type);
}
