Observable = {}

function Observable:new(o)

    o = o or {};
    setmetatable(o, self);
    self.__index = self;

    o.var = nil;
    o.varOld = nil;
    o.observers = {};

    return o;

end

function Observable:registerObserver(observer)
    --Observer must implement a method called OnValueChanged(sender)
    --Var sender helps the observer to identify which observed value changed, if multiple values are observed.

    if observer.OnValueChanged == nil then
        error(StriLi.Lang.ErrorMsg.ObserverImplement);
        return;
    end

    table.insert(self.observers, observer);

end

function Observable:unregisterObserver(observer)

    for key, regObserver in pairs(self.observers) do

        if observer == regObserver then
            self.observers[key] = nil;
            return true;
        end

    end

    return false;

end

function Observable:notify()

    --Avoid calling observers, if number did not change
    if self.var == self.varOld then
        return ;
    end

    for _, observer in pairs(self.observers) do
        observer:OnValueChanged(self);
    end

    self.varOld = self.var;

end

function Observable:set(n)
    self.var = n;
    self:notify();
end

function Observable:get()
    return self.var;
end

ObservableNumber = Observable:new();

function ObservableNumber:new(o)
    o = o or Observable:new(o);
    setmetatable(o, self)
    self.__index = self

    o.var = 0;
    o.varOld = 0;

    return o;
end

function ObservableNumber:add(n)
    self:set(self.var + n);
end

function ObservableNumber:sub(n)
    self:set(self.var - n);
end

function ObservableNumber:mul(n)
    self:set(self.var * n);
end

function ObservableNumber:divBy(n)
    self:set(self.var / n);
end

ObservableString = Observable:new();

function ObservableString:new(o)
    o = o or Observable:new(o);
    setmetatable(o, self)
    self.__index = self

    o.var = "";
    o.varOld = "";

    return o;
end

ObservableBool = Observable:new();

function ObservableBool:new(o)
    o = o or Observable:new(o);
    setmetatable(o, self)
    self.__index = self

    o.var = false;
    o.varOld = false;

    return o;
end