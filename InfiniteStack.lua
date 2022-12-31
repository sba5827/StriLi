InfiniteStack = { stackType=nil, stack={}, count=0}

function InfiniteStack:new(o, stackType)

	o = o or {};
	setmetatable(o, self);
	self.__index = self;
	
	self.stackType=stackType;
	
	return o;
	
end

function InfiniteStack:push(element)
	
	self.count = self.count+1;
	self.stack[self.count]=element;
	
end

function InfiniteStack:pop(...)
	
	if self.count < 1 then
		return self.stackType:new(...);
	else
		self.count = self.count-1;
		return self.stack[self.count+1]:reInit(...);
	end
	
end