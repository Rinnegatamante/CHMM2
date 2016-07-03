-- Enabling 804 Mhz Mode on N3DS
System.setCpuSpeed(804)

-- Localizing used functions/globals
local genColor = Color.new
local setFontSize = Font.setPixelSizes
local fillCPURect = Screen.fillRect
local printFont = Font.print
local flipScreen = Screen.flip
local refreshScreen = Screen.refresh
local fillCPUEmptyRect = Screen.fillEmptyRect
local fillGPURect = Graphics.fillRect
local drawImage = Graphics.drawImage
local drawScaleImage = Graphics.drawScaleImage
local drawPartialImage = Graphics.drawPartialImage
local chdir = System.currentDirectory
local doesFileExist = System.doesFileExist
local loadImage = Graphics.loadImage
local debugPrint = Screen.debugPrint
local getTimerState = Timer.getTime
local resetTimer = Timer.reset
local openFile = io.open
local closeFile = io.close
local getSize = io.size
local writeFile = io.write
local readFile = io.read
local drawLine = Graphics.drawLine
local updateMusic = Sound.updateStream
local getKeyboardString = Keyboard.getInput
local showKeyboard = Keyboard.show
local getKeyboardState = Keyboard.getState
local FINISHED = FINISHED

-- Setting Themes folder
if chdir() == "/" then
	chdir("/Themes/")
else
	chdir(chdir().."Themes/")
end

-- Searching for localization files
local lang_id = System.getLanguage()
local localization
if lang_id == 0 then
	localization = chdir().."../CHMM Localization/japanese.txt"
elseif lang_id == 1 then
	localization = chdir().."../CHMM Localization/english.txt"
elseif lang_id == 2 then
	localization = chdir().."../CHMM Localization/french.txt"
elseif lang_id == 3 then
	localization = chdir().."../CHMM Localization/german.txt"
elseif lang_id == 4 then
	localization = chdir().."../CHMM Localization/italian.txt"
elseif lang_id == 5 then
	localization = chdir().."../CHMM Localization/spanish.txt"
elseif lang_id == 6 then
	localization = chdir().."../CHMM Localization/simplified chinese.txt"
elseif lang_id == 7 then
	localization = chdir().."../CHMM Localization/korean.txt"
elseif lang_id == 8 then
	localization = chdir().."../CHMM Localization/dutch.txt"
elseif lang_id == 9 then
	localization = chdir().."../CHMM Localization/portuguese.txt"
elseif lang_id == 10 then
	localization = chdir().."../CHMM Localization/russian.txt"
else
	localization = chdir().."../CHMM Localization/traditional chinese.txt"
end
if not doesFileExist(localization) then
	localization = "romfs:/english.txt"
end
dofile(localization)

-- Localizing the whole localization file
local wave_style1 = wave_style1
local wave_style2 = wave_style2
local wave_style3 = wave_style3
local listopt = listopt
local listmode1 = listmode1
local listmode2 = listmode2
local bgmprev = bgmprev
local autozipopt = autozipopt
local wavopt = wavopt
local dumpopt = dumpopt
local exitopt = exitopt
local enabled = enabled
local disabled = disabled
local warn = warn
local ok = ok
local yes = yes
local no = no
local hbdesc = hbdesc
local press = press
local linkansw = linkansw
local warnands = warnands
local nodsp = nodsp
local folder = folder
local unkn = unkn
local nodesc = nodesc
local by = by
local norec = norec
local detect = detect
local haxmode = haxmode
local foundt = foundt
local site = site
local shuffle = shuffle
local toexit = toexit
local toscan = toscan
local toprev = toprev
local toerase = toerase
local scanning = scanning
local receiving = receiving
local openbgm = openbgm
local installing = installing
local installing2 = installing2
local dumping = dumping
local extractingzip = extractingzip
local downloadingth = downloadingth
local keyword = keyword
local downth = downth
local showdp = showdp
local search = search
local keysel = keysel
local keymode = keymode
local navmen = navmen
local navthemes = navthemes
local execv = execv
local keymov = keymov
local ret1 = ret1
local addth = addth
local eraseth = eraseth
local installth = installth
local changeidx = changeidx
local unused = unused
local changeth = changeth
local openopt = openopt
local installth2 = installth2
local opensh = opensh
local showprev = showprev
local extzip = extzip
local opendown = opendown

-- Searching for config file
if doesFileExist(chdir().."settings.cfg") then
	dofile(chdir().."settings.cfg")
else
	col_idx = 1
end

-- Initializing some used variables
local list_style = list_style
local bgm_preview = bgm_preview
local auto_extract = auto_extract
local wave_style = wave_style
local col_idx = col_idx
local help_mode = false
local dump_idx = 0
local downloading = false
local opt_idx = 1
local desc_i = 0
local options_menu = false
local opt_voices = {}
local wave_styles = {wave_style1,wave_style2,wave_style3}
local downloader_voices = {downth, showdp, search}
local search_word = ""
local version = "2.7"
local bgm_opening = false
local theme_downloader = false
local shuffle_themes = {}
local select_shuffle = false
local theme_received = false
local netreceiver = false
local install_themes = false
local theme_shuffle = "OFF"
local shuffle_value = 0
local force_bgm_off = false
local idx = 1
local master_index = 0
local preview = false
local is_zip = {}
local zip_pass = {}
local preview_info = {}
local i = 1
local keyboard = false

-- Initializing some colors
local black = genColor(0,0,0)
local white = genColor(255,255,255)

-- Initializing description timer
local desc_timer = Timer.new()
Timer.pause(desc_timer)

-- Setting features according to config file
if list_style == nil then
	list_style = false
end
if bgm_preview == nil then
	bgm_preview = true
end
if auto_extract == nil then
	auto_extract = true
end
if wave_style == nil then
	wave_style = 2
end
if list_style then
	table.insert(opt_voices, listopt .. ": " .. listmode1)
else
	table.insert(opt_voices, listopt .. ": " .. listmode2)
end
if bgm_preview then
	table.insert(opt_voices, bgmprev .. ": " .. enabled)
else
	table.insert(opt_voices, bgmprev .. ": " .. disabled)
end
if auto_extract then
	table.insert(opt_voices, autozipopt .. ": " .. enabled)
else
	table.insert(opt_voices, autozipopt .. ": " .. disabled)
end
table.insert(opt_voices, wavopt .. ": " .. wave_styles[wave_style])
table.insert(opt_voices, dumpopt)
table.insert(opt_voices, exitopt)

-- Initializing GPU
Graphics.init()

-- Loading font
font = Font.load("romfs:/assets/main.ttf")

-- Loading image assets
local icon = loadImage("romfs:/assets/icon.png")
local buttons = loadImage("romfs:/assets/icons.png")
local voice = loadImage("romfs:/assets/voice.png")
local zip_icon = loadImage("romfs:/assets/zip.png")