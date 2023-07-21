local bTestStarted = false;
local file = nil;
local bTestSucceeded = true;
local nTestCount = 0;
local nTestSucceedCount = 0;

local function __FILE__() return debug.getinfo(3, 'S').source end
local function __LINE__() return debug.getinfo(3, 'l').currentline end
local function __FUNC__() return debug.getinfo(3, 'n').name end

function UnitTest_vSetupTests()
	file = io.open (__FILE__():gsub('.lua', ''):gsub('@',''):gsub('UnitTests','Outputs').."_OUT.txt" , "w+");
end

function UnitTest_vFinalizeTests()
	io.close(file)
end

function UnitTest_vStartTest()
	assert(not bTestStarted);
	bTestStarted = true;
	nTestCount = 0;
	nTestSucceedCount = 0;
	
	io.output(file);
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
	sMessage = sMessage or "";
	if not bCondition then 
		io.write(string.format("TEST %s Line %s faild. %s\n", __FUNC__(), __LINE__(),tostring(sMessage)));
		print(string.format("TEST %s Line %s faild. %s", __FUNC__(), __LINE__(),tostring(sMessage)));
		bTestSucceeded = false;
	else
		nTestSucceedCount = nTestSucceedCount + 1;
	end 
end