local comp = require("computer")
local com = require("component")

local created = {{address="T9ste",name="Test",doc={test="prints hello!"},work={test=function() print("hello") end}}}
local removed = {}
local vcom = {}

local oproxy = com.proxy
com.proxy = function(address)
    checkArg(1,address,"string")
    for k,v in ipairs(created) do
        if v.address == address then
            return v.work
        end
    end
    for k,v in ipairs(removed) do
        if v.address == address then
            return
        end
    end
    return oproxy(address)
end

local olist = com.list
com.list = function(filter)
    checkArg(1,filter,"string","nil")
    local res = {}
    for k,v in ipairs(created) do
        if filter == nil then
            res[v.address] = v.name
        else
            if string.match(v.name,filter) ~= nil then 
                res[v.address] = v.name
            end
        end
    end
    local datad = olist(filter)
    for k,v in pairs(datad) do
        local per = true
        for ka,va in ipairs(removed) do
            if va.address == k then
                per = false
            end
        end
        if per == true then
            res[k] = v
        end
    end
    return setmetatable(res,{
    __call=function()
        for k,v in pairs(res) do
            return k,v
        end
    end
    })
end

local otype = com.type
com.type = function(address)
    checkArg(1,address,"string")
    for k,v in ipairs(created) do
        if v.address == address then
            return v.name
        end
    end
    for k,v in ipairs(removed) do
        if v.address == address then
            return
        end
    end
    return otype(address)
end

local odoc = com.doc
com.doc = function(address, data)
    checkArg(1,address,"string")
    checkArg(1,data,"string")
    for k,v in ipairs(created) do
        if v.address == address then
            return v.doc[data]
        end
    end
    for k,v in ipairs(removed) do
        if v.address == address then
            return
        end
    end
    return odoc(address, data)
end

local oslot = com.slot
com.slot = function(address)
    checkArg(1,address,"string")
    for k,v in ipairs(created) do
        if v.address == address then
            return -1
        end
    end
    for k,v in ipairs(removed) do
        if v.address == address then
            return
        end
    end
    return oslot(address)
end

local omethods = com.methods
com.methods = function(address)
    checkArg(1,address,"string")
    local mets = {}
    for k,v in ipairs(created) do
        if v.address == address then
            for ka,va in pairs(v.work) do
                if type(va) == "function" then
                    mets[ka] = true
                end
            end
            return mets
        end
    end
    for k,v in ipairs(removed) do
        if v.address == address then
            return
        end
    end
    return omethods(address)
end

local oinvoke = com.invoke
com.invoke = function(address, method, ...)
    checkArg(1,address,"string")
	checkArg(2,method,"string")
    for k,v in ipairs(created) do
        if v.address == address then
            if v.work[method] == nil then
                error("no such method",2)
            end
            return v.work[method](...)
        end
    end
    for k,v in ipairs(removed) do
        if v.address == address then
            return
        end
    end
    return oinvoke(address, method, ...)
end

local ofields = com.fields
com.fields = function(address)
    checkArg(1,address,"string")
	for k,v in ipairs(created) do
        if v.address == address then
            return {}
        end
    end
    for k,v in ipairs(removed) do
        if v.address == address then
            return
        end
    end
    return ofields(address)
end

vcom.register = function(address,name,doc,work)
    checkArg(1,address,"string")
	checkArg(1,name,"string")
    checkArg(1,doc,"table")
	checkArg(1,work,"table")
    if com.type(address) ~= nil then
        return false, "Component exists!"
    end
    for k,v in ipairs(created) do
        if v.address == address then
            return false, "Component exists!"
        end
    end
    table.insert(created,{address=address,name=name,doc=doc,work=work})
    comp.pushSignal("component_added",address,name)
    return true
end

vcom.unregister = function(address)
    checkArg(1,address,"string")
    local da = {}
    for k,v in ipairs(created) do
        if v.address == address then
            created[k] = nil
            comp.pushSignal("component_removed",address,v.name)
            return true
        end
    end
    return false, "component not exists"
end

vcom.list = function() 
    local ret = {}
    for k,v in ipairs(created) do
        table.insert(ret,v)
    end
    return ret
end

vcom.removereal = function(address) 
    checkArg(1,address,"string")
    if com.type(address) == nil then
        return false, "Component not exists!"
    end
    for k,v in ipairs(created) do
        if v.address == address then
            return false, "Component created by vcom!"
        end
    end
    table.insert(removed,{address=address,name=com.type(address)})
    comp.pushSignal("component_removed",address,com.type(address))
    return true
end

vcom.unremovereal = function(address) 
    checkArg(1,address,"string")
    if com.type(address) ~= nil then
        return false, "Component exists!"
    end
    for k,v in ipairs(created) do
        if v.address == address then
            return false, "Component created by vcom!"
        end
    end
    for k,v in ipairs(removed) do
        if v.address == address then
            removed[k] = nil
            comp.pushSignal("component_added",address,v.name)
            return true
        end
    end
    return false, "an error"
end

vcom.removedlist = function() 
    local ret = {}
    for k,v in ipairs(removed) do
        table.insert(ret,v)
    end
    return ret
end

return vcom
