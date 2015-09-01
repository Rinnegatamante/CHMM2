white = Color.new(255,255,255)
red = Color.new(255,0,0)
green = Color.new(0,255,0)
update = false
music = false
if System.currentDirectory() == "/" then
	System.currentDirectory("/Themes/")
else
	System.currentDirectory(System.currentDirectory().."/Themes/")
end
p = 1
master_index = 0
update_screens = true
function CloseMusic()
	if music then
		Sound.pause(bgm)
		Sound.close(bgm)
		music = false
	end
end
function OneshotPrint(my_func)
	my_func()
	Screen.flip()
	Screen.refresh()
	my_func()
end
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
themes_table = SortDirectory(System.listDirectory(System.currentDirectory()))
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
no_preview = Screen.createImage(400,240,Color.new(0,0,0))
preview_mode = false
if #themes_table == 0 then
	while true do
		Screen.refresh()
		Screen.debugPrint(0,0,"No theme recognized...",white,BOTTOM_SCREEN)
		Screen.debugPrint(0,15,"You have to put themese in:",white,BOTTOM_SCREEN)
		Screen.debugPrint(0,30,System.currentDirectory(),white,BOTTOM_SCREEN)
		Screen.debugPrint(0,60,"Press A to exit.",white,BOTTOM_SCREEN)
		Controls.init()
		if Controls.check(Controls.read(),KEY_A) then
			Screen.freeImage(no_preview)
			System.exit()
		end
		Screen.flip()
		Screen.waitVblankStart()
	end
