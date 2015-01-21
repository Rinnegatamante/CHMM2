white = Color.new(255,255,255)
red = Color.new(255,0,0)
green = Color.new(0,255,0)
update = false
if System.currentDirectory() == "/" then
	System.currentDirectory("/Themes/")
else
	System.currentDirectory(System.currentDirectory().."/Themes/")
end
p = 1
master_index = 0
themes_table = System.listDirectory(System.currentDirectory())
MAX_RAM_ALLOCATION = 10485760
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
function CropPrint(x, y, text, color, screen)
	if string.len(text) > 25 then
		Screen.debugPrint(x, y, string.sub(text,1,25) .. "...", color, screen)
	else
		Screen.debugPrint(x, y, text, color, screen)
	end
end
oldpad = Controls.read()
no_preview = Screen.createImage(400,240)
Screen.fillRect(0,399,0,239,white,no_preview)
preview_table = {}
for i,data in pairs(themes_table) do
	if System.doesFileExist(System.currentDirectory()..data.name.."/preview.png") then
		table.insert(preview_table,Screen.loadImage(System.currentDirectory()..data.name.."/preview.png"))
	else
		table.insert(preview_table,no_preview)
	end
end
if #preview_table > 0 then
	current_file = preview_table[1]
	if Screen.getImageWidth(current_file) > 400 then
		width = 400
		big_image = true
		x_print = 0
		y_print = 0
	else
		width = Screen.getImageWidth(current_file)
	end
	if Screen.getImageHeight(current_file) > 240 then
			height = 240
			big_image = true
			x_print = 0
			y_print = 0
	else
		height = Screen.getImageHeight(current_file)
	end
else
	while true do
		Screen.refresh()
		Screen.debugPrint(0,0,"No theme recognized...",white,BOTTOM_SCREEN)
		Screen.debugPrint(0,15,"Press A to exit.",white,BOTTOM_SCREEN)
		Controls.init()
		if Controls.check(Controls.read(),KEY_A) then
			Screen.freeImage(no_preview)
			System.exit()
		end
		Screen.flip()
		Screen.waitVblankStart()
	end
end
while true do
	Screen.refresh()
	base_y = 0
	Screen.clear(BOTTOM_SCREEN)
	if big_image then
			Screen.drawPartialImage(0,0,x_print,y_print,width,height,current_file,TOP_SCREEN)
			x,y = Controls.readCirclePad()
			if (x < - 100) and (x_print > 0) then
				x_print = x_print - 1
			end
			if (y > 100) and (y_print > 0) then
				y_print = y_print - 1
			end
			if (x > 100) and (x_print + width < Screen.getImageWidth(current_file)) then
				x_print = x_print + 1
			end
			if (y < - 100) and (y_print + height < Screen.getImageHeight(current_file)) then
				y_print = y_print + 1
			end
	else
		Screen.drawImage(0,0,current_file,TOP_SCREEN)
	end
	Controls.init()
	pad = Controls.read()
	for l, file in pairs(themes_table) do
		if (base_y > 226) then
			break
		end
		if (l >= master_index) then
			if (l==p) then
				base_y2 = base_y
				if (base_y) == 0 then
					base_y = 2
				end
				Screen.fillRect(0,319,base_y-2,base_y2+12,green,BOTTOM_SCREEN)
				color = red
				if (base_y) == 2 then
					base_y = 0
				end
			else
				color = white
			end
			CropPrint(0,base_y,file.name,color,BOTTOM_SCREEN)
			base_y = base_y + 15
		end
	end
	if (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
		ChangeTheme(System.currentDirectory()..themes_table[p].name)
	elseif (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) then
			p = p - 1
			update = true
		if (p >= 16) then
			master_index = p - 15
		end
	elseif (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
		p = p + 1
		update = true
		if (p >= 17) then
			master_index = p - 15
		end
	end
	if (p < 1) then
		p = #themes_table
		if (p >= 17) then
			master_index = p - 15
		end
	elseif (p > #themes_table) then
		master_index = 0
		p = 1
	end
	if Controls.check(pad,KEY_START) then
		System.takeScreenshot("/CHMM.bmp")
		for i,data in pairs(preview_table) do
			if data ~= no_preview then
				Screen.freeImage(data)
			end
		end
		Screen.freeImage(no_preview)
		System.exit()
	end
	if update then
		current_file = preview_table[p]
		big_image = false
		if Screen.getImageWidth(current_file) > 400 then
			width = 400
			big_image = true
			x_print = 0
			y_print = 0
		else
			width = Screen.getImageWidth(current_file)
		end
		if Screen.getImageHeight(current_file) > 240 then
			height = 240
			big_image = true
			x_print = 0
			y_print = 0
		else
			height = Screen.getImageHeight(current_file)
		end
		update = false
	end
	Screen.flip()
	Screen.waitVblankStart()
	oldpad = pad
end