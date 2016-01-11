colors = {
		{Color.new(0,132,255), Color.new(72,185,255), Color.new(0,132,255)},  -- Cyan
		{Color.new(255,132,0), Color.new(255,185,72), Color.new(255,132,0)},  -- Orange
		{Color.new(255,72,72), Color.new(255,132,132), Color.new(255,72,72)}, -- Pink
		{Color.new(255,0,0), Color.new(255,72,72), Color.new(255,0,0)}, 	  -- Red
		{Color.new(255,72,255), Color.new(255,185,255), Color.new(255,72,255)},	-- Magenta
		{Color.new(72,72,72), Color.new(0,0,0), Color.new(0,255,0)}	-- Black'N'Green
}
if System.currentDirectory() == "/" then
	System.currentDirectory("/Themes/")
else
	System.currentDirectory(System.currentDirectory().."/Themes/")
end
if System.doesFileExist(System.currentDirectory().."settings.cfg") then
	dofile(System.currentDirectory().."settings.cfg")
else
	col_idx = 1
end
function PurgeDir(dir)
	tmp_files = System.listDirectory(dir)
	for i, file in pairs(tmp_files) do
		System.deleteFile(dir.."/"..file.name)
	end
	System.deleteDirectory(dir)
end
downloading = false
function GenerateQuery(word)
	return string.gsub("http://188.166.72.241/3dsthem.es/api?lua&q="..word," ","%20")
end
function ExecSearchQuery(query)
	idx = 1
	Network.downloadFile(query, "/tmp.chmm")
	zf = io.open("/tmp.chmm",FWRITE)
	io.write(zf,0,"z",1)
	io.close(zf)
	dofile("/tmp.chmm")
	System.deleteFile("/tmp.chmm")
	themes_table = zhemes
	if #themes_table <= 0 then
		return ExecSearchQuery("http://188.166.72.241/3dsthem.es/api?lua&popular")
	end
	Graphics.freeImage(preview_info[1].icon)
	Graphics.freeImage(preview_info[2].icon)
	Graphics.freeImage(preview_info[3].icon)
	ReloadValue(2, idx)
	if idx == 1 then
		o_idx = #themes_table
	else
		o_idx = idx - 1
	end
	ReloadValue(1, o_idx)
	if idx == #themes_table then
		n_idx = 1
	else
		n_idx = idx + 1
	end
	ReloadValue(3, n_idx)
end
function PurgeTmp()
	PurgeDir("/tmp")
end
white = Color.new(255,255,255)
-- DANZEFF KEYBOARD PORTING
danzeff_mode = 1
blockx = 2
blocky = 2
danzeff_x = 20
danzeff_y = 20
danzeff_map = {
    ",abc.def!ghi-jkl\009m n?opq(rst:uvw)xyz",
    "\0\0\0001\0\0\0002\0\0\0003\0\0\0004\009\0 5\0\0\0006\0\0\0007\0\0\0008\0\00009",
    "^ABC@DEF*GHI_JKL\009M N\"OPQ=RST;UVW/XYZ",
    "'(.)\"<'>-[_]!{?}\009\0 \0+\\=/:@;#~$`%*^|&"
}
pic1, pic2, pic3, pic4, pic1m, pic2m, pic3m, pic4m = Graphics.loadDanzeff()
oldpad = KEY_A
downloader_voices = {"Download Theme", "Show Preview", "Search"}
olddanzpad = KEY_A
function ShowDanzeff()
	if danzeff_mode == 1 then
		h = pic1
		Graphics.drawImage(danzeff_x, danzeff_y, pic1m)
	elseif danzeff_mode == 2 then
		h = pic2
		Graphics.drawImage(danzeff_x, danzeff_y, pic2m)
	elseif danzeff_mode == 3 then
		h = pic3
		Graphics.drawImage(danzeff_x, danzeff_y, pic3m)
	else
		h = pic4
		Graphics.drawImage(danzeff_x, danzeff_y, pic4m)
	end
	danx = (blockx - 1) * 50
	dany = (blocky - 1) * 50
	Graphics.drawPartialImage(danzeff_x + danx, danzeff_y + dany, danx, dany, 50, 50, h)
end
function DestroyDanzeff()
	Graphics.freeImage(pic1)
	Graphics.freeImage(pic2)
	Graphics.freeImage(pic3)
	Graphics.freeImage(pic4)
	Graphics.freeImage(pic1m)
	Graphics.freeImage(pic2m)
	Graphics.freeImage(pic3m)
	Graphics.freeImage(pic4m)
end
function DanzeffInput()
	
	cx, cy = Controls.readCirclePad()
	danzpad = Controls.read()
	posx = 2
	posy = 2
	
	if cx < -50 then
		posx = 1
	end
	if cx > 50 then
		posx = 3
	end
	if cy > 50 then
		posy = 1
	end
	if cy < -50 then
		posy = 3
	end
	
	if blocky ~= posy or blockx ~= posx then
		blocky = posy
		blockx = posx
	end
	
	if danzeff_mode > 2 then
		danzeff_mode = danzeff_mode - 2
	end
	
	if Controls.check(danzpad, KEY_L) and not Controls.check(olddanzpad, KEY_L) then
		if danzeff_mode == 1 then
			danzeff_mode = 2
		else
			danzeff_mode = 1
		end
	end
	if Controls.check(danzpad, KEY_R) then
		danzeff_mode = danzeff_mode + 2
	end
	
	charpos = (blocky - 1) * 12 + (blockx - 1) * 4
	if Controls.check(danzpad, KEY_Y) and not Controls.check(olddanzpad, KEY_Y) then
		res = string.byte(danzeff_map[danzeff_mode], charpos + 2)
	elseif Controls.check(danzpad, KEY_A) and not Controls.check(olddanzpad, KEY_A) then
		res = string.byte(danzeff_map[danzeff_mode], charpos + 4)
	elseif Controls.check(danzpad, KEY_B) and not Controls.check(olddanzpad, KEY_B) then
		res = string.byte(danzeff_map[danzeff_mode], charpos + 3)
	elseif Controls.check(danzpad, KEY_X) and not Controls.check(olddanzpad, KEY_X) then
		res = string.byte(danzeff_map[danzeff_mode], charpos + 1)
	else
		res = 0
	end
	
	olddanzpad = danzpad
	return res
	
end
opt_idx = 1
desc_i = 0
desc_timer = Timer.new()
Timer.pause(desc_timer)
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
options_menu = false
opt_voices = {}
wave_styles = {"Ondular","Tiny Wave","Fullscreen Wave"}
if list_style then
	table.insert(opt_voices, "Listing mode: Textlist")
else
	table.insert(opt_voices, "Listing mode: Ringmenu")
end
if bgm_preview then
	table.insert(opt_voices, "BGM Preview: On")
else
	table.insert(opt_voices, "BGM Preview: Off")
end
if auto_extract then
	table.insert(opt_voices, "Auto Extract ZIP themes: On")	
else
	table.insert(opt_voices, "Auto Extract ZIP themes: Off")	
end
table.insert(opt_voices,"Topscreen Wave Style: " .. wave_styles[wave_style])
table.insert(opt_voices,"Exit CHMM2")
function ExtractTheme(t_idx, is_temp)
	filename = System.currentDirectory() .. themes_table[t_idx].name
	-- TODO: Add password support
	if is_temp then
		System.extractZIP(filename, "/tmp")
	else
		System.extractZIP(filename, string.sub(filename,1,-5))
		System.deleteFile(filename)
		is_zip[idx] = false
		themes_table[t_idx].name = string.sub(themes_table[t_idx].name,1,-5)
	end
end

-- Check if themehax/shufflehax is installed
isShufflehax = false
isThemehax = false
reg = System.getRegion()
if reg == 1 then
	archive = 0x000002cd
	archive2 = 0x0000008f
elseif reg == 2 then
	archive = 0x000002ce
	archive2 = 0x00000098
else
	archive = 0x000002cc
	archive2 = 0x00000082
