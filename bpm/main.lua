local component = require("component")
local internet = require("internet")
local gpu = component.gpu
local fs = require("filesystem")
local args, options = require("shell").parse(...)
local ser = require("serialization")
local term = require("term")

local path = "https://raw.githubusercontent.com/BomberPlayz/installpack/main/"

local statusCursors = {"|","/","-","\\"}
local statusNow = 1

local scx, scy = term.getCursor()

function status(info, text)
    local _msg = text
    gpu.setForeground(0xffffff)
    if info == "error" then
        gpu.setForeground(0xFF0000)
        _msg = "[ERROR] > ".._msg
    elseif info == "warn" then
        gpu.setForeground(0xFFFF00)
        _msg = "[WARNING] > ".._msg
    elseif info == "info" then
        gpu.setForeground(0x0000FF)
        _msg = "[INFO] > ".._msg
    end
    local rx,ry = gpu.getResolution()
    gpu.fill(0,scy,rx,1, " ")
    term.setCursor(scx,scy)
    local bf = gpu.getForeground()
    local bg = gpu.getBackground()
    gpu.setForeground(0xffffff)
    io.write(statusCursors[statusNow].." ")
    gpu.setBackground(0xAAAAAA)
    io.write((debug.getinfo(4).name or "Unknown"))
    gpu.setForeground(bf)
    gpu.setBackground(bg)
    io.write("   ")

    statusNow = statusNow+1
    if statusNow > #statusCursors then statusNow = 1 end

    print(_msg)
end

function getFullData(url)
    local data = ""
    local i = 0
    status("info","Fetching data from "..url)
    for chunk in internet.request(url) do
        i = i+1
        --status("info","Received data chunk "..i)
        data = data..chunk
    end
    --status("info","getFullData ended.")
    return data
end

function checkPackagePath(name)
    status("info","Checking package path of package name '"..name.."'")
    local ret,a = ser.unserialize(getFullData(path.."packages.cfg"))
    if not ret[name].name then
        ret[name].name = "Unknown"
    end
    status("warn",a or "no")
    if ret[name] then
        status("info","check complete, Package path is: "..ret[name].path)
        return ret[name]
    else
        status("info","check complete, package was not found.")
        return "err_no"
    end


end

function getTableData(file)
    status("info","Getting data from '"..file.."'")
    local ret,a = ser.unserialize(getFullData(path..file))
    --status("warn",a or "no")
    return ret


end

function getDeps(pcktbl)
    status("info","Getting dependencies for package '"..pcktbl.name.."'")
    local ret = {}
    if not pcktbl.dependency then return ret end
    for i,v in pairs(pcktbl.dependency) do
        status("info","Indexing dependency '"..v.."'")
        ret[i] = {}
        ret[i].name = i
        ret[i].path = checkPackagePath(i).path
    end
    return ret
end

function install(url,loc)
    status("info","Installing '"..url.."' to '"..loc.."'")
    local fileData = getFullData(url)
    local handle = fs.open(loc,"w")
    handle:write(fileData)
    handle:close()
end



if args[1] == "install" then
    local patha = checkPackagePath(args[2])
    -- status("warn","dumped: "..ser.serialize(patha))
    if patha ~= "err_no" then
        local packageData = getTableData(patha.path.."/package_info.cfg")
        -- status("warn",ser.serialize(packageData))
        local deps = getDeps(packageData)
        for k,v in pairs(deps) do
            local depPkg = getTableData(v.path.."/package_info.cfg")
            for k,v in pairs(depPkg.files) do
                install(path..depPkg.path.."/"..k,packageData.files[k])
            end
        end
        for k,v in pairs(packageData.files) do
            install(path..patha.path.."/"..k,packageData.files[k])
        end
        status("info","Install complete!")
    end
end

if args[1] == "update" then
    local patha = checkPackagePath(args[2])
    -- status("warn","dumped: "..ser.serialize(patha))
    if patha ~= "err_no" then
        local packageData = getTableData(patha.path.."/package_info.cfg")
        -- status("warn",ser.serialize(packageData))


        local deps = getDeps(packageData)
        for k,v in pairs(deps) do
            local depPkg = getTableData(v.path.."/package_info.cfg")
            for k,v in pairs(depPkg.files) do
                local toupgrade = true
                if fs.exists(path..depPkg.path.."/"..k) then
                    local file = fs.open(path..depPkg.path.."/"..k)
                    local fileData = file:read(math.huge)
                    if fileData == getFullData(v) then
                        toupgrade = false
                    end
                else
                    toupgrade = true
                end
                if toupgrade then
                    install(path..depPkg.path.."/"..k,packageData.files[k])
                end
            end
        end

        for k,v in pairs(packageData.files) do
            local toupgrade = true
            if fs.exists(path..patha.path.."/"..k) then
                local file = fs.open(path..patha.path.."/"..k)
                local fileData = file:read(math.huge)
                if fileData == getFullData(v) then
                    toupgrade = false
                end
            else
                toupgrade = true
            end
            if toupgrade then
                install(path..patha.path.."/"..k,packageData.files[k])
            end

        end
        status("info","Update complete!")
    end
end
