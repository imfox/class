local function clone(object, base)
    local lookup_table = base or {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

---@class Class
---@field new fun:Class
---@field protected setter fun(self:Class,key:string,func:fun)
---@field protected getter fun(self:Class,key:string,func:fun)
---@field protected setter_getter fun(self:Class,key:string,set:fun,get:fun)
---@field protected ctor fun(self:Class)

---@return Class
local function Class(...)
    -- super list
    local cls
    local superList = { ... }

    if (#superList > 0) then
        cls = clone(superList[1])

        for n = 2, #superList do
            cls = clone(superList[n], cls)
        end
    else
        cls = {
            ctor = function()
            end
        }
    end

    function cls.new(...)
        local sets = {}
        local gets = {}
        local instance = setmetatable({}, {
            __index = function(t, k)
                if gets[k] then
                    return gets[k](t)
                end
                return cls[k]
            end,
            __newindex = function(t, k, v)
                if sets[k] then
                    return sets[k](t, v)
                elseif gets[k] then
                    return
                end
                rawset(t, k, v)
            end
        });
        if instance.setter or instance.getter then
            error("error : Prohibition of override 'setter' and 'getter' Function;");
        end
        function instance:setter(name, func)
            instance[name] = nil
            sets[name] = func
            return instance
        end
        function instance:getter(name, func)
            instance[name] = nil
            gets[name] = func
            return instance
        end
        function instance:setter_getter(name, set, get)
            instance[name] = nil
            sets[name] = set;
            gets[name] = get;
        end

        instance.class = cls
        instance:ctor(...)
        return instance
    end

    return cls
end

return Class
