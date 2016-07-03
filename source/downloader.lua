-- GenerateQuery: Generates an API query
local function GenerateQuery(word)
	return string.gsub("http://rinnegatamante.it/CHMM2/getThemes.php?q="..word," ","%%20")
end

-- ExecSearchQuery: Start a search with the online API
local function ExecSearchQuery(query)
	idx = 1
	Network.downloadFile(query, "/tmp.chmm")
	zf = openFile("/tmp.chmm",FWRITE)
	writeFile(zf,0,"z",1)
	closeFile(zf)
	zf = openFile("/tmp.chmm",FREAD)
	len = getSize(zf)
	closeFile(zf)
	if len >  6 then
		dofile("/tmp.chmm")
	else
		return ExecSearchQuery(query)
	end
	System.deleteFile("/tmp.chmm")
	themes_table = zhemes
	if #themes_table <= 0 then
		return ExecSearchQuery("http://rinnegatamante.it/CHMM2/getThemes.php?popular")
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