end
tmp = io.open("/SaveData.dat",FREAD,archive2)
shuffle_flag = string.byte(io.read(tmp,0x141B,1))
if shuffle_flag == 1 then -- shufflehax?
	shuffle_idx = string.byte(io.read(tmp, 0x13C0, 1))
	if shuffle_idx == 0xFF then
		isShufflehax = true
	end
else -- themehax?
	ylws_file = io.open("/yhemeManage.bin",FREAD,archive)
	if ylws_file > 0 then
		isThemehax = true
		io.close(ylws_file)
	end
end
io.close(tmp)

function OptionExecute(voice_num)
	if voice_num == 1 then
		list_style = not list_style
		if list_style then
			opt_voices[voice_num] = "Listing mode: Textlist"
		else
			opt_voices[voice_num] = "Listing mode: Ringmenu"
		end
	elseif voice_num == 2 then
		bgm_preview = not bgm_preview
		if bgm_preview then
			opt_voices[voice_num] = "BGM Preview: On"
		else
			opt_voices[voice_num] = "BGM Preview: Off"
		end
	elseif voice_num == 3 then
		auto_extract = not auto_extract
		if auto_extract then
			opt_voices[voice_num] = "Auto Extract ZIP themes: On"
		else
			opt_voices[voice_num] = "Auto Extract ZIP themes: Off"
		end
	elseif voice_num == 4 then
		wave_style = wave_style + 1
		if wave_style > 3 then
			wave_style = 1
		end
		wav:destroy()
		if wav_style == 2 then
			wav = LoadWave(1,600, 0.1, wave_style, 400)
		else
			wav = LoadWave(15,600, 0.1, wave_style, 400)
		end
		wav:color(Color.getR(colors[col_idx][3]),Color.getG(colors[col_idx][3]),Color.getB(colors[col_idx][3]))
		opt_voices[voice_num] = "Topscreen Wave Style: " .. wave_styles[wave_style]
	elseif voice_num == 5 then
		options_menu = not options_menu
		Graphics.freeImage(preview_info[1].icon)
		Graphics.freeImage(preview_info[2].icon)
		Graphics.freeImage(preview_info[3].icon)
		Graphics.freeImage(icon)
		Graphics.freeImage(voice)
		Graphics.freeImage(buttons)
		DestroyDanzeff()
		CloseMusic()
		Timer.destroy(desc_timer)
		PurgeShuffleTable()
		if netreceiver then
			Socket.close(netrecv)
			if theme_received then
				Socket.close(client)
			end
			Socket.term()
		end
		Sound.term()
		wav:destroy()
		wav2:destroy()
		ClosePreview()
		Timer.destroy(delayer)
		System.exit()
	end
end
function PrintOptionsVoices()
	Font.setPixelSizes(font, 14)
	base_y = 30
	for l, voice in pairs(opt_voices) do
		if (base_y > 205) then
			break
		end
		x = 5
		if (l==opt_idx) then
			Screen.fillRect(0,319,base_y-2,base_y+17,colors[col_idx][1],BOTTOM_SCREEN)
			x = 10
		end
		Font.print(font, x, base_y, voice, Color.new(255, 255, 255), BOTTOM_SCREEN)
		base_y = base_y + 20
	end
end
version = "2.5"
bgm_opening = false
theme_downloader = false
Graphics.init()
shuffle_themes = {}
select_shuffle = false
Sound.init()
theme_received = false
netreceiver = false
install_themes = false
theme_shuffle = "OFF"
shuffle_value = 0
font = Font.loadMain()
icon, buttons, voice, zip_icon = Graphics.loadAssets()
function SortDirectory(dir)
	folders_table = {}
	for i,file in pairs(dir) do
		if file.directory then
			table.insert(folders_table,file)
		end
	end
	table.sort(folders_table, function (a, b) return (a.name:lower() < b.name:lower() ) end)
	return_table = folders_table
	return return_table
end
function SortZip(dir)
	zip_table = {}
	for i,file in pairs(dir) do
		if not file.directory and string.sub(file.name, -4):lower() == ".zip" then
			table.insert(zip_table,file)
		end
	end
	table.sort(zip_table, function (a, b) return (a.name:lower() < b.name:lower() ) end)
	return_table = zip_table
	return return_table
end
idx = 1
function PrintBottomUI()
	Graphics.fillRect(0, 320, 0, 240, colors[col_idx][2])
	Graphics.fillRect(0, 320, 0, 25, colors[col_idx][1])
end
function PrintTopUI()
	Graphics.fillRect(0, 400, 0, 240, colors[col_idx][2])
end
master_index = 0
function PrintThemesList()
	Font.setPixelSizes(font, 14)
	base_y = 30
	for l, file in pairs(themes_table) do
		if (base_y > 205) then
			break
		end
		if (l >= master_index) then
			x = 5
			if (l==idx) then
				Screen.fillRect(0,319,base_y-2,base_y+17,colors[col_idx][1],BOTTOM_SCREEN)
				x = 10
			end
			Font.print(font, x, base_y, file.name, Color.new(255, 255, 255), BOTTOM_SCREEN)
			base_y = base_y + 20
		end
	end
end
function ReloadValue(p_idx, t_idx)
	if theme_downloader then
		p2_tmp = Screen.createImage(48,48, white)
		Screen.debugPrint(5,8,string.sub(themes_table[t_idx].name,1,3),Color.new(0,0,0),p2_tmp)
		tmp = Graphics.convertFrom(p2_tmp)
		Screen.freeImage(p2_tmp)
		preview_info[p_idx] = {["author"] = themes_table[t_idx].by, ["desc"] = themes_table[t_idx].desc, ["title"] = themes_table[t_idx].name, ["icon"] = tmp}
	elseif is_zip[t_idx] then
		has_smdh = System.extractFromZIP(System.currentDirectory() .. themes_table[t_idx].name, "info.smdh", "/tmp.smdh")
		if has_smdh then
			preview_info[p_idx] = System.extractSMDH("/tmp.smdh")
			tmp = Graphics.convertFrom(preview_info[p_idx].icon)
			Screen.freeImage(preview_info[p_idx].icon)
			preview_info[p_idx].icon = tmp
			System.deleteFile("/tmp.smdh")
		else
			p2_tmp = Screen.createImage(48,48, white)
			Screen.debugPrint(5,8,string.sub(themes_table[t_idx].name,1,3),Color.new(0,0,0),p2_tmp)
			tmp = Graphics.convertFrom(p2_tmp)
			Screen.freeImage(p2_tmp)
			preview_info[p_idx] = {["author"] = "Unknown", ["desc"] = "No description.", ["title"] = themes_table[t_idx].name, ["icon"] = tmp}
		end
	else
		if System.doesFileExist(System.currentDirectory() .. themes_table[t_idx].name .. "/info.smdh") then
			preview_info[p_idx] =  System.extractSMDH(System.currentDirectory() .. themes_table[t_idx].name .. "/info.smdh")
			tmp = Graphics.convertFrom(preview_info[p_idx].icon)
			Screen.freeImage(preview_info[p_idx].icon)
			preview_info[p_idx].icon = tmp
		else
			p2_tmp = Screen.createImage(48,48, white)
			Screen.debugPrint(5,8,string.sub(themes_table[t_idx].name,1,3),Color.new(0,0,0),p2_tmp)
			p2 = Graphics.convertFrom(p2_tmp)
			Screen.freeImage(p2_tmp)
			preview_info[p_idx] = {["author"] = "Unknown", ["desc"] = "No description.", ["title"] = themes_table[t_idx].name, ["icon"] = p2}
		end	
	end
end
function PrintTitle(version_bool)
	Font.setPixelSizes(font, 16)
	Font.print(font, 5, 5, "CHMM2 - Theme Manager for Nintendo 3DS", Color.new(255, 255, 255), BOTTOM_SCREEN)
	if version_bool then
		if Network.isWifiEnabled() then
			if Network.getIPAddress() == "247.7.224.216" then
				ip = "Netrecv error"
			else
				ip = "IP: " .. Network.getIPAddress()
			end
		else
			ip = ""
		end
		Font.print(font, 5, 225, "v."..version.."                                            "..ip, Color.new(255, 255, 255), BOTTOM_SCREEN)
	end
