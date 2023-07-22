BaseFrame = {}

function BaseFrame:SetScript(handler, fnc)
	if handler == "OnUpdate" then
		self.OnUpdate = fnc;
	else
		assert(false,"Given handler not valid/implemented");
	end
end

function CreateFrame(frameType, frameName, parentFrame, inheritsFrame)
	frameType = string.lower(frameType);
	assert(frameType=="frame");
	
	if frameName then
		assert(type(frameName)=="string");
	end
	
	if parentFrame then
		assert(type(parentFrame)=="table");
	end
	
	if inheritsFrame then
		assert(type(inheritsFrame)=="string");
	end
	
	local newFrame = {
		OnUpdate = nil,
	}
	
	setmetatable(newFrame, BaseFrame);
end

function GetLocale()
	return "enGB";
end

function LibStub()
	return {NewAddon = function() return {} end};
end

local sLastMsg, sLastMsgType;

function SendChatMessage(msg ,chatType ,language ,channel);

	assert(type(msg) == "string");
	
	sLastMsg = msg;
	sLastMsgType = chatType;
	
end

function GetLastChatMessage()
	return sLastMsg;
end

function GetLastChatMessageType()
	return sLastMsgType;
end