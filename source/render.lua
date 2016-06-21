-- Default colors
local colors = {
	{Color.new(0,132,255), Color.new(72,185,255), Color.new(0,132,255)},  -- Cyan
	{Color.new(255,132,0), Color.new(255,185,72), Color.new(255,132,0)},  -- Orange
	{Color.new(255,72,72), Color.new(255,132,132), Color.new(255,72,72)}, -- Pink
	{Color.new(255,0,0), Color.new(255,72,72), Color.new(255,0,0)}, 	  -- Red
	{Color.new(255,72,255), Color.new(255,185,255), Color.new(255,72,255)},	-- Magenta
	{Color.new(72,72,72), Color.new(0,0,0), Color.new(0,255,0)}	-- Black'N'Green
}

-- PrintOptionsVoices: Print Options Menu
local function PrintOptionsVoices()
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

-- ShowWarning: Shows a warning panel
local function ShowWarning(text, single_exit)
	local confirm = false
	local error_lines = ErrorGenerator(text)
	Screen.flip()
	Screen.refresh()
	max_y = error_lines[#error_lines][2] + 40
	Screen.fillEmptyRect(5,315,50,max_y,black,BOTTOM_SCREEN)
	Screen.fillRect(6,314,51,max_y-1,white,BOTTOM_SCREEN)
	Font.print(font,8,53,warn,colors[col_idx][1],BOTTOM_SCREEN)
	for i,line in pairs(error_lines) do
		Font.print(font,8,line[2],line[1],black,BOTTOM_SCREEN)
	end
	if single_exit then
		Screen.fillEmptyRect(147,176,max_y - 23, max_y - 8,black,BOTTOM_SCREEN)
		Font.print(font,155,max_y - 23,ok,black,BOTTOM_SCREEN)
	else
		Screen.fillEmptyRect(107,136,max_y - 23, max_y - 8,black,BOTTOM_SCREEN)
		Font.print(font,112,max_y - 23,yes,black,BOTTOM_SCREEN)
		Screen.fillEmptyRect(147,176,max_y - 23, max_y - 8,black,BOTTOM_SCREEN)
		Font.print(font,155,max_y - 23,no,black,BOTTOM_SCREEN)
	end
	Screen.flip()
	Screen.refresh()
	Screen.fillEmptyRect(5,315,50,max_y,black,BOTTOM_SCREEN)
	Screen.fillRect(6,314,51,max_y-1,white,BOTTOM_SCREEN)
	Font.print(font,8,53,warn,colors[col_idx][1],BOTTOM_SCREEN)
	for i,line in pairs(error_lines) do
		Font.print(font,8,line[2],line[1],black,BOTTOM_SCREEN)
	end
	if single_exit then
		Screen.fillEmptyRect(147,176,max_y - 23, max_y - 8,black,BOTTOM_SCREEN)
		Font.print(font,155,max_y - 23,ok,black,BOTTOM_SCREEN)
		while not confirm do
			if (Controls.check(Controls.read(),KEY_TOUCH)) then
				x,y = Controls.readTouch()
				if x >= 147 and x <= 176 and y >= max_y - 23 and y <= max_y - 8 then
					return true
				end
			end
		end
	else
		Screen.fillEmptyRect(107,136,max_y - 23, max_y - 8,black,BOTTOM_SCREEN)
		Font.print(font,112,max_y - 23,yes,black,BOTTOM_SCREEN)
		Screen.fillEmptyRect(147,176,max_y - 23, max_y - 8,black,BOTTOM_SCREEN)
		Font.print(font,155,max_y - 23,no,black,BOTTOM_SCREEN)
		while not confirm do
			if (Controls.check(Controls.read(),KEY_TOUCH)) then
				x,y = Controls.readTouch()
				if x >= 107 and x <= 136 and y >= max_y - 23 and y <= max_y - 8 then
					return true
				elseif x >= 147 and x <= 176 and y >= max_y - 23 and y <= max_y - 8 then
					return false
				end
			end
		end
	end
end

-- PrintBottomUI: Generates bottom screen UI
local function PrintBottomUI()
	Graphics.fillRect(0, 320, 0, 240, colors[col_idx][2])
	Graphics.fillRect(0, 320, 0, 25, colors[col_idx][1])
end

-- PrintTopUI: Generates top screen UI
local function PrintTopUI()
	Graphics.fillRect(0, 400, 0, 240, colors[col_idx][2])
end

-- PrintThemesList: Shows themes list (Listmenu)
local function PrintThemesList()
	Font.setPixelSizes(font, 14)
	local base_y = 30
	for l, file in pairs(themes_table) do
		if (base_y > 205) then
			break
		end
		if (l >= master_index) then
			local x = 5
			if (l==idx) then
				Screen.fillRect(0,319,base_y-2,base_y+17,colors[col_idx][1],BOTTOM_SCREEN)
				x = 10
			end
			Font.print(font, x, base_y, file.name, Color.new(255, 255, 255), BOTTOM_SCREEN)
			base_y = base_y + 20
		end
	end
end

-- PrintTitle: Prints basic info about the homebrew
local function PrintTitle(version_bool)
	local ip
	Font.setPixelSizes(font, 16)
	Font.print(font, 5, 5, "CHMM2 - " .. hbdesc, Color.new(255, 255, 255), BOTTOM_SCREEN)
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

-- PrintIconsPreview: Prints themes icons
local function PrintIconsPreview()
	Graphics.drawImage(132, 82, icon)
	Graphics.drawScaleImage(137, 88, preview_info[2].icon, 0.95, 0.95)
	Graphics.drawScaleImage(66, 60, icon, 0.8, 0.8)
	Graphics.drawScaleImage(71, 66, preview_info[1].icon, 0.7, 0.7)
	Graphics.drawScaleImage(209, 60, icon, 0.8, 0.8)
	Graphics.drawScaleImage(214, 66, preview_info[3].icon, 0.7, 0.7)	
end

-- PrintInfoUI: Prints theme info panel (Ringmenu)
local function PrintInfoUI()
	Graphics.drawImage(10, 150, voice)
	if is_zip[idx] and not theme_downloader then
		Graphics.drawImage(275, 158, zip_icon)
	end
end

-- PrintListInfoUI: Prints theme info panel (Listmenu)
local function PrintListInfoUI()
	Graphics.drawImage(50, 150, voice)
	if is_zip[idx] and not theme_downloader then
		Graphics.drawImage(315, 158, zip_icon)
	end
end

-- DescriptionPrint: Prints a theme description (Ringmenu)
local function DescriptionPrint()
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

-- DescriptionListPrint: Prints a theme description (Listmenu)
local function DescriptionListPrint()
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
	Font.print(font, 57, 189, string.sub(preview_info[2].desc,desc_i,45+desc_i), Color.new(0, 0, 0), TOP_SCREEN)
end

-- PrintInfo: Prints theme info (Ringmenu)
local function PrintInfo()
	Font.setPixelSizes(font, 20)
	Font.print(font, 17, 157, preview_info[2].title, colors[col_idx][1], BOTTOM_SCREEN)
	Font.setPixelSizes(font, 16)
	if string.len(preview_info[2].desc) > 40 then
		Timer.resume(desc_timer)
		DescriptionPrint()
	else
		Font.print(font, 17, 189, preview_info[2].desc, black, BOTTOM_SCREEN)
	end
	Font.setPixelSizes(font, 12)
	Font.print(font, 17, 175, by .. " " .. preview_info[2].author, colors[col_idx][1], BOTTOM_SCREEN)
end

-- PrintListInfo: Prints theme info (Listmenu)
local function PrintListInfo()
	Font.setPixelSizes(font, 20)
	Font.print(font, 57, 157, preview_info[2].title, colors[col_idx][1], TOP_SCREEN)
	Font.setPixelSizes(font, 16)
	if string.len(preview_info[2].desc) > 40 then
		Timer.resume(desc_timer)
		DescriptionListPrint()
	else
		Font.print(font, 57, 189, preview_info[2].desc, black, TOP_SCREEN)
	end
	Font.setPixelSizes(font, 12)
	Font.print(font, 57, 175, by .. " " .. preview_info[2].author, colors[col_idx][1], TOP_SCREEN)
end

-- PrintDownloadMenu: Prints downloader menu
local function PrintDownloadMenu()
	for i, voice in pairs(downloader_voices) do
		if i == dwnld_idx then
			color = Color.new(255, 255, 0)
		else
			color = white
		end
		Font.print(font, 200, 35 + i * 15, voice, color, TOP_SCREEN)
	end
end

-- PrintPreviews: Prints preview for a theme
local function PrintPreviews()
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

-- PrintTopUI2: Prints UI for the top screen
local function PrintTopUI2()
	Graphics.fillRect(0, 400, 215, 240, colors[col_idx][1])
end

-- PrintThemesInfo: Prints info about detected themes and CHMM2 mode
local function PrintThemesInfo()
	Font.setPixelSizes(font, 16)
	if isShufflehax or isThemehax then
		Font.print(font, 5, 220, detect .. ": " .. #themes_table .. "           " .. haxmode .. ": " .. enabled, Color.new(255, 255, 255), TOP_SCREEN)
	elseif theme_downloader and not preview then
		Font.print(font, 5, 220, foundt .. ": " .. #zhemes .. "           " .. site .. ": 3DSThem.es", Color.new(255, 255, 255), TOP_SCREEN)
	else
		if theme_shuffle == "ON" then
			tmp = enabled
		else
			tmp = disabled
		end
		Font.print(font, 5, 220,  detect .. ": " .. #themes_table .. "           " .. shuffle .. ": " .. tmp, Color.new(255, 255, 255), TOP_SCREEN)
	end
end

-- PrintError: Shows an error
local function PrintError()
	Font.setPixelSizes(font, 16)
	Font.print(font, 17, 157, norec, colors[col_idx][1], BOTTOM_SCREEN)
	Font.print(font, 17, 173, folder .. ":", Color.new(0,0,0), BOTTOM_SCREEN)
	Font.print(font, 17, 188, System.currentDirectory(), Color.new(0,0,0), BOTTOM_SCREEN)
end

-- PrintControls: Prints possible controls if no theme is found
function PrintControls()
	Font.setPixelSizes(font, 18)
	Font.print(font, 57, 60, press .. "        " .. toexit, Color.new(0,0,0), TOP_SCREEN)
	Font.print(font, 57, 80, press .. "        " .. toscan, Color.new(0,0,0), TOP_SCREEN)
end

-- Alert: Shows an alert
local function Alert(txt, screen)
	Font.setPixelSizes(font, 16)
	Font.print(font, 5, 220, txt, Color.new(255, 255, 255), screen)
end

-- PrintButtonsUI: Prints buttons image
local function PrintButtonsUI()
	Graphics.drawImage(50, 50, voice)
	Graphics.drawPartialImage(94, 62, 0, 0, 17, 15, buttons)
	Graphics.drawPartialImage(94, 82, 17, 0, 17, 15, buttons)
end

-- PrintPreviewText: Prints preview alert (Normal Mode)
local function PrintPreviewText()
	Font.setPixelSizes(font, 18)
	Font.print(font, 100, 100, press .. "        " .. toprev, white, TOP_SCREEN)
end

-- PrintPreviewText2: Prints preview alert (Shuffle Mode)
local function PrintPreviewText2()
	Font.setPixelSizes(font, 18)
	Font.print(font, 100, 165, press .. "        " .. toerase, white, TOP_SCREEN)
	Font.print(font, 100, 190, press .. "        " .. toprev, white, TOP_SCREEN)
end

-- PrintPrevButton: Prints preview button (Normal Mode)
local function PrintPrevButton()
	Font.setPixelSizes(font, 18)
	Graphics.drawPartialImage(137, 102, 34, 0, 17, 15, buttons)
end

-- PrintPrevButton2: Prints preview button (Shuffle Mode)
local function PrintPrevButton2()
	Font.setPixelSizes(font, 18)
	Graphics.drawPartialImage(137, 192, 34, 0, 17, 15, buttons)
	Graphics.drawPartialImage(137, 167, 17, 0, 17, 15, buttons)
end

-- PrintShuffleGrid: Prints Shuffle Mode Grid
local function PrintShuffleGrid()
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