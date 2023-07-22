function SetScript(self, handler, fnc)
	if handler == "OnUpdate" then
		self.OnUpdate = fnc;
	elseif handler == "OnEvent" then
		self.OnEvent = fnc;
	else
		assert(false,"Given handler not valid/implemented");
	end
end

function RegisterEvent(self, event)
	assert(type(event) == "string");
	
	if event == "ADDON_LOADED" then
	elseif event == "PLAYER_LOGOUT" then
	elseif event == "PARTY_MEMBERS_CHANGED" then
	elseif event == "PARTY_MEMBER_DISABLE" then
	elseif event == "PARTY_MEMBER_ENABLE" then
	elseif event == "CHAT_MSG_ADDON" then
	elseif event == "CHAT_MSG_WHISPER" then
	elseif event == "CHAT_MSG_SYSTEM" then
	else
		assert(false, "Given event not valid/implemented");
	end
	
	self.eventTypes[event] = true;
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
		eventTypes = {},
		OnUpdate = nil,
		OnEvent = nil,
		SetScript = SetScript,
		RegisterEvent = RegisterEvent,
	}
	
	return newFrame;
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