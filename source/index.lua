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
if System.checkBuild() == 2 then -- Patch to disable broken socketing features on NH2
	old_funcs = {["init"] = Socket.init,
				 ["term"] = Socket.term,
				 ["createServerSocket"] = Socket.createServerSocket,
				 ["accept"] = Socket.accept,
				 ["receive"] = Socket.receive,
				 ["send"] = Socket.send,
				 ["close"] = Socket.close,
				}
	function Socket.init()
		return nil
	end
	function Socket.term()
		return nil
	end
	function Socket.createServerSocket(stub)
		return nil
	end
	function Socket.accept(stub)
		return nil
	end
	function Socket.receive(stub, stub)
		return nil
	end
	function Socket.send(stub)
		return nil
	end
	function Socket.close(stub)
		return nil
	end
end
konami_code = {KEY_DUP, KEY_DUP, KEY_DDOWN, KEY_DDOWN, KEY_DLEFT, KEY_DRIGHT, KEY_DLEFT, KEY_DRIGHT, KEY_B, KEY_A}
konami_idx = 1
opt_idx = 1
if list_style == nil then
	list_style = false
end
options_menu = false
if list_style then
	opt_voices = {"Listing mode: Textlist", "Exit CHMM2"}
else
	opt_voices = {"Listing mode: Ringmenu", "Exit CHMM2"}
end
function OptionExecute(voice_num)
	if voice_num == 1 then
		list_style = not list_style
		if list_style then
			opt_voices[1] = "Listing mode: Textlist"
		else
			opt_voices[1] = "Listing mode: Ringmenu"
		end
	elseif voice_num == 2 then
		options_menu = not options_menu
		Graphics.freeImage(preview_info[1].icon)
		Graphics.freeImage(preview_info[2].icon)
		Graphics.freeImage(preview_info[3].icon)
		Graphics.freeImage(icon)
		Graphics.freeImage(voice)
		Graphics.freeImage(buttons)
		CloseMusic()
		Timer.destroy(konami_delayer)
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
		if p ~= nil then
			Graphics.freeImage(p)
		end
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
konami_todo = true
version = "2.1 BETA"
bgm_opening = false
Graphics.init()
shuffle_themes = {}
jump_oldpad = false
select_shuffle = false
Sound.init()
theme_received = false
netreceiver = false
install_themes = false
theme_shuffle = "OFF"
shuffle_value = 0
font = Font.loadMain()
icon, buttons, voice = Graphics.loadAssets()
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
	if System.doesFileExist(System.currentDirectory() .. themes_table[t_idx].name .. "/info.smdh") then
		preview_info[p_idx] =  System.extractSMDH(System.currentDirectory() .. themes_table[t_idx].name .. "/info.smdh")
		tmp = Graphics.convertFrom(preview_info[p_idx].icon)
		Screen.freeImage(preview_info[p_idx].icon)
		preview_info[p_idx].icon = tmp
	else
		p2_tmp = Screen.createImage(48,48, Color.new(255,255,255))
		Screen.debugPrint(5,8,string.sub(themes_table[t_idx].name,1,3),Color.new(0,0,0),p2_tmp)
		p2 = Graphics.convertFrom(p2_tmp)
		Screen.freeImage(p2_tmp)
		preview_info[p_idx] = {["author"] = "Unknown", ["desc"] = "No description.", ["title"] = themes_table[t_idx].name, ["icon"] = p2}
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
end
function PrintInfo()
	Font.setPixelSizes(font, 20)
	Font.print(font, 17, 157, preview_info[2].title, colors[col_idx][1], BOTTOM_SCREEN)
	Font.setPixelSizes(font, 16)
	Font.print(font, 17, 189, preview_info[2].desc, Color.new(0, 0, 0), BOTTOM_SCREEN)
	Font.setPixelSizes(font, 12)
	Font.print(font, 17, 175, "By " .. preview_info[2].author, colors[col_idx][1], BOTTOM_SCREEN)
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
		Sound.pause(bgm)
		Sound.close(bgm)
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
	savedata = io.open("/SaveData.dat",FWRITE,archive2)
	io.write(savedata,0x141B,string.char(0),1)
	io.write(savedata,0x13B8,string.char(0xFF,0,0,0,0,3,0,0),8)
	io.close(savedata)
	if System.doesFileExist(theme.."/body_LZ.bin") then
		body = io.open(theme.."/body_LZ.bin",FREAD)
		body_size = io.size(body)
		out = io.open("/BodyCache.bin",FWRITE,archive)
		io.write(out,0,io.read(body,0,body_size),body_size)
		io.close(out)
		io.close(body)
	else
		body_size = 0
	end
	if System.doesFileExist(theme.."/bgm.bcstm") then
		bgm = io.open(theme.."/bgm.bcstm",FREAD)
		bgm_size = io.size(bgm)
		out = io.open("/BgmCache.bin",FWRITE,archive)
		io.write(out,0,io.read(bgm,0,bgm_size),bgm_size)
		io.close(out)
		io.close(bgm)
	else
		bgm_size = 0
	end
	if System.doesFileExist(theme.."/ThemeManage.bin") then
		tm = io.open(theme.."/ThemeManage.bin",FREAD)
		tm_size = io.size(tm)
		out = io.open("/ThemeManage.bin",FWRITE,archive)
		io.write(out,0,io.read(tm,0,tm_size),tm_size)
		io.close(out)
		io.close(tm)
	else
		out = io.open("/ThemeManage.bin",FWRITE,archive)	
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
	savedata = io.open("/SaveData.dat",FWRITE,archive2)
	io.write(savedata,0x141B,string.char(1),1)
	io.write(savedata,0x13B8,string.char(0,0,0,0,0,0,0,0),8)
	i = 0
	while i < 10 do
		savedata_offset = 0x13C0 + 0x8 * i
		if i < #themes then
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
	io.write(out,0x08,string.char(0,0,0,0),4)
	io.write(out,0x0C,string.char(0,0,0,0),4)
	i = 0
	while i < 10 do
		mng_body_offset = 0x338 + 0x4 * i
		mng_bgm_offset = 0x360 + 0x4 * i
		io.write(out,mng_body_offset,u32toString(body_sizes[i + 1]),4)
		io.write(out,mng_bgm_offset,u32toString(bgm_sizes[i + 1]),4)
		i = i + 1
	end
	io.close(out)