end
function PrintIconsPreview()
	
	-- Current icon
	Graphics.drawImage(132, 82, icon)
	Graphics.drawScaleImage(137, 88, preview_info[2].icon, 0.95, 0.95)
	
	-- #1 and #3 icons
	Graphics.drawScaleImage(66, 60, icon, 0.8, 0.8)
	Graphics.drawScaleImage(71, 66, preview_info[1].icon, 0.7, 0.7)
	Graphics.drawScaleImage(209, 60, icon, 0.8, 0.8)
	Graphics.drawScaleImage(214, 66, preview_info[3].icon, 0.7, 0.7)
	
end
function PrintInfoUI()
	Graphics.drawImage(10, 150, voice)
	if is_zip[idx] and not theme_downloader then
		Graphics.drawImage(275, 158, zip_icon)
	end
end
function DescriptionPrint()
	len = string.len(preview_info[2].desc) - 45
	if desc_i == 0 or desc_i >= len then
		if desc_i == 0 and Timer.getTime(desc_timer) > 2000 then
			desc_i = 1
			Timer.reset(desc_timer)
		elseif desc_i >= len and Timer.getTime(desc_timer) > 2000 then
			desc_i = 0
			Timer.reset(desc_timer)
		end
	else
		desc_i = desc_i + 1
		Timer.reset(desc_timer)
	end
	Font.print(font, 17, 189, string.sub(preview_info[2].desc,desc_i,45+desc_i), Color.new(0, 0, 0), BOTTOM_SCREEN)
end
function PrintInfo()
	Font.setPixelSizes(font, 20)
	Font.print(font, 17, 157, preview_info[2].title, colors[col_idx][1], BOTTOM_SCREEN)
	Font.setPixelSizes(font, 16)
	if string.len(preview_info[2].desc) > 40 then
		Timer.resume(desc_timer)
		DescriptionPrint()
	else
		Font.print(font, 17, 189, preview_info[2].desc, Color.new(0, 0, 0), BOTTOM_SCREEN)
	end
	Font.setPixelSizes(font, 12)
	Font.print(font, 17, 175, "By " .. preview_info[2].author, colors[col_idx][1], BOTTOM_SCREEN)
end
function PrintDownloadMenu()
	for i, voice in pairs(downloader_voices) do
		if i == dwnld_idx then
			color = Color.new(255, 255, 0)
		else
			color = white
		end
		Font.print(font, 200, 35 + i * 15, voice, color, TOP_SCREEN)
	end
end
function MoveCursorLeft(t_idx)
	Graphics.freeImage(preview_info[3].icon)
	preview_info[3] = preview_info[2]
	preview_info[2] = preview_info[1]
	t_idx = t_idx - 1
	if t_idx < 1 then
		t_idx = #themes_table
	end
	ReloadValue(1, t_idx)
end
function MoveCursorRight(t_idx)
	Graphics.freeImage(preview_info[1].icon)
	preview_info[1] = preview_info[2]
	preview_info[2] = preview_info[3]
	t_idx = t_idx + 1
	if t_idx > #themes_table then
		t_idx = 1
	end
	ReloadValue(3, t_idx)
end
function CloseMusic()
	if music then
		Sound.close(bgm_song)
		music = false
	end
end
function u32toString(value)
	byte4 = 0x00
	byte3 = 0x00
	byte2 = 0x00
	while (value >= 0x1000000) do
		byte4 = byte4 + 1
		value = value - 0x1000000
	end
	while (value >= 0x10000) do
		byte3 = byte3 + 1
		value = value - 0x10000
	end
	while (value >= 0x100) do
		byte2 = byte2 + 1
		value = value - 0x100
	end
	byte1 = value
	ret_string = string.char(byte1,byte2,byte3,byte4)
	return ret_string
end
function ChangeTheme(theme)
	if isShufflehax or isThemehax then
		body_f = "/yodyCache.bin"
		theme_f = "/yhemeManage.bin"
	else
		savedata = io.open("/SaveData.dat",FWRITE,archive2)
		io.write(savedata,0x141B,string.char(0),1)
		io.write(savedata,0x13B8,string.char(0xFF,0,0,0,0,3,0,0),8)
		io.close(savedata)
		body_f = "/BodyCache.bin"
		theme_f = "/ThemeManage.bin"
	end
	if System.doesFileExist(theme.."/body_LZ.bin") then
		body = io.open(theme.."/body_LZ.bin",FREAD)
		body_size = io.size(body)
		out = io.open(body_f,FWRITE,archive)
		to_write = io.read(body,0,body_size)
		if isShufflehax then
			out2 = io.open("/yodyCache_rd.bin",FWRITE,archive)
			io.write(out2,0,to_write,body_size)
			io.write(out2,0x2A0000,to_write,body_size)
			io.close(out2)
		end
		io.write(out,0,to_write,body_size)
		io.close(out)
		io.close(body)
	else
		body_size = 0
	end
	if System.doesFileExist(theme.."/bgm.bcstm") then
		bgm = io.open(theme.."/bgm.bcstm",FREAD)
		bgm_size = io.size(bgm)
		to_write = io.read(bgm,0,bgm_size)
		if isShufflehax then
			out2 = io.open("/BgmCache_00.bin",FWRITE,archive)
			io.write(out2,0,to_write,bgm_size)
			io.close(out2)
			out2 = io.open("/BgmCache_02.bin",FWRITE,archive)
			io.write(out2,0,to_write,bgm_size)
			io.close(out2)
		end
		out = io.open("/BgmCache.bin",FWRITE,archive)
		io.write(out,0,to_write,bgm_size)
		io.close(out)
		io.close(bgm)
	else
		bgm_size = 0
	end
	if System.doesFileExist(theme.."/ThemeManage.bin") and not isShufflehax then
		tm = io.open(theme.."/ThemeManage.bin",FREAD)
		tm_size = io.size(tm)
		out = io.open(theme_f,FWRITE,archive)
		io.write(out,0,io.read(tm,0,tm_size),tm_size)
		io.close(out)
		io.close(tm)
	elseif isShufflehax then
		out = io.open(theme_f,FWRITE,archive)
		io.write(out,0x338,u32toString(body_size),4)
		io.write(out,0x340,u32toString(body_size),4)
		io.write(out,0x360,u32toString(bgm_size),4)
		io.write(out,0x368,u32toString(bgm_size),4)
		io.close(out)
	else
		out = io.open(theme_f,FWRITE,archive)	
		io.write(out,0x00,string.char(1),1)
		io.write(out,0x01,string.char(0,0,0,0,0,0,0),7)
		io.write(out,0x08,u32toString(body_size),4)
		io.write(out,0x0C,u32toString(bgm_size),4)
		io.write(out,0x10,string.char(0xFF),1)
		io.write(out,0x14,string.char(0x01),1)
		io.write(out,0x18,string.char(0xFF),1)
		io.write(out,0x1D,string.char(0x02),1)
		io.close(out)
	end
