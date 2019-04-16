# class

#### example
```lua
local class = require("class")

local a = class()
function a:ctor()
    print("a")
end
function a:funcA()
    print("funcA")
end
------------------
local b = class(a)
function b:ctor()
    a.ctor(self)
    print("b")
end
function b:funcB()
    print("funcB")
end
------------------
local c = class(b)
function c:ctor()
    b.ctor(self)
    print("c")
    self._x = nil;
    self:setter("x",function (v)
        self._x = v;
        print("setter x:" .. v)
    end)
    self:getter("x",function()
        print("getter x:" .. self._x)
        return self._x;
    end)
end
function c:funcC()
    print("funcC")
    return self
end
------------------
local d = class(c)
function d:ctor()
    c.ctor(self)
    print("d")
end

local t = d.new()
t:funcA()
t.x = "hello";
print(t.x);
t:funcC():funcB()
```