end
function LoadPreview()
	if System.doesFileExist(System.currentDirectory() .. themes_table[idx].name .. "/preview.png") then
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
	Font.print(font, 5, 220, "Detected Themes: " .. #themes_table .. "           Theme Shuffle: " .. theme_shuffle, Color.new(255, 255, 255), TOP_SCREEN)
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
themes_table = SortDirectory(System.listDirectory(System.currentDirectory()))
preview_info = {}
wav = LoadWave(1,600, 0.1, 2, 400)
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
	if System.doesFileExist(System.currentDirectory() .. themes_table[i2].name .. "/info.smdh") then
		table.insert(preview_info, System.extractSMDH(System.currentDirectory() .. themes_table[i2].name .. "/info.smdh"))
		tmp = Graphics.convertFrom(preview_info[i].icon)
		Screen.freeImage(preview_info[i].icon)
		preview_info[i].icon = tmp
	else
		p2_tmp = Screen.createImage(48,48, Color.new(255,255,255))
		Screen.debugPrint(5,8,string.sub(themes_table[i2].name,1,3),Color.new(0,0,0),p2_tmp)
		p2 = Graphics.convertFrom(p2_tmp)
		Screen.freeImage(p2_tmp)
		table.insert(preview_info, {["author"] = "Unknown", ["desc"] = "No description.", ["title"] = themes_table[i2].name, ["icon"] = p2})
	end
	i2 = i2 + 1
	i = i + 1
end
function LoadIcon(my_idx)
	if System.doesFileExist(System.currentDirectory() .. themes_table[my_idx].name .. "/info.smdh") then
		tmp_v = System.extractSMDH(System.currentDirectory() .. themes_table[my_idx].name .. "/info.smdh")
		tmp = Graphics.convertFrom(tmp_v.icon)
		Screen.freeImage(tmp_v.icon)
	else
		p2_tmp = Screen.createImage(48,48, Color.new(255,255,255))
		Screen.debugPrint(5,8,string.sub(themes_table[my_idx].name,1,3),Color.new(0,0,0),p2_tmp)
		tmp = Graphics.convertFrom(p2_tmp)
		Screen.freeImage(p2_tmp)
	end
	return tmp
end
function PrintPreviewText()
	Font.setPixelSizes(font, 18)
	Font.print(font, 100, 100, "Press        to open theme preview.", Color.new(255,255,255), TOP_SCREEN)
end
function PrintPreviewText2()
	Font.setPixelSizes(font, 18)
	Font.print(font, 100, 165, "Press        to erase current theme.", Color.new(255,255,255), TOP_SCREEN)
	Font.print(font, 100, 190, "Press        to open theme preview.", Color.new(255,255,255), TOP_SCREEN)
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
konami_delayer = Timer.new()
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
		if not options_menu then
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
	if bgm_opening or install_theme or install_themes or theme_received then
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
	if not preview then
		PrintThemesInfo()
		if not options_menu then
			if theme_shuffle == "ON" then
				PrintPreviewText2()
			else
				PrintPreviewText()
			end
		end
	end
	Screen.flip()
	Screen.waitVblankStart()
	if bgm_opening then
		Timer.pause(alpha_transf)
		bgm = Sound.openOgg(System.currentDirectory()..themes_table[idx].name.."/BGM.ogg",false)
		Sound.play(bgm,LOOP,0x08,0x09)
		Timer.resume(alpha_transf)
		music = true
		bgm_opening = false
	end
	if install_theme then
		if p ~= nil then
			Timer.pause(alpha_transf)
		end
		ChangeTheme(System.currentDirectory()..themes_table[idx].name)
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
	end
	if konami_todo and Controls.check(pad, konami_code[konami_idx]) and not Controls.check(oldpad, konami_code[konami_idx]) then
		if Controls.check(pad, KEY_B) then
			pad = KEY_DUP
			oldpad = KEY_B
			jump_oldpad = true
		elseif Controls.check(pad, KEY_A) then
			pad = KEY_DUP
			oldpad = KEY_A
			jump_oldpad = true
		end
		konami_idx = konami_idx + 1
		Timer.reset(konami_delayer)
		if konami_idx > #konami_code then
			konami_todo = false
			wav:destroy()
			wav = LoadWave(15, 600, 0.1, 3, 400)
			wav:color(Color.getR(colors[col_idx][3]),Color.getG(colors[col_idx][3]),Color.getB(colors[col_idx][3]))
		end
	elseif Timer.getTime(konami_delayer) > 500 then
		konami_idx = 1
		Timer.reset(konami_delayer)
	end
	if Controls.check(pad, KEY_START) and not Controls.check(oldpad, KEY_START) then
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
			io.write(theme_setting,0,"col_idx = " .. col_idx .. "\n",11 + string.len(col_idx))
			if list_style then
				io.write(theme_setting,11 + string.len(col_idx),"list_style = true\n",18)
			else
				io.write(theme_setting,11 + string.len(col_idx),"list_style = false\n",19)
			end
			io.close(theme_setting)
		end
	elseif (Controls.check(pad,KEY_B)) and not (Controls.check(oldpad,KEY_B)) and theme_shuffle == "ON" and not options_menu then
		if shuffle_value < #shuffle_themes then
			Graphics.freeImage(shuffle_themes[shuffle_value + 1][2])
			table.remove(shuffle_themes, shuffle_value + 1)
		end
	elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
		if options_menu then
			OptionExecute(opt_idx)
		else
			if theme_shuffle == "OFF" then
				install_theme = true
			else
				if shuffle_value == #shuffle_themes then
					table.insert(shuffle_themes, {themes_table[idx].name, LoadIcon(idx)})
				else
					Graphics.freeImage(shuffle_themes[shuffle_value + 1][2])
					shuffle_themes[shuffle_value + 1] = {themes_table[idx].name, LoadIcon(idx)}
				end
			end
		end
	elseif Controls.check(pad, KEY_Y) and not Controls.check(oldpad, KEY_Y) and not options_menu then
		if not preview then
			alpha1 = 255
			alpha2 = 0
			alpha_transf = Timer.new()
			alpha_idx = 1
			if System.doesFileExist(System.currentDirectory()..themes_table[idx].name.."/BGM.ogg") and not music then
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
	elseif (Controls.check(pad,KEY_X)) and not (Controls.check(oldpad,KEY_X)) and not options_menu then
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
	elseif (Controls.check(pad,KEY_L)) and not (Controls.check(oldpad,KEY_L)) and theme_shuffle == "ON" and not options_menu then
		shuffle_value = shuffle_value - 1
		if shuffle_value < 0 then
			shuffle_value = #shuffle_themes
		end
		if shuffle_value > 9 then
			shuffle_value = 9
		end
	elseif (Controls.check(pad,KEY_R)) and not (Controls.check(oldpad,KEY_R)) and theme_shuffle == "ON" and not options_menu then
		shuffle_value = shuffle_value + 1
		if shuffle_value > #shuffle_themes or shuffle_value > 9 then
			shuffle_value = 0
		end
	elseif Controls.check(pad, KEY_DLEFT) and Timer.getTime(delayer) > 200 and not options_menu then
		CloseMusic()
		if p ~= nil then
			Graphics.freeImage(p)
			Timer.destroy(alpha_transf)
			alpha_transf = nil
			preview = false
			p = nil
		end
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
	elseif Controls.check(pad, KEY_DRIGHT) and Timer.getTime(delayer) > 200 and not options_menu then
		CloseMusic()
		if p ~= nil then
			Graphics.freeImage(p)
			Timer.destroy(alpha_transf)
			alpha_transf = nil
			preview = false
			p = nil
		end
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
	elseif Controls.check(pad, KEY_TOUCH) and not Controls.check(oldpad, KEY_TOUCH) then
		if s_idx == nil then
			s_idx = 0
		else
			s_idx = s_idx + 1
		end
		System.takeScreenshot("/CHMM2_"..s_idx..".bmp",false)
	elseif Controls.check(pad, KEY_SELECT) and not Controls.check(oldpad, KEY_SELECT) then
		col_idx = col_idx + 1
		if col_idx > #colors then
			col_idx = 1
		end
		wav:color(Color.getR(colors[col_idx][3]),Color.getG(colors[col_idx][3]),Color.getB(colors[col_idx][3]))
		wav2:color(Color.getR(colors[col_idx][3]),Color.getG(colors[col_idx][3]),Color.getB(colors[col_idx][3]))
		theme_setting = io.open(System.currentDirectory().."settings.cfg",FCREATE)
		io.write(theme_setting,0,"col_idx = " .. col_idx .. "\n",11 + string.len(col_idx))
		if list_style then
			io.write(theme_setting,11 + string.len(col_idx),"list_style = true\n",18)
		else
			io.write(theme_setting,11 + string.len(col_idx),"list_style = false\n",19)
		end
		io.close(theme_setting)
	elseif (Controls.check(pad,KEY_DUP)) and Timer.getTime(delayer) > 200 then
		if options_menu then
			opt_idx = opt_idx - 1
			if opt_idx < 1 then
				opt_idx = #opt_voices
			end
		elseif list_style then
			CloseMusic()
			if p ~= nil then
				Graphics.freeImage(p)
				Timer.destroy(alpha_transf)
				alpha_transf = nil
				preview = false
				p = nil
			end
			idx = idx - 1
			if idx < 1 then
				idx = #themes_table
			end
			if (idx >= 8) then
				master_index = idx - 7
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
			CloseMusic()
			if p ~= nil then
				Graphics.freeImage(p)
				Timer.destroy(alpha_transf)
				alpha_transf = nil
				preview = false
				p = nil
			end
			idx = idx + 1
			if idx > #themes_table then
				idx = 1
				master_index = 0
			end
			if (idx >= 9) then
				master_index = idx- 7
			end
		end
		Timer.reset(delayer)
	end
	if not jump_oldpad then
		oldpad = pad
	else
		jump_oldpad = false
	end
end