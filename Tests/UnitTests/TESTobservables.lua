--[[
Autogenerated Test File for observables
--]]

package.path = package.path..package.path:gsub("Framework","FakedFiles");
-------------------------------------Define setup code here for fake files here--------------------------------------

--------------------------------------------------End of Setup Code--------------------------------------------------

require("BlizzardFakes");
require("UnitTest");
require("Fakeobservables");


-----------------------------------------Define generel Test setup code here-----------------------------------------

--------------------------------------------------End of Setup Code--------------------------------------------------

function TEST_Observable:new()
	UnitTest_vStartTest();

	--Test1
	UnitTest_vTestAssert(false);

	UnitTest_vFinishTest();
end

function TEST_Observable:registerObserver()
	UnitTest_vStartTest();

	--Test1
	UnitTest_vTestAssert(false);

	UnitTest_vFinishTest();
end

function TEST_Observable:unregisterObserver()
	UnitTest_vStartTest();

	--Test1
	UnitTest_vTestAssert(false);

	UnitTest_vFinishTest();
end

function TEST_Observable:notify()
	UnitTest_vStartTest();

	--Test1
	UnitTest_vTestAssert(false);

	UnitTest_vFinishTest();
end

function TEST_Observable:set()
	UnitTest_vStartTest();

	--Test1
	UnitTest_vTestAssert(false);

	UnitTest_vFinishTest();
end

function TEST_Observable:get()
	UnitTest_vStartTest();

	--Test1
	UnitTest_vTestAssert(false);

	UnitTest_vFinishTest();
end

function TEST_ObservableNumber:new()
	UnitTest_vStartTest();

	--Test1
	UnitTest_vTestAssert(false);

	UnitTest_vFinishTest();
end

function TEST_ObservableNumber:add()
	UnitTest_vStartTest();

	--Test1
	UnitTest_vTestAssert(false);

	UnitTest_vFinishTest();
end

function TEST_ObservableNumber:sub()
	UnitTest_vStartTest();

	--Test1
	UnitTest_vTestAssert(false);

	UnitTest_vFinishTest();
end

function TEST_ObservableNumber:mul()
	UnitTest_vStartTest();

	--Test1
	UnitTest_vTestAssert(false);

	UnitTest_vFinishTest();
end

function TEST_ObservableNumber:divBy()
	UnitTest_vStartTest();

	--Test1
	UnitTest_vTestAssert(false);

	UnitTest_vFinishTest();
end

function TEST_ObservableString:new()
	UnitTest_vStartTest();

	--Test1
	UnitTest_vTestAssert(false);

	UnitTest_vFinishTest();
end

function TEST_ObservableBool:new()
	UnitTest_vStartTest();

	--Test1
	UnitTest_vTestAssert(false);

	UnitTest_vFinishTest();
end

UnitTest_vSetupTests();
TEST_Observable:new();
TEST_Observable:registerObserver();
TEST_Observable:unregisterObserver();
TEST_Observable:notify();
TEST_Observable:set();
TEST_Observable:get();
TEST_ObservableNumber:new();
TEST_ObservableNumber:add();
TEST_ObservableNumber:sub();
TEST_ObservableNumber:mul();
TEST_ObservableNumber:divBy();
TEST_ObservableString:new();
TEST_ObservableBool:new();
UnitTest_vFinalizeTests();