end
info_cns = Console.new(TOP_SCREEN)
function UpdateScreens()
	base_y = 0
	info_file = System.currentDirectory()..themes_table[p].name.."/info.lua"
	if System.doesFileExist(info_file) then
		dofile(info_file)
	else
		author = "Unknown"
		name = "Unknown"
		desc = "Unknown"
	end
	Console.clear(info_cns)
	Console.append(info_cns, "Name: " .. name  .. "\n")
	Console.append(info_cns, "Author: " .. author  .. "\n")
	Console.append(info_cns, "Description: " .. desc .. "\n")
	if preview_mode then
		if big_image then
			if r_width == 400 and r_height >= 480 then
				Screen.drawPartialImage(0,0,0,0,400,240,current_file,TOP_SCREEN)
				Screen.drawPartialImage(0,0,40,240,320,240,current_file,BOTTOM_SCREEN)
			elseif r_width == 432 and r_height == 528 then
				Screen.drawPartialImage(0,0,16,16,400,240,current_file,TOP_SCREEN)
				Screen.drawPartialImage(0,0,56,272,320,240,current_file,BOTTOM_SCREEN)
			else
				custom_big = true
				Screen.clear(BOTTOM_SCREEN)
				Screen.drawPartialImage(0,0,x_print,y_print,width,height,current_file,TOP_SCREEN)
			end
		else
			Screen.clear(BOTTOM_SCREEN)
			Screen.drawImage(0,0,current_file,TOP_SCREEN)
		end
	else
		Screen.clear(BOTTOM_SCREEN)
		Screen.clear(TOP_SCREEN)
		Console.show(info_cns)
	end
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
end
Sound.init()
while true do
	pad = Controls.read()
	Screen.refresh()
	if update_screens then
		OneshotPrint(UpdateScreens)
		update_screens = false
	end
	if big_image and custom_big and preview_mode then
		x,y = Controls.readCirclePad()
		if (x < - 100) and (x_print > 0) then
			x_print = x_print - 1
			update_screens = true
		end
		if (y > 100) and (y_print > 0) then
			y_print = y_print - 1
			update_screens = true
		end
		if (x > 100) and (x_print + width < Screen.getImageWidth(current_file)) then
			x_print = x_print + 1
			update_screens = true
		end
		if (y < - 100) and (y_print + height < Screen.getImageHeight(current_file)) then
			y_print = y_print + 1
			update_screens = true
		end
	end
	if (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
		CloseMusic()
		Screen.fillEmptyRect(10,200,10,26,red,BOTTOM_SCREEN)
		Screen.fillRect(11,199,11,25,Color.new(0,0,0),BOTTOM_SCREEN)
		Screen.debugPrint(13,13,"Installing theme...",green,BOTTOM_SCREEN)
		Screen.flip()
		Screen.waitVblankStart()
		ChangeTheme(System.currentDirectory()..themes_table[p].name)
		update_screens = true
	elseif (Controls.check(pad,KEY_Y)) and not (Controls.check(oldpad,KEY_Y)) then
		if System.doesFileExist(System.currentDirectory()..themes_table[p].name.."/BGM.ogg") and not music then
			Screen.fillEmptyRect(10,200,10,26,red,BOTTOM_SCREEN)
			Screen.fillRect(11,199,11,25,Color.new(0,0,0),BOTTOM_SCREEN)
			Screen.debugPrint(13,13,"Opening BGM...",green,BOTTOM_SCREEN)
			Screen.flip()
			Screen.waitVblankStart()
			update_screens = true
			bgm = Sound.openOgg(System.currentDirectory()..themes_table[p].name.."/BGM.ogg",false)
			Sound.play(bgm,LOOP,0x08,0x09)
			music = true
		end
		if System.doesFileExist(System.currentDirectory()..themes_table[p].name.."/preview.png") then
			current_file = Screen.loadImage(System.currentDirectory()..themes_table[p].name.."/preview.png")
		else
			if System.doesFileExist(System.currentDirectory()..themes_table[p].name.."/preview.jpg") then
				current_file = Screen.loadImage(System.currentDirectory()..themes_table[p].name.."/preview.jpg")
			else
				if System.doesFileExist(System.currentDirectory()..themes_table[p].name.."/preview.bmp") then
					current_file = Screen.loadImage(System.currentDirectory()..themes_table[p].name.."/preview.bmp")
				else
					current_file = no_preview
				end
			end
		end
		if Screen.getImageWidth(current_file) >= 400 then
			width = 400
			big_image = true
			x_print = 0
			y_print = 0
			r_width = Screen.getImageWidth(current_file)
		else
			big_image = false
			width = Screen.getImageWidth(current_file)
		end
		if Screen.getImageHeight(current_file) >= 240 then
			height = 240
			big_image = true
			x_print = 0
			y_print = 0
			r_height = Screen.getImageHeight(current_file)
		else
			height = Screen.getImageHeight(current_file)
		end
		update_screens = true
		preview_mode = not preview_mode
	elseif (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) then
		CloseMusic()
		if preview_mode and current_file ~= no_preview then
			Screen.freeImage(current_file)
		end
		preview_mode = false
		p = p - 1
		if (p >= 16) then
			master_index = p - 15
		end
		update_screens = true
	elseif (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
		CloseMusic()
		if preview_mode and current_file ~= no_preview then
			Screen.freeImage(current_file)
		end
		preview_mode = false
		p = p + 1
		if (p >= 17) then
			master_index = p - 15
		end
		update_screens = true
	elseif (Controls.check(pad,KEY_DLEFT)) and not (Controls.check(oldpad,KEY_DLEFT)) then
		CloseMusic()
		if preview_mode and current_file ~= no_preview then
			Screen.freeImage(current_file)
		end
		preview_mode = false
		p = p - 16
		if (p >= 16) then
			master_index = p - 15
		end
		update_screens = true
	elseif (Controls.check(pad,KEY_DRIGHT)) and not (Controls.check(oldpad,KEY_DRIGHT)) then
		CloseMusic()
		if preview_mode and current_file ~= no_preview then
			Screen.freeImage(current_file)
		end
		preview_mode = false
		p = p + 16
		if (p >= 17) then
			master_index = p - 15
		end
		update_screens = true
	end
	if (p < 1) then
		p = 1
		master_index = 0
	elseif (p > #themes_table) then
		p = #themes_table
		if (p >= 17) then
			master_index = p - 15
		end
	end
	if Controls.check(pad,KEY_START) then
		if preview_mode and current_file ~= no_preview then
			Screen.freeImage(current_file)
		end
		Screen.freeImage(no_preview)
		CloseMusic()
		Console.destroy(info_cns)
		Sound.term()
		System.exit()
	end
	Screen.flip()
	Screen.waitVblankStart()
	oldpad = pad
end