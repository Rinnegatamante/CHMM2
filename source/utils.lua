-- PurgeDir: Deletes a directory and its contents
local function PurgeDir(dir)
	local tmp_files = System.listDirectory(dir)
	for i, file in pairs(tmp_files) do
		System.deleteFile(dir.."/"..file.name)
	end
	System.deleteDirectory(dir)
end

-- hex2num: Converts a generic 32 bit string to a number
local function hex2num(hex)
	local b1,b2,b3,b4 = string.byte(hex,1,4)
	return b1 + (b2<<8) + (b3<<16) + (b4<<24)
end

-- LastSpace: Returns offset of last detected space for a string
local function LastSpace(text)
	local found = false
	local start = -1
	while string.sub(text,start,start) ~= " " do
		start = start - 1
	end
	return start
end

-- ErrorGenerator: Generates an error table for the renderer
function ErrorGenerator(text)
	y = 68
	local error_lines = {}
	while string.len(text) > 50 do
		endl = 51 + LastSpace(string.sub(text,1,50))
		table.insert(error_lines,{string.sub(text,1,endl), y})
		text = string.sub(text,endl+1,-1)
		y = y + 15
	end
	if string.len(text) > 0 then
		table.insert(error_lines,{text, y})
	end
	return error_lines
end

-- SortDirectory: List and sort directories
function SortDirectory(dir)
	local folders_table = {}
	for i,file in pairs(dir) do
		if file.directory then
			table.insert(folders_table,file)
		end
	end
	table.sort(folders_table, function (a, b) return (a.name:lower() < b.name:lower() ) end)
	return_table = folders_table
	return return_table
end

-- SortZip: List and sort zip files
function SortZip(dir)
	local zip_table = {}
	for i,file in pairs(dir) do
		if not file.directory and string.sub(file.name, -4):lower() == ".zip" then
			table.insert(zip_table,file)
		end
	end
	table.sort(zip_table, function (a, b) return (a.name:lower() < b.name:lower() ) end)
	return_table = zip_table
	return return_table
end

-- u32toString: Converts a 32bit integer to a string
function u32toString(value)
	local byte4 = 0x00
	local byte3 = 0x00
	local byte2 = 0x00
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
	local byte1 = value
	local ret_string = string.char(byte1,byte2,byte3,byte4)
	return ret_string
end

-- ScanDirectory: Scans a directory in search of themes
local function ScanDirectory(dir,path)
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

-- ScanSD: Scans the whole SD in search of themes
local function ScanSD()
	found = false
	System.createDirectory(System.currentDirectory())
	ScanDirectory("/","/")	
	themes_table = SortDirectory(System.listDirectory(System.currentDirectory()))
end

-- LoadWave: Init a new wave object
local function LoadWave(height,dim,f,style,x_dim)	
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
			t = getTimerState(self.contador)/1000+desfase
			for x = 0,x_dim,4 do
				y = 100+self.Amplitud*math.sin(2*self.pi*(t*self.Frec-x/self.Long_onda))
				i = self.Amplitud*(-2*self.pi/self.Long_onda)*math.cos(2*self.pi*(t*self.Frec-x/self.Long_onda))
				drawLine(x-200,x+200,y-i*200,y+i*200,genColor(self.a,self.b,self.c,math.floor(x/40)))
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
			t = getTimerState(self.contador)/1000+desfase
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
					Graphics.drawLine(x-20,x+20,a+y-i*20,a+y+i*20,genColor(self.a,self.b,self.c,25-math.abs(a*5)))
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
		function onda:color(a,b,c) self.Color=genColor(a,b,c,40) end
		function onda:init(desfase)
			desfase=desfase or 0
			if not self.contador then
				self.contador=Timer.new()
			end
			if not self.Color then
				self.Color=genColor(0,0,255,40)
			end
			local t,x,y,i
			t = getTimerState(self.contador)/1000+desfase
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

-- PurgeShuffleTable: Purges Shuffle table from Shuffle Mode
function PurgeShuffleTable()
	for i, theme in pairs(shuffle_themes) do
		Graphics.freeImage(theme[2])
	end
	shuffle_themes = {}
	shuffle_value = 0
end