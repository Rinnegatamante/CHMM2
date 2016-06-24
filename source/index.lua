-- Bootstrap (single chunk dofile clone implementation)
local script = "System.deleteFile(\"/tmp.lua\")" .. string.char(0x0A)
local function add2script(file)
	if System.doesFileExist(file) then
		local tmp = io.open(file, FREAD)
		script = script .. io.read(tmp,0,io.size(tmp)) .. string.char(0x0A)
		io.close(tmp)
	end
end
local scripts = {
	"boot.lua", "themes.lua", "utils.lua", "render.lua",
	"options.lua", "downloader.lua", "main.lua"
}
for i, code in pairs(scripts) do
	add2script("romfs:/"..code)
end
script = script .. string.char(0x00)
local output = io.open("/tmp.lua",FCREATE)
io.write(output,0,script,string.len(script))
io.close(output)
dofile("/tmp.lua")