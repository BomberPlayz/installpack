function class(classname, super)
    local c = {}		-- a new class instance
    c.__cname = classname
    c.__ctype = "class"
    c.__index = c

    -- class will be the metatable for all its objects
    setmetatable(c, {__call = function(c, ...)
        local obj = {}
        setmetatable(obj, c)
        if c.ctor then
            c.ctor(obj, ...)
        end
        return obj
    end})

    -- define a new constructor for this class
    c.new = function(...)
        return c(...)
    end

    -- copy fields from super class
    if super then
        local mt = getmetatable(super)
        for k, v in pairs(super) do
            c[k] = v
        end
        setmetatable(c, mt)
    end

    -- define all fields here
    c.__call = function(c, ...)
        local obj = {}
        setmetatable(obj, c)
        if c.ctor then
            c.ctor(obj, ...)
        end
        return obj
    end

    return c
end

return class
