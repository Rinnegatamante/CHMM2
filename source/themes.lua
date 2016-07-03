-- Checking if themehax/shufflehax is installed
local archive
local archive2
local isShufflehax = false
local isThemehax = false
local reg = System.getRegion()
local tmp_handle
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
tmp = openFile("/SaveData.dat",FREAD,archive2)
local shuffle_flag = string.byte(readFile(tmp,0x141B,1))
if shuffle_flag == 1 then -- shufflehax?
	shuffle_idx = string.byte(readFile(tmp, 0x13C0, 1))
	if shuffle_idx == 0xFF then
		isShufflehax = true
	end
else -- themehax?
	local function checkThemehax()
		tmp_handle = openFile("/yhemeManage.bin",FREAD,archive)
	end
	local isThemehax = pcall(checkThemehax)
	if isThemehax then
		closeFile(tmp_handle)
	end
end
closeFile(tmp)

-- DumpTheme: Dump in-use theme
local function DumpTheme()
	while doesFileExist(System.currentDirectory().."Dumped_"..dump_idx.."/body_LZ.bin") do
		dump_idx = dump_idx + 1
	end
	theme_folder = System.currentDirectory().."Dumped_"..dump_idx
	System.createDirectory(theme_folder)
	if isShufflehax or isThemehax then
		body_f = "/yodyCache.bin"
		theme_f = "/yhemeManage.bin"
	else
		body_f = "/BodyCache.bin"
		theme_f = "/ThemeManage.bin"
	end
	inp = openFile(theme_f, FREAD, archive)
	if isShufflehax then
		body_size = hex2num(readFile(inp,0x338,4))
		bgm_size = hex2num(readFile(inp,0x360,4))
	else
		body_size = hex2num(readFile(inp,0x08,4))
		bgm_size = hex2num(readFile(inp,0x0C,4))
	end
	closeFile(inp)
	inp = openFile(body_f, FREAD, archive)
	body_data = readFile(inp, 0, body_size)
	closeFile(inp)
	out = openFile(theme_folder.."/body_LZ.bin",FCREATE)
	writeFile(out, 0, body_data, body_size)
	closeFile(out)
	inp = openFile("/BgmCache.bin", FREAD, archive)
	bgm_data = readFile(inp, 0, bgm_size)
	closeFile(inp)
	out = openFile(theme_folder.."/bgm.bcstm",FCREATE)
	writeFile(out,0,bgm_data,bgm_size)
	closeFile(out)
	table.insert(themes_table, {["name"] = "Dumped_"..dump_idx})
	table.insert(is_zip, false)
	table.insert(zip_pass, nil)
end

-- ExtractTheme: Extract a ZIP theme
local function ExtractTheme(t_idx, is_temp)
	local filename = System.currentDirectory() .. themes_table[t_idx].name
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

-- ReloadValue: Reloads cached values for an indexed theme
local function ReloadValue(p_idx, t_idx)
	if theme_downloader then
		p2_tmp = Screen.createImage(48,48, white)
		debugPrint(5,8,string.sub(themes_table[t_idx].name,1,3),genColor(0,0,0),p2_tmp)
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
			debugPrint(5,8,string.sub(themes_table[t_idx].name,1,3),genColor(0,0,0),p2_tmp)
			tmp = Graphics.convertFrom(p2_tmp)
			Screen.freeImage(p2_tmp)
			preview_info[p_idx] = {["author"] = "Unknown", ["desc"] = "No description.", ["title"] = themes_table[t_idx].name, ["icon"] = tmp}
		end
	else
		if doesFileExist(System.currentDirectory() .. themes_table[t_idx].name .. "/info.smdh") then
			preview_info[p_idx] =  System.extractSMDH(System.currentDirectory() .. themes_table[t_idx].name .. "/info.smdh")
			tmp = Graphics.convertFrom(preview_info[p_idx].icon)
			Screen.freeImage(preview_info[p_idx].icon)
			preview_info[p_idx].icon = tmp
		else
			p2_tmp = Screen.createImage(48,48, white)
			debugPrint(5,8,string.sub(themes_table[t_idx].name,1,3),genColor(0,0,0),p2_tmp)
			p2 = Graphics.convertFrom(p2_tmp)
			Screen.freeImage(p2_tmp)
			preview_info[p_idx] = {["author"] = "Unknown", ["desc"] = "No description.", ["title"] = themes_table[t_idx].name, ["icon"] = p2}
		end	
	end
