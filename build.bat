bin2c source/index.lua source/index.cpp index_lua
bin2c data/icons.png source/icons.cpp icons_png
bin2c data/icon.png source/icon.cpp icon_png
bin2c data/voice.png source/voice.cpp voice_png
bin2c data/main.ttf source/font.cpp font_ttf
make
arm-none-eabi-strip CHMM.elf
makerom2 -f cci -o CHMM.3ds -rsf gw_workaround.rsf -target d -exefslogo -elf CHMM.elf -icon icon.bin -banner banner.bin
makerom -f cia -o CHMM.cia -elf CHMM.elf -rsf cia_workaround.rsf -icon icon.bin -banner banner.bin -exefslogo -target t 