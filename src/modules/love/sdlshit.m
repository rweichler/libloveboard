/*
 Simple DirectMedia Layer
 Copyright (C) 1997-2016 Sam Lantinga <slouken@libsdl.org>
 
 This software is provided 'as-is', without any express or implied
 warranty.  In no event will the authors be held liable for any damages
 arising from the use of this software.
 
 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it
 freely, subject to the following restrictions:
 
 1. The origin of this software must not be misrepresented; you must not
 claim that you wrote the original software. If you use this software
 in a product, an acknowledgment in the product documentation would be
 appreciated but is not required.
 2. Altered source versions must be plainly marked as such, and must not be
 misrepresented as being the original software.
 3. This notice may not be removed or altered from any source distribution.
 */
//#include "SDL_internal.h"

//#include "SDL_sysvideo.h"
#include "SDL_assert.h"
#include "SDL_hints.h"
#include "SDL_system.h"
#include "SDL_main.h"
#include <Foundation/Foundation.h>

//#import "SDL_uikitappdelegate.h"
//#import "SDL_uikitmodes.h"
//#import "SDL_uikitwindow.h"

//#include "../../events/SDL_events_c.h"

#ifdef main
#undef main
#endif

void love_SDL_iPhoneSetEventPump(BOOL pump)
{
	SDL_iPhoneSetEventPump(pump ? SDL_TRUE : SDL_FALSE);
}

void love_SDL_SetMainReady()
{
	SDL_SetMainReady();
}