end
function ChangeMultipleTheme(themes)
	body_sizes = {}
	bgm_sizes = {}
	savedata = io.open("/SaveData.dat",FWRITE,archive2)
	io.write(savedata,0x141B,string.char(1),1)
	io.write(savedata,0x13B8,string.char(0,0,0,0,0,0,0,0),8)
	i = 0
	while i < 10 do
		savedata_offset = 0x13C0 + 0x8 * i
		if i < #themes then
			if themes[i + 1][3] then
				ExtractTheme(themes[i + 1][4], true)
				System.renameDirectory("/tmp","/tmp"..i)
			end
			io.write(savedata,savedata_offset,string.char(i,0,0,0,0,3,0,0),8)
		else
			io.write(savedata,savedata_offset,string.char(0,0,0,0,0,0,0,0),8)
		end
		i = i + 1
	end
	io.close(savedata)
	i = 0
	out = io.open("/BodyCache_rd.bin",FWRITE,archive)
	while i < 10 do
		body_offset = 0x150000 * i
		if i < #themes then
			theme = themes[i + 1][1]
			if System.doesFileExist(System.currentDirectory()..theme.."/body_LZ.bin") then
				body = io.open(System.currentDirectory()..theme.."/body_LZ.bin",FREAD)
				body_size = io.size(body)
				io.write(out,body_offset,io.read(body,0,body_size),body_size)
				io.close(body)
			elseif System.doesFileExist("/tmp"..i.."/body_LZ.bin") and themes[i + 1][3] then
				body = io.open("/tmp"..i.."/body_LZ.bin",FREAD)
				body_size = io.size(body)
				io.write(out,body_offset,io.read(body,0,body_size),body_size)
				io.close(body)
			else
				body_size = 0
			end
		else
			body_size = 0
		end
		table.insert(body_sizes, body_size)
		i = i + 1
	end
	io.close(out)
	i = 0
	while i < 10 do
		if i < #themes then
			theme = themes[i + 1][1]
			if System.doesFileExist(System.currentDirectory()..theme.."/bgm.bcstm") then
				bgm = io.open(System.currentDirectory()..theme.."/bgm.bcstm",FREAD)
				bgm_size = io.size(bgm)
				out = io.open("/BgmCache_0"..i..".bin",FWRITE,archive)
				io.write(out,0,io.read(bgm,0,bgm_size),bgm_size)
				io.close(out)
				io.close(bgm)
			elseif System.doesFileExist("/tmp"..i.."/bgm.bcstm") and themes[i + 1][3] then
				bgm = io.open("/tmp"..i.."/bgm.bcstm",FREAD)
				bgm_size = io.size(bgm)
				out = io.open("/BgmCache_0"..i..".bin",FWRITE,archive)
				io.write(out,0,io.read(bgm,0,bgm_size),bgm_size)
				io.close(out)
				io.close(bgm)
			else
				bgm_size = 0
			end
		else
			bgm_size = 0
		end
		table.insert(bgm_sizes, bgm_size)
		i = i + 1
	end
	out = io.open("/ThemeManage.bin",FWRITE,archive)
	io.write(out,0x00,string.char(1),1)
	io.write(out,0x01,string.char(0,0,0,0,0,0,0),7)
	io.write(out,0x08,string.char(0,0,0,0),4)
	io.write(out,0x0C,string.char(0,0,0,0),4)
	io.write(out,0x10,string.char(0xFF),1)
	io.write(out,0x14,string.char(0x01),1)
	io.write(out,0x18,string.char(0xFF),1)
	io.write(out,0x1D,string.char(0x02),1)
	i = 0
	while i < 10 do
		mng_body_offset = 0x338 + 0x4 * i
		mng_bgm_offset = 0x360 + 0x4 * i
		io.write(out,mng_body_offset,u32toString(body_sizes[i + 1]),4)
		io.write(out,mng_bgm_offset,u32toString(bgm_sizes[i + 1]),4)
		if i < #themes then
			if themes[i + 1][3] then
				PurgeDir("/tmp"..i)
			end
		end
		i = i + 1
	end
	io.close(out)
end
function LoadPreview()
	if theme_downloader then
		p = Graphics.loadImage("/chmm_tmp.png")
		System.deleteFile("/chmm_tmp.png")
	elseif is_zip[idx] then
		p1 = System.extractFromZIP(System.currentDirectory() .. themes_table[idx].name, "Preview.png", "/preview.png")
		if not p1 then
			p1 = System.extractFromZIP(System.currentDirectory() .. themes_table[idx].name, "Preview.jpg", "/preview.png")
			if not p1 then
				p1 = System.extractFromZIP(System.currentDirectory() .. themes_table[idx].name, "Preview.bmp", "/preview.png")
			end
		end
		if not p1 then
			p_tmp = Screen.createImage(400,240, Color.new(0,0,0))
			p = Graphics.convertFrom(p_tmp)
			Screen.freeImage(p_tmp)
		else
			p = Graphics.loadImage("/preview.png")
			System.deleteFile("/preview.png")
		end
	elseif System.doesFileExist(System.currentDirectory() .. themes_table[idx].name .. "/preview.png") then
		p = Graphics.loadImage(System.currentDirectory() .. themes_table[idx].name .. "/preview.png")
	elseif System.doesFileExist(System.currentDirectory() .. themes_table[idx].name .. "/preview.jpg") then
		p = Graphics.loadImage(System.currentDirectory() .. themes_table[idx].name .. "/preview.jpg")
	elseif System.doesFileExist(System.currentDirectory() .. themes_table[idx].name .. "/preview.bmp") then
		p = Graphics.loadImage(System.currentDirectory() .. themes_table[idx].name .. "/preview.bmp")
	else
		p_tmp = Screen.createImage(400,240, Color.new(0,0,0))
		p = Graphics.convertFrom(p_tmp)
		Screen.freeImage(p_tmp)
	end
	r_width = Graphics.getImageWidth(p)
	r_height = Graphics.getImageHeight(p)
	if r_width == 400 and r_height >= 480 then
		img_type = "YATA"
	elseif r_width == 432 and r_height == 528 then
		img_type = "SSHOT"
	else
		img_type = "UNKNWN"
	end
end
function PrintPreviews()
	if p == nil then
		LoadPreview()		
	end
	if	img_type == "YATA" then
		Graphics.drawPartialImage(0, 0, 0, 0, 400, 240, p, Color.new(255,255,255,alpha1))
		Graphics.drawPartialImage(40, 0, 40, 240, 320, 240, p, Color.new(255,255,255,alpha2))
	elseif img_type == "SSHOT" then
		Graphics.drawPartialImage(0, 0, 16, 16, 400, 240, p, Color.new(255,255,255,alpha1))
		Graphics.drawPartialImage(40, 0, 56, 272, 320, 240, p, Color.new(255,255,255,alpha2))
	else
		Graphics.drawPartialImage(0, 0, 0, 0, 400, 240, p)
	end
end
function PrintTopUI2()
	Graphics.fillRect(0, 400, 215, 240, colors[col_idx][1])
