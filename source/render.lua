-- Default colors
local colors = {
	{genColor(0,132,255), genColor(72,185,255), genColor(0,132,255)},  -- Cyan
	{genColor(255,132,0), genColor(255,185,72), genColor(255,132,0)},  -- Orange
	{genColor(255,72,72), genColor(255,132,132), genColor(255,72,72)}, -- Pink
	{genColor(255,0,0), genColor(255,72,72), genColor(255,0,0)}, 	  -- Red
	{genColor(255,72,255), genColor(255,185,255), genColor(255,72,255)},	-- Magenta
	{genColor(72,72,72), genColor(0,0,0), genColor(0,255,0)}	-- Black'N'Green
}

-- PrintOptionsVoices: Print Options Menu
local function PrintOptionsVoices()
	setFontSize(font, 14)
	base_y = 30
	for l, voice in pairs(opt_voices) do
		if (base_y > 205) then
			break
		end
		x = 5
		if (l==opt_idx) then
			fillCPURect(0,319,base_y-2,base_y+17,colors[col_idx][1],BOTTOM_SCREEN)
			x = 10
		end
		printFont(font, x, base_y, voice, genColor(255, 255, 255), BOTTOM_SCREEN)
		base_y = base_y + 20
	end
end

-- ShowWarning: Shows a warning panel
local function ShowWarning(text, single_exit)
	local confirm = false
	local error_lines = ErrorGenerator(text)
	flipScreen()
	refreshScreen()
	max_y = error_lines[#error_lines][2] + 40
	fillCPUEmptyRect(5,315,50,max_y,black,BOTTOM_SCREEN)
	fillCPURect(6,314,51,max_y-1,white,BOTTOM_SCREEN)
	printFont(font,8,53,warn,colors[col_idx][1],BOTTOM_SCREEN)
	for i,line in pairs(error_lines) do
		printFont(font,8,line[2],line[1],black,BOTTOM_SCREEN)
	end
	if single_exit then
		fillCPUEmptyRect(147,176,max_y - 23, max_y - 8,black,BOTTOM_SCREEN)
		printFont(font,155,max_y - 23,ok,black,BOTTOM_SCREEN)
	else
		fillCPUEmptyRect(107,136,max_y - 23, max_y - 8,black,BOTTOM_SCREEN)
		printFont(font,112,max_y - 23,yes,black,BOTTOM_SCREEN)
		fillCPUEmptyRect(147,176,max_y - 23, max_y - 8,black,BOTTOM_SCREEN)
		printFont(font,155,max_y - 23,no,black,BOTTOM_SCREEN)
	end
	flipScreen()
	refreshScreen()
	fillCPUEmptyRect(5,315,50,max_y,black,BOTTOM_SCREEN)
	fillCPURect(6,314,51,max_y-1,white,BOTTOM_SCREEN)
	printFont(font,8,53,warn,colors[col_idx][1],BOTTOM_SCREEN)
	for i,line in pairs(error_lines) do
		printFont(font,8,line[2],line[1],black,BOTTOM_SCREEN)
	end
	if single_exit then
		fillCPUEmptyRect(147,176,max_y - 23, max_y - 8,black,BOTTOM_SCREEN)
		printFont(font,155,max_y - 23,ok,black,BOTTOM_SCREEN)
		while not confirm do
			if (Controls.check(Controls.read(),KEY_TOUCH)) then
				x,y = Controls.readTouch()
				if x >= 147 and x <= 176 and y >= max_y - 23 and y <= max_y - 8 then
					return true
				end
			end
		end
	else
		fillCPUEmptyRect(107,136,max_y - 23, max_y - 8,black,BOTTOM_SCREEN)
		printFont(font,112,max_y - 23,yes,black,BOTTOM_SCREEN)
		fillCPUEmptyRect(147,176,max_y - 23, max_y - 8,black,BOTTOM_SCREEN)
		printFont(font,155,max_y - 23,no,black,BOTTOM_SCREEN)
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
	fillGPURect(0, 320, 0, 240, colors[col_idx][2])
	fillGPURect(0, 320, 0, 25, colors[col_idx][1])
end

-- PrintTopUI: Generates top screen UI
local function PrintTopUI()
	fillGPURect(0, 400, 0, 240, colors[col_idx][2])
end

-- PrintThemesList: Shows themes list (Listmenu)
local function PrintThemesList()
	setFontSize(font, 14)
	local base_y = 30
	for l, file in pairs(themes_table) do
		if (base_y > 205) then
			break
		end
		if (l >= master_index) then
			local x = 5
			if (l==idx) then
				fillCPURect(0,319,base_y-2,base_y+17,colors[col_idx][1],BOTTOM_SCREEN)
				x = 10
			end
			printFont(font, x, base_y, file.name, genColor(255, 255, 255), BOTTOM_SCREEN)
			base_y = base_y + 20
		end
	end
end

-- PrintTitle: Prints basic info about the homebrew
local function PrintTitle(version_bool)
	local ip
	setFontSize(font, 16)
	printFont(font, 5, 5, "CHMM2 - " .. hbdesc, genColor(255, 255, 255), BOTTOM_SCREEN)
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
		printFont(font, 5, 225, "v."..version.."                                            "..ip, genColor(255, 255, 255), BOTTOM_SCREEN)
	end
end

-- PrintIconsPreview: Prints themes icons
local function PrintIconsPreview()
	drawImage(132, 82, icon)
	drawScaleImage(137, 88, preview_info[2].icon, 0.95, 0.95)
	drawScaleImage(66, 60, icon, 0.8, 0.8)
	drawScaleImage(71, 66, preview_info[1].icon, 0.7, 0.7)
	drawScaleImage(209, 60, icon, 0.8, 0.8)
	drawScaleImage(214, 66, preview_info[3].icon, 0.7, 0.7)	
end

-- PrintInfoUI: Prints theme info panel (Ringmenu)
local function PrintInfoUI()
	drawImage(10, 150, voice)
	if is_zip[idx] and not theme_downloader then
		drawImage(275, 158, zip_icon)
	end
end

-- PrintListInfoUI: Prints theme info panel (Listmenu)
local function PrintListInfoUI()
	drawImage(50, 150, voice)
	if is_zip[idx] and not theme_downloader then
		drawImage(315, 158, zip_icon)
	end
end

-- DescriptionPrint: Prints a theme description (Ringmenu)
local function DescriptionPrint()
	len = string.len(preview_info[2].desc) - 45
	if desc_i == 0 or desc_i >= len then
		if desc_i == 0 and getTimerState(desc_timer) > 2000 then
			desc_i = 1
			resetTimer(desc_timer)
		elseif desc_i >= len and getTimerState(desc_timer) > 2000 then
			desc_i = 0
			resetTimer(desc_timer)
		end
	else
		desc_i = desc_i + 1
		resetTimer(desc_timer)
	end
	printFont(font, 17, 189, string.sub(preview_info[2].desc,desc_i,45+desc_i), genColor(0, 0, 0), BOTTOM_SCREEN)
end

-- DescriptionListPrint: Prints a theme description (Listmenu)
local function DescriptionListPrint()
	len = string.len(preview_info[2].desc) - 45
	if desc_i == 0 or desc_i >= len then
		if desc_i == 0 and getTimerState(desc_timer) > 2000 then
			desc_i = 1
			resetTimer(desc_timer)
		elseif desc_i >= len and getTimerState(desc_timer) > 2000 then
			desc_i = 0
			resetTimer(desc_timer)
		end
	else
		desc_i = desc_i + 1
		resetTimer(desc_timer)
	end
	printFont(font, 57, 189, string.sub(preview_info[2].desc,desc_i,45+desc_i), genColor(0, 0, 0), TOP_SCREEN)
end

-- PrintInfo: Prints theme info (Ringmenu)
local function PrintInfo()
	setFontSize(font, 20)
	printFont(font, 17, 157, preview_info[2].title, colors[col_idx][1], BOTTOM_SCREEN)
	setFontSize(font, 16)
	if string.len(preview_info[2].desc) > 40 then
		Timer.resume(desc_timer)
		DescriptionPrint()
	else
		printFont(font, 17, 189, preview_info[2].desc, black, BOTTOM_SCREEN)
	end
	setFontSize(font, 12)
	printFont(font, 17, 175, by .. " " .. preview_info[2].author, colors[col_idx][1], BOTTOM_SCREEN)
end

-- PrintListInfo: Prints theme info (Listmenu)
local function PrintListInfo()
	setFontSize(font, 20)
	printFont(font, 57, 157, preview_info[2].title, colors[col_idx][1], TOP_SCREEN)
	setFontSize(font, 16)
	if string.len(preview_info[2].desc) > 40 then
		Timer.resume(desc_timer)
		DescriptionListPrint()
	else
		printFont(font, 57, 189, preview_info[2].desc, black, TOP_SCREEN)
	end
	setFontSize(font, 12)
	printFont(font, 57, 175, by .. " " .. preview_info[2].author, colors[col_idx][1], TOP_SCREEN)
end

-- PrintDownloadMenu: Prints downloader menu
local function PrintDownloadMenu()
	for i, voice in pairs(downloader_voices) do
		if i == dwnld_idx then
			color = genColor(255, 255, 0)
		else
			color = white
		end
		printFont(font, 5, 35 + i * 15, voice, color, TOP_SCREEN)
	end
end

-- PrintPreviews: Prints preview for a theme
local function PrintPreviews()
	if p == nil then
		LoadPreview()		
	end
	if	img_type == "YATA" then
		drawPartialImage(0, 0, 0, 0, 400, 240, p, genColor(255,255,255,alpha1))
		drawPartialImage(40, 0, 40, 240, 320, 240, p, genColor(255,255,255,alpha2))
	elseif img_type == "SSHOT" then
		drawPartialImage(0, 0, 16, 16, 400, 240, p, genColor(255,255,255,alpha1))
		drawPartialImage(40, 0, 56, 272, 320, 240, p, genColor(255,255,255,alpha2))
	elseif img_type == "USAGI" then
		drawPartialImage(0, 0, 6, 0, 400, 240, p, genColor(255,255,255,alpha1))
		drawPartialImage(40, 0, 46, 240, 320, 240, p, genColor(255,255,255,alpha2))
	else
		drawPartialImage(0, 0, 0, 0, 400, 240, p)
	end
end

-- PrintTopUI2: Prints UI for the top screen
local function PrintTopUI2()
	fillGPURect(0, 400, 215, 240, colors[col_idx][1])
end

-- PrintThemesInfo: Prints info about detected themes and CHMM2 mode
local function PrintThemesInfo()
	setFontSize(font, 16)
	if isShufflehax or isThemehax then
		printFont(font, 5, 220, detect .. ": " .. #themes_table .. "           " .. haxmode .. ": " .. enabled, genColor(255, 255, 255), TOP_SCREEN)
	elseif theme_downloader and not preview then
		printFont(font, 5, 220, foundt .. ": " .. #zhemes .. "           " .. site .. ": 3DSThem.es", genColor(255, 255, 255), TOP_SCREEN)
	else
		if theme_shuffle == "ON" then
			tmp = enabled
		else
			tmp = disabled
		end
		printFont(font, 5, 220,  detect .. ": " .. #themes_table .. "           " .. shuffle .. ": " .. tmp, genColor(255, 255, 255), TOP_SCREEN)
	end
end

-- PrintError: Shows an error
local function PrintError()
	setFontSize(font, 16)
	printFont(font, 17, 157, norec, colors[col_idx][1], BOTTOM_SCREEN)
	printFont(font, 17, 173, folder .. ":", genColor(0,0,0), BOTTOM_SCREEN)
	printFont(font, 17, 188, System.currentDirectory(), genColor(0,0,0), BOTTOM_SCREEN)
end

-- PrintControls: Prints possible controls if no theme is found
function PrintControls()
	setFontSize(font, 18)
	printFont(font, 57, 60, press .. "        " .. toexit, genColor(0,0,0), TOP_SCREEN)
	printFont(font, 57, 80, press .. "        " .. toscan, genColor(0,0,0), TOP_SCREEN)
end

-- Alert: Shows an alert
local function Alert(txt, screen)
	setFontSize(font, 16)
	printFont(font, 5, 220, txt, genColor(255, 255, 255), screen)
end

-- PrintButtonsUI: Prints buttons image
local function PrintButtonsUI()
	drawImage(50, 50, voice)
	drawPartialImage(94, 62, 0, 0, 17, 15, buttons)
	drawPartialImage(94, 82, 17, 0, 17, 15, buttons)
end

-- PrintPreviewText: Prints preview alert (Normal Mode)
local function PrintPreviewText()
	setFontSize(font, 18)
	printFont(font, 100, 100, press .. "        " .. toprev, white, TOP_SCREEN)
end

-- PrintPreviewText2: Prints preview alert (Shuffle Mode)
local function PrintPreviewText2()
	setFontSize(font, 18)
	printFont(font, 100, 165, press .. "        " .. toerase, white, TOP_SCREEN)
	printFont(font, 100, 190, press .. "        " .. toprev, white, TOP_SCREEN)
end

-- PrintPrevButton: Prints preview button (Normal Mode)
local function PrintPrevButton()
	setFontSize(font, 18)
	drawPartialImage(137, 102, 34, 0, 17, 15, buttons)
end

-- PrintPrevButton2: Prints preview button (Shuffle Mode)
local function PrintPrevButton2()
	setFontSize(font, 18)
	drawPartialImage(137, 192, 34, 0, 17, 15, buttons)
	drawPartialImage(137, 167, 17, 0, 17, 15, buttons)
end

-- PrintShuffleGrid: Prints Shuffle Mode Grid
local function PrintShuffleGrid()
	x = 12
	y = 10
	i = 1
	while i <= 10 do
		if i == (shuffle_value + 1) then
			drawImage(x, y, icon)
			if i <= #shuffle_themes then
				drawScaleImage(x + 5, y + 6, shuffle_themes[i][2], 0.95, 0.95)
			end
		else
			drawScaleImage(x + 5, y + 5, icon, 0.8, 0.8)
			if i <= #shuffle_themes then
				drawScaleImage(x + 10, y + 11, shuffle_themes[i][2], 0.7, 0.7)
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