end

-- ChangeTheme: Installs a new theme
local function ChangeTheme(theme)
	if isShufflehax or isThemehax then
		body_f = "/yodyCache.bin"
		theme_f = "/yhemeManage.bin"
	else
		savedata = openFile("/SaveData.dat",FWRITE,archive2)
		writeFile(savedata,0x141B,string.char(0),1)
		writeFile(savedata,0x13B8,string.char(0xFF,0,0,0,0,3,0,0),8)
		closeFile(savedata)
		body_f = "/BodyCache.bin"
		theme_f = "/ThemeManage.bin"
	end
	if doesFileExist(theme.."/body_LZ.bin") then
		body = openFile(theme.."/body_LZ.bin",FREAD)
		body_size = getSize(body)
		out = openFile(body_f,FWRITE,archive)
		to_write = readFile(body,0,body_size)
		if isShufflehax then
			out2 = openFile("/yodyCache_rd.bin",FWRITE,archive)
			writeFile(out2,0,to_write,body_size)
			writeFile(out2,0x2A0000,to_write,body_size)
			closeFile(out2)
		end
		writeFile(out,0,to_write,body_size)
		closeFile(out)
		closeFile(body)
	else
		body_size = 0
	end
	if doesFileExist(theme.."/bgm.bcstm") then
		bgm = openFile(theme.."/bgm.bcstm",FREAD)
		bgm_size = getSize(bgm)
		to_write = readFile(bgm,0,bgm_size)
		if isShufflehax then
			out2 = openFile("/BgmCache_00.bin",FWRITE,archive)
			writeFile(out2,0,to_write,bgm_size)
			closeFile(out2)
			out2 = openFile("/BgmCache_02.bin",FWRITE,archive)
			writeFile(out2,0,to_write,bgm_size)
			closeFile(out2)
		end
		out = openFile("/BgmCache.bin",FWRITE,archive)
		writeFile(out,0,to_write,bgm_size)
		closeFile(out)
		closeFile(bgm)
	else
		bgm_size = 0
	end
	if doesFileExist(theme.."/ThemeManage.bin") and not isShufflehax then
		tm = openFile(theme.."/ThemeManage.bin",FREAD)
		tm_size = getSize(tm)
		out = openFile(theme_f,FWRITE,archive)
		writeFile(out,0,readFile(tm,0,tm_size),tm_size)
		closeFile(out)
		closeFile(tm)
	elseif isShufflehax then
		out = openFile(theme_f,FWRITE,archive)
		writeFile(out,0x338,u32toString(body_size),4)
		writeFile(out,0x340,u32toString(body_size),4)
		writeFile(out,0x360,u32toString(bgm_size),4)
		writeFile(out,0x368,u32toString(bgm_size),4)
		closeFile(out)
	else
		out = openFile(theme_f,FWRITE,archive)	
		writeFile(out,0x00,string.char(1),1)
		writeFile(out,0x01,string.char(0,0,0,0,0,0,0),7)
		writeFile(out,0x08,u32toString(body_size),4)
		writeFile(out,0x0C,u32toString(bgm_size),4)
		writeFile(out,0x10,string.char(0xFF),1)
		writeFile(out,0x14,string.char(0x01),1)
		writeFile(out,0x18,string.char(0xFF),1)
		writeFile(out,0x1D,string.char(0x02),1)
		writeFile(out,0x338,u32toString(0),4)
		writeFile(out,0x340,u32toString(0),4)
		writeFile(out,0x360,u32toString(0),4)
		writeFile(out,0x368,u32toString(0),4)
		closeFile(out)
	end
end

