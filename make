#!/usr/bin/env bash

gcc hook.m -Ilua -Ilove -I ~/code/iphoneheaders/ -dynamiclib -o hook_main.dylib /usr/lib/libsubstrate.dylib -framework Foundation
