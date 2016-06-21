-- Booting checks
if (isShufflehax or isThemehax) and (System.checkBuild() == 1) then
	if ShowWarning(linkansw, false) then
		ShowWarning(warnands, true)
		if isShufflehax then
			System.deleteFile("/yodyCache.bin",archive)
			System.deleteFile("/yodyCache_rd.bin",archive)
			System.deleteFile("/yhemeManage.bin",archive)
		end
		isShufflehax = false
		isThemehax = false
	end
end
if not pcall(Sound.init) then
	ShowWarning(nodsp, true)
	bgm_preview = false
	force_bgm_off = true
	opt_voices[2] = bgmprev .. ": " .. disabled
end

-- Populating themes table
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

-- Initializing background wave
if wav_style == 2 then
	wav = LoadWave(1,600, 0.1, wave_style, 400)
else
	wav = LoadWave(15,600, 0.1, wave_style, 400)
end
wav2 = LoadWave(15,600, 0.1, 1, 320)
wav:color(Color.getR(colors[col_idx][3]),Color.getG(colors[col_idx][3]),Color.getB(colors[col_idx][3]))
wav2:color(Color.getR(colors[col_idx][3]),Color.getG(colors[col_idx][3]),Color.getB(colors[col_idx][3]))

-- Launching patch.lua if exists
if System.doesFileExist("/patch.lua") then
	dofile("/patch.lua")
end

-- No theme recognized screen
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
					table.insert(is_zip, false)
					table.insert(zip_pass, nil)
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
		Alert(scanning, TOP_SCREEN)
	elseif theme_received then
		Alert(receiving, TOP_SCREEN)
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
		if not help_screen == nil then
			Screen.freeImage(help_screen)
		end
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

-- Populating previews table
local i2 = #themes_table
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

-- Initializing system timer
local delayer = Timer.new()

