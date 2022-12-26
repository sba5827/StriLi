--[[
Class: ObservableNumber

variables:
	number
	numberOld
	observers
	
methods:
	--can be called--
	new
	add
	sub
	mul
	div
	set
	get
	registerObserver
	unregisterObserver
		
	--for local use only--
	notify
	
--]]

ObservableNumber = {}

function ObservableNumber:new(o)

    o = o or {};
    setmetatable(o, self);
    self.__index = self;

    o.number = 0;
    o.numberOld = 0;
    o.observers = {};

    return o;

end

function ObservableNumber:registerObserver(observer)
    --Observer must implement a method called OnValueChanged(sender)
    --Var sender helps the observer to identify which observed value changed, if multiple values are observed.

    if observer.OnValueChanged == nil then
        error(StriLi.Lang.ErrorMsg.ObserverImplement);
        return ;
    end

    table.insert(self.observers, observer);

end

function ObservableNumber:unregisterObserver(observer)

    for key, regObserver in pairs(self.observers) do

        if observer == regObserver then
            self.observers[key] = nil;
            return true;
        end

    end

    return false;

end

function ObservableNumber:notify()

    --Avoid calling observers, if number did not change
    if self.number == self.numberOld then
        return ;
    end

    for _, observer in pairs(self.observers) do
        observer:OnValueChanged(self);
    end

    self.numberOld = self.number;

end

function ObservableNumber:add(n)
    self.number = self.number + n;
    self:notify();
end

function ObservableNumber:sub(n)
    self.number = self.number - n;
    self:notify();
end

function ObservableNumber:mul(n)
    self.number = self.number * n;
    self:notify();
end

function ObservableNumber:div(n)
    self.number = self.number / n;
    self:notify();
end

function ObservableNumber:set(n)
    self.number = n;
    self:notify();
end

function ObservableNumber:get()
    return self.number;
end