InfiniteStack = { stackType=nil, stack={}}

function InfiniteStack:new(o, stackType)

	o = o or {};
	setmetatable(o, self);
	self.__index = self;
	
	self.stackType=stackType;
	
	return o;
	
end

function InfiniteStack:push(element)
	table.insert(self.stack, element);
end

function InfiniteStack:pop(...)

	local returnElm =  table.remove(self.stack);

	if returnElm == nil then
		return self.stackType:new(...);
	else
		return returnElm:reInit(...);
	end
	
end

function InfiniteStack:dumpRemainingElements()

	local returnElm =  table.remove(self.stack);

	while returnElm ~= nil do
		returnElm =  table.remove(self.stack);
	end

end