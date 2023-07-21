local bTestStarted = false;
local file = nil;
local bTestSucceeded = true;
local nTestCount, nAllTestCount = 0, 0;
local nTestSucceedCount, nAllTestSucceedCount = 0, 0;

local function __FILE__() return debug.getinfo(3, 'S').source end
local function __LINE__() return debug.getinfo(3, 'l').currentline end
local function __FUNC__() return debug.getinfo(3, 'n').name end

function UnitTest_vSetupTests()
	nAllTestCount = 0;
	nAllTestSucceedCount = 0;
	file = io.open (__FILE__():gsub('.lua', ''):gsub('@',''):gsub('UnitTests','Outputs').."_OUT.txt" , "w+");
	io.output(file);
	io.write(string.format("Starting Tests for Module %s.\n", __FILE__():gsub('.lua', ''):gsub('@',''):gsub('UnitTests',''):gsub('..//','')));
	print(string.format("Starting Tests for Module %s.", __FILE__():gsub('.lua', ''):gsub('@',''):gsub('UnitTests',''):gsub('..//','')));
end

function UnitTest_vFinalizeTests()
	if nAllTestCount == 0 then
			nAllTestCount = 1;
		end
	io.write(string.format("Module %s: %d%% passed.\n\n", __FILE__():gsub('.lua', ''):gsub('@',''):gsub('UnitTests',''):gsub('..//',''), math.floor(nAllTestSucceedCount/nAllTestCount*100)));
	print(string.format("Module %s: %d%% passed.\n", __FILE__():gsub('.lua', ''):gsub('@',''):gsub('UnitTests',''):gsub('..//',''), math.floor(nAllTestSucceedCount/nAllTestCount*100)));
	io.close(file)
end

function UnitTest_vStartTest()
	assert(not bTestStarted);
	bTestStarted = true;
	nTestCount = 0;
	nTestSucceedCount = 0;
end

function UnitTest_vFinishTest()
	assert(bTestStarted);
	if bTestSucceeded then
		io.write(string.format("TEST %s succeeded.\n", __FUNC__()));
		print(string.format("TEST %s succeeded.", __FUNC__()));
	else
		if nTestCount == 0 then
			nTestCount = 1;
		end
		
		io.write(string.format("TEST %s: %d%% passed.\n", __FUNC__(), math.floor(nTestSucceedCount/nTestCount*100)));
		print(string.format("TEST %s: %d%% passed.", __FUNC__(), math.floor(nTestSucceedCount/nTestCount*100)));
	end
	
	bTestStarted = false;
	bTestSucceeded = true;
end

function UnitTest_vTestAssert(bCondition, sMessage) 
	nTestCount = nTestCount + 1;
	nAllTestCount = nAllTestCount + 1;
	sMessage = sMessage or "";
	if not bCondition then 
		io.write(string.format("TEST %s Line %s faild. %s\n", __FUNC__(), __LINE__(),tostring(sMessage)));
		print(string.format("TEST %s Line %s faild. %s", __FUNC__(), __LINE__(),tostring(sMessage)));
		bTestSucceeded = false;
	else
		nTestSucceedCount = nTestSucceedCount + 1;
		nAllTestSucceedCount = nAllTestSucceedCount + 1;
	end 
end