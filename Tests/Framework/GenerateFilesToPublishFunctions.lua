require("CodeCoverageParser");

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

local lBlockOpeningKeywords_ClosedByEnd = {
	"do",
	"if",
	"function",
};

local bUnclosedReturn = false;
local bUnclosedBracket = false;
local bInsideFunction = false;
local nOpenBlockCount = 0;

local function insertFunctionLineCoveredStatement(sLine, nLineCount)

	local sToInsert = string.format(";print(%d);", nLineCount);
	local nStartFound, _, _ = string.find(sLine, "%s+return[%s;]");

	if nStartFound ~= nil then
			sLine = string.sub(sLine, 1, nStartFound) .. sToInsert .. string.sub(sLine, nStartFound+1);
	else
		if string.sub(sLine, -1,-1) == '\r' then
			sLine = string.sub(sLine, 1, -2) .. sToInsert .. string.sub(sLine, -1);
		else
			sLine = sLine .. sToInsert;
		end
	end

	return sLine;

end

local function bLineStartsFunction(sLine)
	local nStartFound, _, _ = string.find(sLine, "%sfunction%s");

	if nStartFound then
		return true;
	else
		nStartFound, _, _ = string.find(sLine, "function%s");
		if nStartFound == 1 then
			return true;
		else
			return false;
		end
	end

	return false;

end

local function vUpdateOpenBlockCount(sLine)

	--find block openings
	for _, keyword in pairs(lBlockOpeningKeywords_ClosedByEnd) do
		local sTempLine = sLine;
		repeat
			local nStart, nEnd, _ = string.find(sTempLine, keyword.."[%s;()]");

			local bFoundValid = false;

			if nStart then
				if nStart == 1 then
					bFoundValid = true;
				elseif nStart > 1 then
					if string.match(sTempLine:sub(nStart-1,nStart-1), "[%s;()]") then
						bFoundValid = true;
					end
				end
			end

			if bFoundValid then
				nOpenBlockCount = nOpenBlockCount + 1;
				sTempLine = string.sub(sTempLine, nEnd+1);
			elseif nStart then
				sTempLine = string.sub(sTempLine, nEnd+1);
			end

		until (nStart == nil)
	end

	--find block closings

	local sTempLine = sLine;

	repeat
		local nStart, nEnd, _ = string.find(sTempLine, "end".."[%s;()]");

		local bFoundValid = false;

		if nStart then
			if nStart == 1 then
				bFoundValid = true;
			elseif nStart > 1 then
				if string.match(sTempLine:sub(nStart-1,nStart-1), "[%s;()]") then
					bFoundValid = true;
				end
			end
		elseif sTempLine == "end" then
			nOpenBlockCount = nOpenBlockCount - 1;
		end

		if bFoundValid then
			nOpenBlockCount = nOpenBlockCount - 1;
			sTempLine = string.sub(sTempLine, nEnd+1);
		elseif nStart then
			sTempLine = string.sub(sTempLine, nEnd+1);
		end
	until (nStart == nil)

end

local function bOnlyContainsWhiteSpace(sLine)

	if sLine:find("%S+") then
		return false;
	end

	return true;
end

while sFileName do	
	if isLuaFile(sFileName) then
		local originalFile, fakedFile = io.open(sProductiveFilesDir.."\\"..sFileName, "rb"), io.open(sProductiveFilesDir.."\\Tests\\FakedFiles\\".."Fake"..sFileName, "w+");
		local _lines = originalFile:lines();
		io.output(fakedFile);

		local i = 0;
		for line in _lines do

			line = line:gsub("local function", "function");

			if not bInsideFunction then
				bInsideFunction = bLineStartsFunction(line);
				if bInsideFunction then
					nOpenBlockCount = 1;
					i = 0;
					bUnclosedReturn = false;
				end
			else
				vUpdateOpenBlockCount(line);

				if nOpenBlockCount == 0 then
					bInsideFunction = false;
				end

			end

			if bInsideFunction and not bUnclosedReturn and not bOnlyContainsWhiteSpace(line) then
				i = i + 1;
				line = insertFunctionLineCoveredStatement(line, i);

				if nOpenBlockCount == 1 then
					local sTemp = line;

					repeat
						local nStart, nEnd = string.find(sTemp, "end[%s;()]")

						if nStart then
							sTemp = sTemp:sub(nEnd);
						end

					until (nStart == nil)

					if string.match(sTemp, "return[;%s]") then
						bUnclosedReturn = true;
					end
				end

			end
			io.write(line);
		end

		originalFile:close();
		fakedFile:close();

		fakedFile = io.open(sProductiveFilesDir.."\\Tests\\FakedFiles\\".."Fake"..sFileName, "rb");

		sParsFile(fakedFile:read("a"));

		print("Fake"..sFileName.." generated.");

	end
    i = i + 1;
    sFileName = _filenames[i];
end