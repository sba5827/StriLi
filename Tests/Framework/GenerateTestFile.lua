-- Returns: [bool] isLocal, [string] functionName
local function getFunctionName(aString)
	local bReturnIsLocal, sFunctionName = nil, nil;
	
	if aString:sub(1,5) == "local" then
		if aString:sub(7,14) == "function" then
			bReturnIsLocal = true;
		end
	elseif aString:sub(1,8) == "function" then
		bReturnIsLocal = false;
	end
	
	if not (bReturnIsLocal == nil) then
		local nPositionOpeningBracket = aString:find("%(")
		if bReturnIsLocal then
			sFunctionName = aString:sub(16,nPositionOpeningBracket-1);
		else
			sFunctionName = aString:sub(10,nPositionOpeningBracket-1);
		end
	end
	
	return bReturnIsLocal, sFunctionName;
end

local sTestHeaderString = "--[[\
Autogenerated Test File for %s\
--]]\n\
package.path = package.path..package.path:gsub(\"Framework\",\"FakedFiles\");\
-------------------------------------Define setup code here for fake files here--------------------------------------\n\
--------------------------------------------------End of Setup Code--------------------------------------------------\n\
require(\"BlizzardFakes\");\
require(\"UnitTest\");\
require(\"Fake%s\");\n\n\
-----------------------------------------Define generel Test setup code here-----------------------------------------\n\
--------------------------------------------------End of Setup Code--------------------------------------------------\n\n";
local sTestTemplateString = "\tUnitTest_vStartTest();\n\n\t--Test1\n\tUnitTest_vTestAssert(false);\n\n\tUnitTest_vFinishTest();";

-- Starting Script --

local file = io.open('../_path.txt', 'rb');
local path = file:read"*a":gsub('"',''):gsub('\n',''):gsub(' ',''):gsub('\r',''):gsub('\t','');
file:close();

local nStartLuaExtentionPosition = string.find(path, "%.lua");
assert(nStartLuaExtentionPosition, "File is not a Lua file!");

file = io.open(path);

assert(file, "File not found!");

local i = nStartLuaExtentionPosition-1;
while path:sub(i,i) ~= '\\' and (i>0) do
	i = i - 1;
end

local sFileName = path:sub(i+1,nStartLuaExtentionPosition-1);

local _lines = file:lines();
local functionTable = {};

for line in _lines do
	local bIsLocal, sFunctionName = getFunctionName(line);
	if bIsLocal ~= nil then
		sFunctionName = sFunctionName:gsub(':','_'):gsub('%.','_');
		table.insert(functionTable, {["bLocal"]=bIsLocal, ["name"]=sFunctionName});
		print(string.format("local: %s, name: %s", tostring(bIsLocal), tostring(sFunctionName)));
	end
end

file:close();

file = io.open(string.format('../UnitTests/TEST%s.lua', sFileName), 'w+');
io.output(file);

io.write(string.format(sTestHeaderString, sFileName, sFileName));

i = 1;
local foo = functionTable[i];
while foo do
	if not foo["bLocal"] then
		io.write(string.format("function TEST_%s()\n%s\nend\n\n", foo["name"], sTestTemplateString));
	end
	i = i + 1;
	foo = functionTable[i];
end

io.write("UnitTest_vSetupTests();\n");
i = 1;
local foo = functionTable[i];
while foo do
	if not foo["bLocal"] then
		io.write(string.format("TEST_%s();\n", foo["name"], sTestTemplateString));
	end
	i = i + 1;
	foo = functionTable[i];
end
io.write("UnitTest_vFinalizeTests();\n");

file:close();

file = io.open('../RunAllTests.bat', 'r');
local content = file:read'*a';
file:close();

local bLineExists = (content:find(sFileName)) and true or false;

file = io.open('../RunAllTests.bat', 'w+');

if not bLineExists then
	if content:find("pause") then
		content = content:gsub("pause", string.format("lua54.exe ../UnitTests/TEST%s.lua\npause", sFileName));
	else
		content = content..string.format("\nlua54.exe ../UnitTests/TEST%s.lua\npause", sFileName);
	end
else
	if not content:find("pause") then
		content = content.."\npause";
	end
end

io.output(file):write(content);
file:close();

file = io.open('../RunAllTestsGitHub.bat', 'r');
local content = file:read'*a';
file:close();

local bLineExists = (content:find(sFileName)) and true or false;

file = io.open('../RunAllTestsGitHub.bat', 'w+');

if not bLineExists then
	if content:find("pause") then
		content = content:gsub("pause", string.format("lua54.exe ../UnitTests/TEST%s.lua\npause", sFileName));
	else
		content = content..string.format("\nlua54.exe ../UnitTests/TEST%s.lua\npause", sFileName);
	end
else
	if not content:find("pause") then
		content = content.."\npause";
	end
end

io.output(file):write(content);
file:close();