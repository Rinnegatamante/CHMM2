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
tmp = io.open("/SaveData.dat",FREAD,archive2)
local shuffle_flag = string.byte(io.read(tmp,0x141B,1))
if shuffle_flag == 1 then -- shufflehax?
	shuffle_idx = string.byte(io.read(tmp, 0x13C0, 1))
	if shuffle_idx == 0xFF then
		isShufflehax = true
	end
else -- themehax?
	local function checkThemehax()
		tmp_handle = io.open("/yhemeManage.bin",FREAD,archive)
	end
	local isThemehax = pcall(checkThemehax)
	if isThemehax then
		io.close(tmp_handle)
	end
end
io.close(tmp)

-- DumpTheme: Dump in-use theme
local function DumpTheme()
	while System.doesFileExist(System.currentDirectory().."Dumped_"..dump_idx.."/body_LZ.bin") do
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
	inp = io.open(theme_f, FREAD, archive)
	if isShufflehax then
		body_size = hex2num(io.read(inp,0x338,4))
		bgm_size = hex2num(io.read(inp,0x360,4))
	else
		body_size = hex2num(io.read(inp,0x08,4))
		bgm_size = hex2num(io.read(inp,0x0C,4))
	end
	io.close(inp)
	inp = io.open(body_f, FREAD, archive)
	body_data = io.read(inp, 0, body_size)
	io.close(inp)
	out = io.open(theme_folder.."/body_LZ.bin",FCREATE)
	io.write(out, 0, body_data, body_size)
	io.close(out)
	inp = io.open("/BgmCache.bin", FREAD, archive)
	bgm_data = io.read(inp, 0, bgm_size)
	io.close(inp)
	out = io.open(theme_folder.."/bgm.bcstm",FCREATE)
	io.write(out,0,bgm_data,bgm_size)
	io.close(out)
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

-- ChangeTheme: Installs a new theme
local function ChangeTheme(theme)
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
		io.write(out,0x338,u32toString(0),4)
		io.write(out,0x340,u32toString(0),4)
		io.write(out,0x360,u32toString(0),4)
		io.write(out,0x368,u32toString(0),4)
		io.close(out)
	end
end

-- ChangeMultipleTheme: Installs a new themeset
local function ChangeMultipleTheme(themes)
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