end
function PrintThemesInfo()
	Font.setPixelSizes(font, 16)
	if isShufflehax or isThemehax then
		Font.print(font, 5, 220, "Detected Themes: " .. #themes_table .. "           MenuHax Mode: ON", Color.new(255, 255, 255), TOP_SCREEN)
	elseif theme_downloader and not preview then
		Font.print(font, 5, 220, "Found Themes: " .. #zhemes .. "           Theme Site: 3DSThem.es", Color.new(255, 255, 255), TOP_SCREEN)
	else
		Font.print(font, 5, 220, "Detected Themes: " .. #themes_table .. "           Theme Shuffle: " .. theme_shuffle, Color.new(255, 255, 255), TOP_SCREEN)
	end
end
preview = false
function ScanDirectory(dir,path)
	for i, file in pairs(System.listDirectory(path)) do
		if file.name == "body_LZ.bin" and string.len(path) > 1 then
			System.createDirectory(System.currentDirectory() .. dir)
			for i, file in pairs(System.listDirectory(path)) do
				System.renameFile(path .. file.name, System.currentDirectory() .. dir .. "/" .. file.name)
			end
			System.deleteDirectory(path)
			break
		elseif file.directory then
			ScanDirectory(file.name,path..file.name.."/")
		end
	end
end
function ScanSD()
	found = false
	System.createDirectory(System.currentDirectory())
	ScanDirectory("/","/")	
	themes_table = SortDirectory(System.listDirectory(System.currentDirectory()))
end
function PrintError()
	Font.setPixelSizes(font, 16)
	Font.print(font, 17, 157, "No theme recognized.", colors[col_idx][1], BOTTOM_SCREEN)
	Font.print(font, 17, 173, "You must put themes in:", Color.new(0,0,0), BOTTOM_SCREEN)
	Font.print(font, 17, 188, System.currentDirectory(), Color.new(0,0,0), BOTTOM_SCREEN)
end
function PrintControls()
	Font.setPixelSizes(font, 18)
	Font.print(font, 57, 60, "Press        to exit CHMM2", Color.new(0,0,0), TOP_SCREEN)
	Font.print(font, 57, 80, "Press        to scan SD for themes", Color.new(0,0,0), TOP_SCREEN)
end
function Alert(txt, screen)
	Font.setPixelSizes(font, 16)
	Font.print(font, 5, 220, txt, Color.new(255, 255, 255), screen)
end
function PrintButtonsUI()
	Graphics.drawImage(50, 50, voice)
	Graphics.drawPartialImage(94, 62, 0, 0, 17, 15, buttons)
	Graphics.drawPartialImage(94, 82, 17, 0, 17, 15, buttons)
end
function LoadWave(height,dim,f,style,x_dim)	
	if style == 1 then
		f=f or 0.1
		local onda={pi=math.pi,Frec=f,Long_onda=dim,Amplitud=height}
		function onda:color(a,b,c) self.a=a self.b=b self.c=c end
		function onda:init(desfase)
			desfase=desfase or 0
			if not self.contador then
				self.contador=Timer.new()
			end
			if not self.a or not self.b or not self.c then
				self.a = 0
				self.b = 0
				self.c = 255
			end
			local t,x,y,i
			t = Timer.getTime(self.contador)/1000+desfase
			for x = 0,x_dim,4 do
				y = 100+self.Amplitud*math.sin(2*self.pi*(t*self.Frec-x/self.Long_onda))
				i = self.Amplitud*(-2*self.pi/self.Long_onda)*math.cos(2*self.pi*(t*self.Frec-x/self.Long_onda))
				Graphics.drawLine(x-200,x+200,y-i*200,y+i*200,Color.new(self.a,self.b,self.c,math.floor(x/40)))
			end
			collectgarbage()
		end
		function onda:destroy()
			Timer.destroy(self.contador)
		end
		return onda
	end
	if style == 2 then
		f=f or 0.1
		local onda={pi=math.pi,Frec=f,Long_onda=dim,Amplitud=height}
		function onda:color(a,b,c) self.a=a self.b=b self.c=c end
		function onda:init(desfase)
			desfase=desfase or 0
			if not self.contador then
				self.contador=Timer.new()
			end
			if not self.a or not self.b or not self.c then
				self.a = 0
				self.b = 0
				self.c = 255
			end
			local t,x,y,i,a
			t = Timer.getTime(self.contador)/1000+desfase
			if self.Amplitud <= 5 then
				self.aumento = true
			elseif self.Amplitud >= 110 then
				self.aumento = false
			end
			if self.aumento then
				self.Amplitud = self.Amplitud+0.1
			else
				self.Amplitud = self.Amplitud-0.1
			end
			for x = 0,x_dim,10 do
				y = 120+self.Amplitud*math.sin(2*self.pi*(t*self.Frec-x/self.Long_onda))
				i = self.Amplitud*(-2*self.pi/self.Long_onda)*math.cos(2*self.pi*(t*self.Frec-x/self.Long_onda))
				for a = -3,3 do
					Graphics.drawLine(x-20,x+20,a+y-i*20,a+y+i*20,Color.new(self.a,self.b,self.c,25-math.abs(a*5)))
				end
			end
			collectgarbage()
		end
		function onda:destroy()
			Timer.destroy(self.contador)
		end
		return onda
	end
	if style == 3 then
		f=f or 0.1
		local onda={pi=math.pi,Frec=f,Long_onda=dim,Amplitud=height}
		function onda:color(a,b,c) self.Color=Color.new(a,b,c,40) end
		function onda:init(desfase)
			desfase=desfase or 0
			if not self.contador then
				self.contador=Timer.new()
			end
			if not self.Color then
				self.Color=Color.new(0,0,255,40)
			end
			local t,x,y,i
			t = Timer.getTime(self.contador)/1000+desfase
			for x = 0,x_dim do
				y = 100+self.Amplitud*math.sin(2*self.pi*(t*self.Frec-x/self.Long_onda))
				Graphics.drawLine(x,x,y,240,self.Color)
			end
			collectgarbage()
		end
		function onda:destroy()
			Timer.destroy(self.contador)
		end
		return onda
	end
end
is_zip = {}
zip_pass = {}
themes_table = SortDirectory(System.listDirectory(System.currentDirectory()))
for i, folder in pairs(themes_table) do
	table.insert(is_zip, false)
	table.insert(zip_pass, nil)
end
themes_table2 = SortZip(System.listDirectory(System.currentDirectory()))
for i, zipfile in pairs(themes_table2) do
	table.insert(themes_table, zipfile)
	table.insert(is_zip, true)
	table.insert(zip_pass, nil)
end
preview_info = {}
if wav_style == 2 then
	wav = LoadWave(1,600, 0.1, wave_style, 400)
else
	wav = LoadWave(15,600, 0.1, wave_style, 400)
end
wav2 = LoadWave(15,600, 0.1, 1, 320)
wav:color(Color.getR(colors[col_idx][3]),Color.getG(colors[col_idx][3]),Color.getB(colors[col_idx][3]))
wav2:color(Color.getR(colors[col_idx][3]),Color.getG(colors[col_idx][3]),Color.getB(colors[col_idx][3]))
if System.doesFileExist("/patch.lua") then
	dofile("/patch.lua")
end
while #themes_table <= 0 do
	if theme_received then
		block = Socket.receive(client, 16384)
		if string.len(block) > 0 then
			io.write(new_theme, offs, block, string.len(block))
			offs = offs + string.len(block)
		else
			io.close(new_theme)
			Socket.send(client, "YATA TERM")
			Socket.close(client)
			System.extractZIP("/tmp.zip","/tmp")
			for i,dir in pairs(System.listDirectory("/tmp")) do
				if dir.directory then
					System.createDirectory(System.currentDirectory() .. dir.name)
					filelist = System.listDirectory("/tmp/" .. dir.name)
					for z, file in pairs(filelist) do
						System.renameFile("/tmp/" .. dir.name .. "/" .. file.name, System.currentDirectory() .. dir.name .. "/" .. file.name)
					end
					System.deleteDirectory("/tmp/" .. dir.name)
					table.insert(themes_table, dir)
				end
			end
			System.deleteDirectory("/tmp")
			System.deleteFile("/tmp.zip")
			Graphics.freeImage(preview_info[1].icon)
			Graphics.freeImage(preview_info[3].icon)
			if idx > 1 then
				ReloadValue(1, idx-1)
			else
				ReloadValue(1, #themes_table)
			end
			ReloadValue(3, idx+1)
			theme_received = false
			client = nil
		end
	else
		if not netreceiver then
			if Network.isWifiEnabled() then
				Socket.init()
				netrecv = Socket.createServerSocket(5000)
				netreceiver = true
			end
		else
			if not Network.isWifiEnabled() then
				Socket.close(netrecv)
				Socket.term()
				netreceiver = false
			else
				client = Socket.accept(netrecv)
				if client ~= nil then
					Socket.send(client, "YATA SENDER")
					new_theme = io.open("/tmp.zip",FCREATE)
					offs = 0
					theme_received = true
				end
			end
		end
	end
	pad = Controls.read()
	Screen.refresh()
	Graphics.initBlend(TOP_SCREEN)
	PrintTopUI()
	wav:init()
	PrintButtonsUI()
	if to_scan then
		PrintTopUI2()
	end
	Graphics.termBlend()
	Graphics.initBlend(BOTTOM_SCREEN)
	PrintBottomUI()
	wav2:init()
	PrintControls()
	PrintInfoUI()
	Graphics.termBlend()
	PrintError()
	if to_scan then
		Alert("Scanning SD for themes...", TOP_SCREEN)
	elseif theme_received then
		Alert("Receiving a themes packet from network...", TOP_SCREEN)
	end
	PrintTitle(true)
	Screen.flip()
	if to_scan then
		ScanSD()
	end
	Screen.waitVblankStart()
	if Controls.check(Controls.read(),KEY_A) then
		Graphics.freeImage(icon)
		Graphics.freeImage(voice)
		Graphics.freeImage(buttons)
		wav:destroy()
		wav2:destroy()
		if netreceiver then
			Socket.close(netrecv)
			if theme_received then
				Socket.close(client)
			end
			Socket.term()
		end
		Sound.term()
		System.exit()
	elseif Controls.check(Controls.read(), KEY_B) then
		to_scan = true
	elseif Controls.check(pad, KEY_SELECT) and not Controls.check(oldpad, KEY_SELECT) then
		col_idx = col_idx + 1
		if col_idx > #colors then
			col_idx = 1
		end
		wav:color(Color.getR(colors[col_idx][3]),Color.getG(colors[col_idx][3]),Color.getB(colors[col_idx][3]))
		wav2:color(Color.getR(colors[col_idx][3]),Color.getG(colors[col_idx][3]),Color.getB(colors[col_idx][3]))
	end
	oldpad = pad
end
i = 1
i2 = #themes_table
while i <= 3 do
	if i2 > #themes_table then
		i2 = 1
	end
	if is_zip[i2] then
		has_smdh = System.extractFromZIP(System.currentDirectory() .. themes_table[i2].name, "info.smdh", "/tmp.smdh")
		if has_smdh then
			table.insert(preview_info, System.extractSMDH("/tmp.smdh"))
			tmp = Graphics.convertFrom(preview_info[i].icon)
			Screen.freeImage(preview_info[i].icon)
			preview_info[i].icon = tmp
			System.deleteFile("/tmp.smdh")
		else
			p2_tmp = Screen.createImage(48,48, white)
			Screen.debugPrint(5,8,string.sub(themes_table[i2].name,1,3),Color.new(0,0,0),p2_tmp)
			tmp = Graphics.convertFrom(p2_tmp)
			Screen.freeImage(p2_tmp)
			table.insert(preview_info, {["author"] = "Unknown", ["desc"] = "No description.", ["title"] = themes_table[i2].name, ["icon"] = p2})
		end
	else
		if System.doesFileExist(System.currentDirectory() .. themes_table[i2].name .. "/info.smdh") then
			table.insert(preview_info, System.extractSMDH(System.currentDirectory() .. themes_table[i2].name .. "/info.smdh"))
			tmp = Graphics.convertFrom(preview_info[i].icon)
			Screen.freeImage(preview_info[i].icon)
			preview_info[i].icon = tmp
		else
			p2_tmp = Screen.createImage(48,48, white)
			Screen.debugPrint(5,8,string.sub(themes_table[i2].name,1,3),Color.new(0,0,0),p2_tmp)
			p2 = Graphics.convertFrom(p2_tmp)
			Screen.freeImage(p2_tmp)
			table.insert(preview_info, {["author"] = "Unknown", ["desc"] = "No description.", ["title"] = themes_table[i2].name, ["icon"] = p2})
		end
	end
	i2 = i2 + 1
	i = i + 1
end
function LoadIcon(my_idx)
	if is_zip[my_idx] then
		has_smdh = System.extractFromZIP(System.currentDirectory() .. themes_table[my_idx].name, "info.smdh", "/tmp.smdh")
		if has_smdh then
			tmp_v = System.extractSMDH("/tmp.smdh")
			tmp = Graphics.convertFrom(tmp_v.icon)
			Screen.freeImage(tmp_v.icon)
			tmp_v.icon = tmp
			System.deleteFile("/tmp.smdh")
		else
			p2_tmp = Screen.createImage(48,48, white)
			Screen.debugPrint(5,8,string.sub(themes_table[my_idx].name,1,3),Color.new(0,0,0),p2_tmp)
			tmp = Graphics.convertFrom(p2_tmp)
			Screen.freeImage(p2_tmp)
		end
	else
		if System.doesFileExist(System.currentDirectory() .. themes_table[my_idx].name .. "/info.smdh") then
			tmp_v = System.extractSMDH(System.currentDirectory() .. themes_table[my_idx].name .. "/info.smdh")
			tmp = Graphics.convertFrom(tmp_v.icon)
			Screen.freeImage(tmp_v.icon)
		else
			p2_tmp = Screen.createImage(48,48, white)
			Screen.debugPrint(5,8,string.sub(themes_table[my_idx].name,1,3),Color.new(0,0,0),p2_tmp)
			tmp = Graphics.convertFrom(p2_tmp)
			Screen.freeImage(p2_tmp)
		end
	end
	return tmp
end
function ClosePreview()
	if p ~= nil then
		Graphics.freeImage(p)
		Timer.destroy(alpha_transf)
		alpha_transf = nil
		preview = false
		p = nil
	end
end
function PrintPreviewText()
	Font.setPixelSizes(font, 18)
	Font.print(font, 100, 100, "Press        to open theme preview.", white, TOP_SCREEN)
end
function PrintPreviewText2()
	Font.setPixelSizes(font, 18)
	Font.print(font, 100, 165, "Press        to erase current theme.", white, TOP_SCREEN)
	Font.print(font, 100, 190, "Press        to open theme preview.", white, TOP_SCREEN)
end
function PrintPrevButton()
	Font.setPixelSizes(font, 18)
	Graphics.drawPartialImage(137, 102, 34, 0, 17, 15, buttons)
end
function PrintPrevButton2()
	Font.setPixelSizes(font, 18)
	Graphics.drawPartialImage(137, 192, 34, 0, 17, 15, buttons)
	Graphics.drawPartialImage(137, 167, 17, 0, 17, 15, buttons)
end
function PrintShuffleGrid()
	x = 12
	y = 10
	i = 1
	while i <= 10 do
		if i == (shuffle_value + 1) then
			Graphics.drawImage(x, y, icon)
			if i <= #shuffle_themes then
				Graphics.drawScaleImage(x + 5, y + 6, shuffle_themes[i][2], 0.95, 0.95)
			end
		else
			Graphics.drawScaleImage(x + 5, y + 5, icon, 0.8, 0.8)
			if i <= #shuffle_themes then
				Graphics.drawScaleImage(x + 10, y + 11, shuffle_themes[i][2], 0.7, 0.7)
			end
		end
		x = x + 80
		if x == 412 then
			y = y + 80
			x = 12
		end
		i = i + 1
	end
end
function PurgeShuffleTable()
	for i, theme in pairs(shuffle_themes) do
		Graphics.freeImage(theme[2])
	end
	shuffle_themes = {}
	shuffle_value = 0
end
delayer = Timer.new()
while true do
	if theme_received then
		block = Socket.receive(client, 16384)
		if string.len(block) > 0 then
			io.write(new_theme, offs, block, string.len(block))
			offs = offs + string.len(block)
		else
			io.close(new_theme)
			Socket.send(client, "YATA TERM")
			Socket.close(client)
			if auto_extract then
				System.extractZIP("/tmp.zip","/tmp")
				for i,dir in pairs(System.listDirectory("/tmp")) do
					if dir.directory then
						System.createDirectory(System.currentDirectory() .. dir.name)
						filelist = System.listDirectory("/tmp/" .. dir.name)
						for z, file in pairs(filelist) do
							System.renameFile("/tmp/" .. dir.name .. "/" .. file.name, System.currentDirectory() .. dir.name .. "/" .. file.name)
						end
						System.deleteDirectory("/tmp/" .. dir.name)
						table.insert(themes_table, dir)
						System.deleteDirectory("/tmp")
						System.deleteFile("/tmp.zip")
					end
				end
			else
				System.renameFile("/tmp.zip",System.currentDirectory().."/received.zip")
			end
			table.insert(is_zip, not auto_extract)
			Graphics.freeImage(preview_info[1].icon)
			Graphics.freeImage(preview_info[3].icon)
			if idx > 1 then
				ReloadValue(1, idx-1)
			else
				ReloadValue(1, #themes_table)
			end
			ReloadValue(3, idx+1)
			theme_received = false
			client = nil
		end
	else
		if not netreceiver then
			if Network.isWifiEnabled() then
				Socket.init()
				if Network.getIPAddress() ~= "247.7.224.216" then
					netrecv = Socket.createServerSocket(5000)
					netreceiver = true
				end
			end
		else
			if not Network.isWifiEnabled() then
				Socket.close(netrecv)
				Socket.term()
				netreceiver = false
			else
				client = Socket.accept(netrecv)
				if client ~= nil then
					Socket.send(client, "YATA SENDER")
					new_theme = io.open("/tmp.zip",FCREATE)
					offs = 0
					theme_received = true
				end
			end
		end
	end
	if alpha_transf ~= nil then
		if Timer.getTime(alpha_transf) > 3000 and alpha_idx <= 255  then
			if Timer.getTime(alpha_transf) > 3000 + 10 * alpha_idx then
				alpha_idx = alpha_idx + 5
				alpha1 = alpha1 - 5
				alpha2 = alpha2 + 5
				if alpha_idx == 256 then
					Timer.reset(alpha_transf)
				end
			end
		elseif alpha_idx >= 256 and alpha_idx <= 510 then
			if Timer.getTime(alpha_transf) > 3000 + 10 * (alpha_idx - 255) then
				alpha_idx = alpha_idx + 5
				alpha1 = alpha1 + 5
				alpha2 = alpha2 - 5
			end
		elseif alpha_idx > 510 then
			Timer.reset(alpha_transf)
			alpha_idx = 1
		end
	end
	pad = Controls.read()
	Screen.refresh()
	Graphics.initBlend(TOP_SCREEN)
	PrintTopUI()
	if preview then
		PrintPreviews()
	else
		wav:init()
		PrintTopUI2()
		if theme_downloader and not preview then
			ShowDanzeff()
			input = DanzeffInput()
		end
		if not options_menu and not theme_downloader then
			if theme_shuffle == "ON" then
				PrintPrevButton2()
				PrintShuffleGrid()
			else
				PrintPrevButton()
			end
		end
		if Network.isWifiEnabled() then
			Graphics.fillRect(390,395,219,235,Color.new(255, 255, 255))
			Graphics.fillRect(383,388,225,235,Color.new(255, 255, 255))
			Graphics.fillRect(376,381,231,235,Color.new(255, 255, 255))
		end
	end
	Graphics.termBlend()
	Graphics.initBlend(BOTTOM_SCREEN)
	PrintBottomUI()
	wav2:init()
	if not list_style and not options_menu then
		PrintIconsPreview()
		PrintInfoUI()
	end
	if bgm_opening or install_theme or install_themes or theme_received or downloading then
		PrintTopUI2()
	end
	Graphics.termBlend()
	if bgm_opening then
		PrintTitle(false)
		Alert("Opening BGM preview...", BOTTOM_SCREEN)
	elseif install_theme then
		PrintTitle(false)
		Alert("Installing theme...", BOTTOM_SCREEN)
	elseif install_themes then
		PrintTitle(false)
		Alert("Installing shuffle themeset...", BOTTOM_SCREEN)
	elseif theme_received then
		PrintTitle(false)
		Alert("Receiving a themes packet from network...", BOTTOM_SCREEN)
	elseif extracting then
		PrintTitle(false)
		Alert("Extracting theme...", BOTTOM_SCREEN)
	elseif downloading then
		PrintTitle(false)
		Alert("Downloading theme...", BOTTOM_SCREEN)
	else
		PrintTitle(true)
	end
	if not options_menu then
		if list_style then
			PrintThemesList()
		else
			PrintInfo()
		end
	else
		PrintOptionsVoices()
	end		
	if not preview and not theme_downloader then
		PrintThemesInfo()
		if not options_menu then
			if theme_shuffle == "ON" then
				PrintPreviewText2()
			else
				PrintPreviewText()
			end
		end
	end
	if theme_downloader and not preview then
		PrintThemesInfo()
		PrintDownloadMenu()
		if input > 0 then
			if input == 0x09 then
				if string.len(search_word) > 1 then
					search_word = string.sub(search_word,1,string.len(search_word)-1)
				else
					search_word = ""
				end
			else
				search_word = search_word .. string.char(input)
			end
		end
		Font.print(font, 10, 180, "Keyword: "..search_word, white, TOP_SCREEN)
	end
	Screen.flip()
	Screen.waitVblankStart()
	if bgm_opening then
		Timer.pause(alpha_transf)
		if is_zip[idx] then
			bgm_song = Sound.openOgg("/bgm.ogg",false)
			System.deleteFile("/bgm.ogg")
		else
			bgm_song = Sound.openOgg(System.currentDirectory()..themes_table[idx].name.."/BGM.ogg",false)
		end
		Sound.play(bgm_song,LOOP)
		Timer.resume(alpha_transf)
		music = true
		bgm_opening = false
	elseif downloading then
		Network.downloadFile("http://188.166.72.241/3dsthem.es/api?download="..themes_table[idx].id,System.currentDirectory()..themes_table[idx].name..".zip")
		tmp = themes_table[idx].name
		themes_table[idx].name = themes_table[idx].name .. ".zip"
		if auto_extract then
			ExtractTheme(idx, false)
			themes_table[idx].name = tmp
			table.insert(backuped_table, themes_table[idx])
			table.insert(backuped_zip, false)
		else
			new_voice = {}
			new_voice.name = themes_table[idx].name
			table.insert(backuped_table, new_voice)
			table.insert(backuped_zip, true)
			themes_table[idx].name = tmp
		end
		downloading = false
	elseif install_theme then
		if p ~= nil then
			Timer.pause(alpha_transf)
		end
		if is_zip[idx] then
			ExtractTheme(idx, true)
			ChangeTheme("/tmp")
			PurgeTmp()
		else
			ChangeTheme(System.currentDirectory()..themes_table[idx].name)
		end		
		install_theme = false
		if p ~= nil then
			Timer.resume(alpha_transf)
		end
	elseif install_themes then
		if p ~= nil then
			Timer.pause(alpha_transf)
		end
		ChangeMultipleTheme(shuffle_themes)
		install_themes = false
		PurgeShuffleTable()
		if p ~= nil then
			Timer.resume(alpha_transf)
		end
	elseif extracting then
		ExtractTheme(idx, false)
		extracting = false
	end
	if Controls.check(pad, KEY_START) and not Controls.check(oldpad, KEY_START) and not theme_downloader then
		ClosePreview()
		CloseMusic()
		options_menu = not options_menu
		if not options_menu then
			if not list_style then
				Graphics.freeImage(preview_info[1].icon)
				Graphics.freeImage(preview_info[2].icon)
				Graphics.freeImage(preview_info[3].icon)
				ReloadValue(2, idx)
				if idx == 1 then
					o_idx = #themes_table
				else
					o_idx = idx - 1
				end
				ReloadValue(1, o_idx)
				if idx == #themes_table then
					n_idx = 1
				else
					n_idx = idx + 1
				end
				ReloadValue(3, n_idx)
			end
			theme_setting = io.open(System.currentDirectory().."settings.cfg",FCREATE)
			offs = 0
			io.write(theme_setting,offs,"col_idx = " .. col_idx .. "\n",11 + string.len(col_idx))
			offs = 11 + string.len(col_idx)
			if list_style then
				io.write(theme_setting,offs,"list_style = true\n",18)
				offs = offs + 18
			else
				io.write(theme_setting,offs,"list_style = false\n",19)
				offs = offs + 19
			end
			if bgm_preview then
				io.write(theme_setting,offs,"bgm_preview = true\n",19)
				offs = offs + 19
			else
				io.write(theme_setting,offs,"bgm_preview = false\n",20)
				offs = offs + 20
			end
			if auto_extract then
				io.write(theme_setting,offs,"auto_extract = true\n",20)
				offs = offs + 20
			else
				io.write(theme_setting,offs,"auto_extract = false\n",21)
				offs = offs + 21
			end
			io.write(theme_setting,offs,"wave_style = "..wave_style.."\n",15)
			io.close(theme_setting)
		end
	elseif (Controls.check(pad, KEY_START) and not Controls.check(oldpad, KEY_START)) or (theme_downloader and not Network.isWifiEnabled()) then
		Timer.pause(desc_timer)
		Timer.reset(desc_timer)
		ClosePreview()
		theme_downloader = not theme_downloader
		themes_table = backuped_table
		is_zip = backuped_zip
		idx = backuped_idx
		list_style = backuped_list_style
		Graphics.freeImage(preview_info[1].icon)
		Graphics.freeImage(preview_info[2].icon)
		Graphics.freeImage(preview_info[3].icon)
		ReloadValue(2, idx)
		if idx == 1 then
			o_idx = #themes_table
		else
			o_idx = idx - 1
		end
		ReloadValue(1, o_idx)
		if idx == #themes_table then
			n_idx = 1
		else
			n_idx = idx + 1
		end
		ReloadValue(3, n_idx)
	elseif (Controls.check(pad,KEY_B)) and not (Controls.check(oldpad,KEY_B)) and theme_shuffle == "ON" and not options_menu and not theme_downloader then
		if shuffle_value < #shuffle_themes then
			Graphics.freeImage(shuffle_themes[shuffle_value + 1][2])
			table.remove(shuffle_themes, shuffle_value + 1)
		end
	elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) and not theme_downloader then
		if options_menu then
			OptionExecute(opt_idx)
		else
			if theme_shuffle == "OFF" then
				install_theme = true
			else
				-- TODO: Add password support for ZIP themes
				if shuffle_value == #shuffle_themes then
					table.insert(shuffle_themes, {themes_table[idx].name, LoadIcon(idx), is_zip[idx], idx})
				else
					Graphics.freeImage(shuffle_themes[shuffle_value + 1][2])
					shuffle_themes[shuffle_value + 1] = {themes_table[idx].name, LoadIcon(idx), is_zip[idx], idx}
				end
			end
		end
	elseif Controls.check(pad, KEY_Y) and not Controls.check(oldpad, KEY_Y) and not options_menu and not theme_downloader then
		if not preview then
			alpha1 = 255
			alpha2 = 0
			alpha_transf = Timer.new()
			alpha_idx = 1
			if is_zip[idx] and not music and bgm_preview then
				has_bgm = System.extractFromZIP(System.currentDirectory() .. themes_table[idx].name, "bgm.ogg", "/bgm.ogg")
				if has_bgm then
					bgm_opening = true
				end
			elseif System.doesFileExist(System.currentDirectory()..themes_table[idx].name.."/BGM.ogg") and not music and bgm_preview then
				bgm_opening = true
			end
		else
			CloseMusic()
			Graphics.freeImage(p)
			p = nil
			Timer.destroy(alpha_transf)
			alpha_transf = nil
		end
		preview = not preview
	elseif (Controls.check(pad,KEY_X)) and not (Controls.check(oldpad,KEY_X)) and not options_menu and not isShufflehax and not isThemehax and not theme_downloader then
		if theme_shuffle == "ON" then
			if #shuffle_themes > 1 then
				install_themes = true
			elseif #shuffle_themes == 1 then
				PurgeShuffleTable()
			end
			theme_shuffle = "OFF"
		else
			theme_shuffle = "ON"
		end
	elseif (Controls.check(pad,KEY_L)) and not (Controls.check(oldpad,KEY_L)) and not options_menu and not theme_downloader then
		if theme_shuffle == "ON" then
			shuffle_value = shuffle_value - 1
			if shuffle_value < 0 then
				shuffle_value = #shuffle_themes
			end
			if shuffle_value > 9 then
				shuffle_value = 9
			end
		else
			if is_zip[idx] then
				extracting = true
			end
		end
	elseif (Controls.check(pad,KEY_R)) and not (Controls.check(oldpad,KEY_R)) and not options_menu and not theme_downloader then
		if theme_shuffle == "ON" then
			shuffle_value = shuffle_value + 1
			if shuffle_value > #shuffle_themes or shuffle_value > 9 then
				shuffle_value = 0
			end
		elseif Network.isWifiEnabled() then
			backuped_table = themes_table
			backuped_idx = idx
			backuped_zip = is_zip
			backuped_list_style = list_style
			CloseMusic()
			Timer.pause(desc_timer)
			Timer.reset(desc_timer)
			ClosePreview()
			theme_downloader = not theme_downloader
			ExecSearchQuery("http://188.166.72.241/3dsthem.es/api?lua&popular")
			search_word = ""			
			list_style = false
			dwnld_idx = 1
		end
	elseif Controls.check(pad, KEY_DLEFT) and Timer.getTime(delayer) > 200 and (not options_menu) then
		CloseMusic()
		Timer.pause(desc_timer)
		Timer.reset(desc_timer)
		ClosePreview()
		if list_style then
			idx = idx - 8
			if idx < 1 then
				idx = 1
			end
		else
			idx = idx - 1
			if idx < 1 then
				idx = #themes_table
			end
		end
		if not list_style then
			MoveCursorLeft(idx)
		else
			if (idx >= 8) then
				master_index = idx - 7
			else
				master_index = 0
			end
		end
		Timer.reset(delayer)
	elseif Controls.check(pad, KEY_DRIGHT) and Timer.getTime(delayer) > 200 and (not options_menu) then
		CloseMusic()
		Timer.pause(desc_timer)
		Timer.reset(desc_timer)
		ClosePreview()
		if list_style then
			idx = idx + 8
			if idx > #themes_table then
				idx = #themes_table
			end
		else
			idx = idx + 1
			if idx > #themes_table then
				idx = 1
			end
		end
		if not list_style then
			MoveCursorRight(idx)
		else
			if (idx >= 9) then
				master_index = idx - 7
			end
		end
		Timer.reset(delayer)
	elseif Controls.check(pad, KEY_SELECT) and not Controls.check(oldpad, KEY_SELECT) then
		if theme_downloader then
			if dwnld_idx == 1 then
				downloading = true
			elseif dwnld_idx == 2 then
				Network.downloadFile("http://188.166.72.241/3dsthem.es/api?preview="..themes_table[idx].id,"/chmm_tmp.png")
				alpha1 = 255
				alpha2 = 0
				alpha_transf = Timer.new()
				alpha_idx = 1
				preview = true
			else
				ExecSearchQuery(GenerateQuery(search_word))
			end
		else
			col_idx = col_idx + 1
			if col_idx > #colors then
				col_idx = 1
			end
			wav:color(Color.getR(colors[col_idx][3]),Color.getG(colors[col_idx][3]),Color.getB(colors[col_idx][3]))
			wav2:color(Color.getR(colors[col_idx][3]),Color.getG(colors[col_idx][3]),Color.getB(colors[col_idx][3]))
		end
	elseif (Controls.check(pad,KEY_DUP)) and Timer.getTime(delayer) > 200 then
		if options_menu then
			opt_idx = opt_idx - 1
			if opt_idx < 1 then
				opt_idx = #opt_voices
			end
		elseif list_style then
			CloseMusic()
			ClosePreview()
			idx = idx - 1
			if idx < 1 then
				idx = #themes_table
			end
			if (idx >= 8) then
				master_index = idx - 7
			end
		elseif theme_downloader then
			dwnld_idx = dwnld_idx - 1
			if dwnld_idx < 1 then
				dwnld_idx = #downloader_voices
			end
		end
		Timer.reset(delayer)
	elseif (Controls.check(pad,KEY_DDOWN)) and Timer.getTime(delayer) > 200 then
		if options_menu then
			opt_idx = opt_idx + 1
			if opt_idx > #opt_voices then
				opt_idx = 1
			end
		elseif list_style then
			desc_i = 1
			Timer.pause(desc_timer)
			Timer.reset(desc_timer)
			CloseMusic()
			ClosePreview()
			idx = idx + 1
			if idx > #themes_table then
				idx = 1
				master_index = 0
			end
			if (idx >= 9) then
				master_index = idx- 7
			end
		elseif theme_downloader then
			dwnld_idx = dwnld_idx + 1
			if dwnld_idx > #downloader_voices then
				dwnld_idx = 1
			end
		end
		Timer.reset(delayer)
	end
	oldpad = pad
end