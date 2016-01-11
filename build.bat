bin2c source/index.lua source/index.cpp index_lua
bin2c assets/icons.png source/icons.cpp icons_png
bin2c assets/icon.png source/icon.cpp icon_png
bin2c assets/voice.png source/voice.cpp voice_png
bin2c assets/main.ttf source/main_font.cpp main_ttf
bin2c assets/keys.png source/pic1.cpp pic1
bin2c assets/nums.png source/pic2.cpp pic2
bin2c assets/keys_c.png source/pic3.cpp pic3
bin2c assets/nums_c.png source/pic4.cpp pic4
bin2c assets/keys_t.png source/pic1m.cpp pic1m
bin2c assets/nums_t.png source/pic2m.cpp pic2m
bin2c assets/keys_c_t.png source/pic3m.cpp pic3m
bin2c assets/nums_c_t.png source/pic4m.cpp pic4m
bin2c assets/zip.png source/zip.cpp zip
make
arm-none-eabi-strip CHMM.elf
makerom2 -f cci -o CHMM.3ds -rsf gw_workaround.rsf -target d -exefslogo -elf CHMM.elf -icon icon.bin -banner banner.bin
makerom -f cia -o CHMM.cia -elf CHMM.elf -rsf cia_workaround.rsf -icon icon.bin -banner banner.bin -exefslogo -target t 