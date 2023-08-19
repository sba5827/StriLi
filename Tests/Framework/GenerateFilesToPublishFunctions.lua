local sCurrentDir = io.popen("cd"):read();
local sProductiveFilesDir = sCurrentDir:gsub("\\Tests\\Framework", "");

local function scandir(directory)
    local i, t = 0, {}
    local pfile = io.popen('dir "'..directory..'" /b')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

local function isLuaFile(sFileName)
	local containsLuaExtention = string.find(sFileName, "%.lua");
	
	if containsLuaExtention then
		return true;
	else
		return false;
	end
end

local _filenames = scandir(sProductiveFilesDir);

local i = 1;
local sFileName = _filenames[i];

while sFileName do	
	if isLuaFile(sFileName) then
		local originalFile, fakedFile = io.open(sProductiveFilesDir.."\\"..sFileName, "rb"), io.open(sProductiveFilesDir.."\\Tests\\FakedFiles\\".."Fake"..sFileName, "w+");
		local _lines = originalFile:lines();
		io.output(fakedFile);
		
		for line in _lines do
			line = line:gsub("local function", "function");
			io.write(line);
		end
		
		originalFile:close();
		fakedFile:close();
		print("Fake"..sFileName.." generated.");
	end
	
	i = i + 1;
	sFileName = _filenames[i];
end