-- ChangeMultipleTheme: Installs a new themeset
local function ChangeMultipleTheme(themes)
	body_sizes = {}
	bgm_sizes = {}
	savedata = openFile("/SaveData.dat",FWRITE,archive2)
	writeFile(savedata,0x141B,string.char(1),1)
	writeFile(savedata,0x13B8,string.char(0,0,0,0,0,0,0,0),8)
	i = 0
	while i < 10 do
		savedata_offset = 0x13C0 + 0x8 * i
		if i < #themes then
			if themes[i + 1][3] then
				ExtractTheme(themes[i + 1][4], true)
				System.renameDirectory("/tmp","/tmp"..i)
			end
			writeFile(savedata,savedata_offset,string.char(i,0,0,0,0,3,0,0),8)
		else
			writeFile(savedata,savedata_offset,string.char(0,0,0,0,0,0,0,0),8)
		end
		i = i + 1
	end
	closeFile(savedata)
	i = 0
	out = openFile("/BodyCache_rd.bin",FWRITE,archive)
	while i < 10 do
		body_offset = 0x150000 * i
		if i < #themes then
			theme = themes[i + 1][1]
			if doesFileExist(System.currentDirectory()..theme.."/body_LZ.bin") then
				body = openFile(System.currentDirectory()..theme.."/body_LZ.bin",FREAD)
				body_size = getSize(body)
				writeFile(out,body_offset,readFile(body,0,body_size),body_size)
				closeFile(body)
			elseif doesFileExist("/tmp"..i.."/body_LZ.bin") and themes[i + 1][3] then
				body = openFile("/tmp"..i.."/body_LZ.bin",FREAD)
				body_size = getSize(body)
				writeFile(out,body_offset,readFile(body,0,body_size),body_size)
				closeFile(body)
			else
				body_size = 0
			end
		else
			body_size = 0
		end
		table.insert(body_sizes, body_size)
		i = i + 1
	end
	closeFile(out)
	i = 0
	while i < 10 do
		if i < #themes then
			theme = themes[i + 1][1]
			if doesFileExist(System.currentDirectory()..theme.."/bgm.bcstm") then
				bgm = openFile(System.currentDirectory()..theme.."/bgm.bcstm",FREAD)
				bgm_size = getSize(bgm)
				out = openFile("/BgmCache_0"..i..".bin",FWRITE,archive)
				writeFile(out,0,readFile(bgm,0,bgm_size),bgm_size)
				closeFile(out)
				closeFile(bgm)
			elseif doesFileExist("/tmp"..i.."/bgm.bcstm") and themes[i + 1][3] then
				bgm = openFile("/tmp"..i.."/bgm.bcstm",FREAD)
				bgm_size = getSize(bgm)
				out = openFile("/BgmCache_0"..i..".bin",FWRITE,archive)
				writeFile(out,0,readFile(bgm,0,bgm_size),bgm_size)
				closeFile(out)
				closeFile(bgm)
			else
				bgm_size = 0
			end
		else
			bgm_size = 0
		end
		table.insert(bgm_sizes, bgm_size)
		i = i + 1
	end
	out = openFile("/ThemeManage.bin",FWRITE,archive)
	writeFile(out,0x00,string.char(1),1)
	writeFile(out,0x01,string.char(0,0,0,0,0,0,0),7)
	writeFile(out,0x08,string.char(0,0,0,0),4)
	writeFile(out,0x0C,string.char(0,0,0,0),4)
	writeFile(out,0x10,string.char(0xFF),1)
	writeFile(out,0x14,string.char(0x01),1)
	writeFile(out,0x18,string.char(0xFF),1)
	writeFile(out,0x1D,string.char(0x02),1)
	i = 0
	while i < 10 do
		mng_body_offset = 0x338 + 0x4 * i
		mng_bgm_offset = 0x360 + 0x4 * i
		writeFile(out,mng_body_offset,u32toString(body_sizes[i + 1]),4)
		writeFile(out,mng_bgm_offset,u32toString(bgm_sizes[i + 1]),4)
		if i < #themes then
			if themes[i + 1][3] then
				PurgeDir("/tmp"..i)
			end
		end
		i = i + 1
	end
	closeFile(out)