-- Main loop
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
						table.insert(is_zip, false)
						table.insert(zip_pass, nil)
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
		if list_style and not options_menu then
			PrintListInfoUI()
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
		Alert(openbgm, BOTTOM_SCREEN)
	elseif install_theme then
		PrintTitle(false)
		Alert(installing, BOTTOM_SCREEN)
	elseif install_themes then
		PrintTitle(false)
		Alert(installing2, BOTTOM_SCREEN)
	elseif theme_received then
		PrintTitle(false)
		Alert(receiving, BOTTOM_SCREEN)
	elseif dump_theme then
		PrintTitle(false)
		Alert(dumping, BOTTOM_SCREEN)
	elseif extracting then
		PrintTitle(false)
		Alert(extractingzip, BOTTOM_SCREEN)
	elseif downloading then
		PrintTitle(false)
		Alert(downloadingth, BOTTOM_SCREEN)
	else
		PrintTitle(true)
	end
	if not options_menu then
		if list_style then
			PrintThemesList()
			PrintListInfo()
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
				if not list_style then
					PrintPreviewText2()
				end
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
		Font.print(font, 10, 180, keyword.." "..search_word, white, TOP_SCREEN)
	end
	if help_mode then
		Screen.drawImage(5,5, help_screen, BOTTOM_SCREEN)
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
		Network.downloadFile("http://rinnegatamante.it/CHMM2/api.php?download="..themes_table[idx].id,System.currentDirectory()..themes_table[idx].name..".zip")
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
	elseif dump_theme then
		DumpTheme()
		dump_theme = false
	elseif install_theme then
		if p ~= nil then
			Timer.pause(alpha_transf)
		end
		if is_zip[idx] then
			ExtractTheme(idx, true)
			ChangeTheme("/tmp")
			PurgeDir("/tmp")
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
			ExecSearchQuery("http://rinnegatamante.it/CHMM2/getThemes.php?popular")
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
			ReloadValue(2, idx)
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
			ReloadValue(2, idx)
		end
		Timer.reset(delayer)
	elseif Controls.check(pad, KEY_SELECT) and not Controls.check(oldpad, KEY_SELECT) then
		if theme_downloader then
			if dwnld_idx == 1 then
				downloading = true
			elseif dwnld_idx == 2 then
				Network.downloadFile("http://rinnegatamante.it/CHMM2/api.php?preview="..themes_table[idx].id,"/chmm_tmp.png")
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
			ReloadValue(2, idx)
		elseif theme_downloader then
			dwnld_idx = dwnld_idx - 1
			if dwnld_idx < 1 then
				dwnld_idx = #downloader_voices
			end
		end
		Timer.reset(delayer)
	elseif Controls.check(pad,KEY_DDOWN) and Timer.getTime(delayer) > 200 then
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
			ReloadValue(2, idx)
		elseif theme_downloader then
			dwnld_idx = dwnld_idx + 1
			if dwnld_idx > #downloader_voices then
				dwnld_idx = 1
			end
		end
		Timer.reset(delayer)
	elseif Controls.check(pad, KEY_TOUCH) and not Controls.check(oldpad, KEY_TOUCH) then
		help_mode = not help_mode
		if help_mode then
			help_screen = Screen.createImage(310, 180, Color.new(255, 255, 255))
			Screen.fillEmptyRect(0,309,1,180, Color.new(0,0,0), help_screen)
			if theme_downloader then
				Screen.debugPrint(3, 5, "A: " .. keysel, Color.new(0,0,0), help_screen)
				Screen.debugPrint(3, 20, "B: " .. keysel, Color.new(0,0,0), help_screen)
				Screen.debugPrint(3, 35, "X: " .. keysel, Color.new(0,0,0), help_screen)
				Screen.debugPrint(3, 50, "Y: " .. keysel, Color.new(0,0,0), help_screen)
				Screen.debugPrint(3, 65, "L: " .. keymode, Color.new(0,0,0), help_screen)
				Screen.debugPrint(3, 80, "R: " .. keymode, Color.new(0,0,0), help_screen)
				Screen.debugPrint(3, 95, "Up/Down: " .. navmen, Color.new(0,0,0), help_screen)
				Screen.debugPrint(3, 110, "Left/Right: " .. navthemes, Color.new(0,0,0), help_screen)
				Screen.debugPrint(3, 125, "Circle Pad: " .. keymov, Color.new(0,0,0), help_screen)
				Screen.debugPrint(3, 140, "Select: " .. execv, Color.new(0,0,0), help_screen)
				Screen.debugPrint(3, 155, "Start: " .. ret1, Color.new(0,0,0), help_screen)
			elseif not options_menu then
				if theme_shuffle == "ON" then
					Screen.debugPrint(3, 5, "A: " .. addth, Color.new(0,0,0), help_screen)
					Screen.debugPrint(3, 20, "B: " .. eraseth, Color.new(0,0,0), help_screen)
					Screen.debugPrint(3, 35, "X: " .. installth, Color.new(0,0,0), help_screen)
					Screen.debugPrint(3, 50, "Y: " .. showprev, Color.new(0,0,0), help_screen)
					Screen.debugPrint(3, 65, "L: " .. changeidx, Color.new(0,0,0), help_screen)
					Screen.debugPrint(3, 80, "R: " .. changeidx, Color.new(0,0,0), help_screen)
					Screen.debugPrint(3, 95, "Up/Down: " .. navthemes, Color.new(0,0,0), help_screen)
					Screen.debugPrint(3, 110, "Left/Right: " .. navthemes, Color.new(0,0,0), help_screen)
					Screen.debugPrint(3, 125, "Circle Pad: " .. unused, Color.new(0,0,0), help_screen)
					Screen.debugPrint(3, 140, "Select: " .. changeth, Color.new(0,0,0), help_screen)
					Screen.debugPrint(3, 155, "Start: " .. openopt, Color.new(0,0,0), help_screen)
				else
					Screen.debugPrint(3, 5, "A: " .. installth2, Color.new(0,0,0), help_screen)
					Screen.debugPrint(3, 20, "B: " .. unused, Color.new(0,0,0), help_screen)
					Screen.debugPrint(3, 35, "X: " .. opensh, Color.new(0,0,0), help_screen)
					Screen.debugPrint(3, 50, "Y: " .. showprev, Color.new(0,0,0), help_screen)
					Screen.debugPrint(3, 65, "L: " .. extzip, Color.new(0,0,0), help_screen)
					Screen.debugPrint(3, 80, "R: " .. opendown, Color.new(0,0,0), help_screen)
					Screen.debugPrint(3, 95, "Up/Down: " .. navthemes, Color.new(0,0,0), help_screen)
					Screen.debugPrint(3, 110, "Left/Right: " .. navthemes, Color.new(0,0,0), help_screen)
					Screen.debugPrint(3, 125, "Circle Pad: " .. unused, Color.new(0,0,0), help_screen)
					Screen.debugPrint(3, 140, "Select: " .. changeth, Color.new(0,0,0), help_screen)
					Screen.debugPrint(3, 155, "Start: " .. openopt, Color.new(0,0,0), help_screen)
				end
			end
		else
			Screen.freeImage(help_screen)
			help_screen = nil
		end
	end
	oldpad = pad
end