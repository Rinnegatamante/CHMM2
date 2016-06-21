-- OptionExecute: Execute a task depending on current selected voice
local function OptionExecute(voice_num)
	if voice_num == 1 then
		list_style = not list_style
		if list_style then
			opt_voices[voice_num] = listopt .. ": " .. listmode1
		else
			opt_voices[voice_num] = listopt .. ": " .. listmode2
		end
	elseif voice_num == 2 then
		if not force_bgm_off then
			bgm_preview = not bgm_preview
			if bgm_preview then
				opt_voices[voice_num] = bgmprev .. ": " .. enabled
			else
				opt_voices[voice_num] = bgmprev .. ": " .. disabled
			end
		end
	elseif voice_num == 3 then
		auto_extract = not auto_extract
		if auto_extract then
			opt_voices[voice_num] = autozipopt .. ": " .. enabled
		else
			opt_voices[voice_num] = autozipopt .. ": " .. disabled
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
		opt_voices[voice_num] = wavopt .. ": " .. wave_styles[wave_style]
	elseif voice_num == 5 then
		dump_theme = true
	elseif voice_num == 6 then
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