end

-- MoveCursorLeft: Move themes cursor left (Ringmenu)
local function MoveCursorLeft(t_idx)
	Graphics.freeImage(preview_info[3].icon)
	preview_info[3] = preview_info[2]
	preview_info[2] = preview_info[1]
	t_idx = t_idx - 1
	if t_idx < 1 then
		t_idx = #themes_table
	end
	ReloadValue(1, t_idx)
end

-- MoveCursorLeft: Move themes cursor right (Ringmenu)
local function MoveCursorRight(t_idx)
	Graphics.freeImage(preview_info[1].icon)
	preview_info[1] = preview_info[2]
	preview_info[2] = preview_info[3]
	t_idx = t_idx + 1
	if t_idx > #themes_table then
		t_idx = 1
	end
	ReloadValue(3, t_idx)
end

-- CloseMusic: Stops BGM preview of a theme
function CloseMusic()
	if music then
		Sound.close(bgm_song)
		music = false
	end
end

-- LoadPreview: Loads preview for a theme
function LoadPreview()
	if theme_downloader then
		p = loadImage("/chmm_tmp.png")
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
			p_tmp = Screen.createImage(400,240, genColor(0,0,0))
			p = Graphics.convertFrom(p_tmp)
			Screen.freeImage(p_tmp)
		else
			p = loadImage("/preview.png")
			System.deleteFile("/preview.png")
		end
	elseif doesFileExist(System.currentDirectory() .. themes_table[idx].name .. "/preview.png") then
		p = loadImage(System.currentDirectory() .. themes_table[idx].name .. "/preview.png")
	elseif doesFileExist(System.currentDirectory() .. themes_table[idx].name .. "/preview.jpg") then
		p = loadImage(System.currentDirectory() .. themes_table[idx].name .. "/preview.jpg")
	elseif doesFileExist(System.currentDirectory() .. themes_table[idx].name .. "/preview.bmp") then
		p = loadImage(System.currentDirectory() .. themes_table[idx].name .. "/preview.bmp")
	else
		p_tmp = Screen.createImage(400,240, genColor(0,0,0))
		p = Graphics.convertFrom(p_tmp)
		Screen.freeImage(p_tmp)
	end
	r_width = Graphics.getImageWidth(p)
	r_height = Graphics.getImageHeight(p)
	if r_width == 400 and r_height >= 480 then
		img_type = "YATA"
	elseif r_width == 432 and r_height == 528 then
		img_type = "SSHOT"
	elseif r_width == 412 and r_height >= 480 then
		img_type = "USAGI"
	else
		img_type = "UNKNWN"
	end
end

-- LoadIcon: Extract theme icon from an smdh file
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
			debugPrint(5,8,string.sub(themes_table[my_idx].name,1,3),genColor(0,0,0),p2_tmp)
			tmp = Graphics.convertFrom(p2_tmp)
			Screen.freeImage(p2_tmp)
		end
	else
		if doesFileExist(System.currentDirectory() .. themes_table[my_idx].name .. "/info.smdh") then
			tmp_v = System.extractSMDH(System.currentDirectory() .. themes_table[my_idx].name .. "/info.smdh")
			tmp = Graphics.convertFrom(tmp_v.icon)
			Screen.freeImage(tmp_v.icon)
		else
			p2_tmp = Screen.createImage(48,48, white)
			debugPrint(5,8,string.sub(themes_table[my_idx].name,1,3),genColor(0,0,0),p2_tmp)
			tmp = Graphics.convertFrom(p2_tmp)
			Screen.freeImage(p2_tmp)
		end
	end
	return tmp
end

-- ClosePreview: Stops preview mode
function ClosePreview()
	if p ~= nil then
		Graphics.freeImage(p)
		Timer.destroy(alpha_transf)
		alpha_transf = nil
		preview = false
		p = nil
	end
end