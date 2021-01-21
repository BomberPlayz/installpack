local com = require("component")
local modem = com.modem
local gpu = com.gpu
local cport = 0
local fs = require("filesystem")
local event = require("event")
local thread = require("thread")
local colors = require("colors")
local shell = require("shell")

function mysplit (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function catc(reas)
    gpu.setForeground(0xea7e12)
    print("A kapcsolatot a távoli állomás kényszerítetten bezárta")
    print("     "..reas)
    os.exit()
end

function runcmd(data)
    shell.execute(data)
end

gpu.setBackground(colors.blue, true)
runcmd("clear")
print("port?")
local port = tonumber(io.read())
runcmd("clear")
print("cli port?")
cport = tonumber(io.read())
modem.open(cport)

thread.create(function()
    print("thread 1 started!")
    while true do
        local _,_,whoia,portia,_,msgia = event.pull(1,"modem_message")
        local mms = mysplit(msgia)
        if mss[1] == "client.disconnect.adcli" then
            catc(mss[2])
        end
        if mss[1] == "done!" then
            print("server >> done!")
        end
    end
end)

local dat = false
local i = 1
while i ~= 10 do
    i = i + 1
    --print(i)
    modem.broadcast(port, "server.connect.adcli")
    local _,_,who,port,_,msg = event.pull(1,"modem_message")
    if msg == "client.pong.adcli" then
        runcmd("clear")
        dat = true
        break
    end    
end
if dat == true then
    while true do
        print("command >> ")
        local data = io.read()
        print("client >> "..data)
        dat = false
        i = 1
        while i ~= 10 do
            i = i + 1
            local fit = mysplit(data)
            if fit[1] == "fs.upload" then
                if fs.exists("/home/files/"..fit[2]) then
                    local asd = ""
                    for line in io.lines("/home/files/"..fit[2]) do
                        asd=asd..line.."\n"
                    end
                    modem.broadcast(port, "fs.upload "..fit[2].." "..asd)
                end
            else
                modem.broadcast(port, data)
            end
            local _,_,whoi,porti,_,msgi = event.pull(1,"modem_message")
            if msgi then
                dat = true
                if fit[1] == "fs.get" then
                    local handle = fs.open("/home/files/"..fit[2],"w")
                    handle:write(msgi)
                    handle:close()
                    print("server >> done")
                else
                    print("server >> "..msgi)  
                end
                break
            end
        end
        if dat == false then
            print("A kapcsolatot a helyi állomás kényszerítetten bezárta")
            print("     Időtúllépés!")
            os.exit()
        end
    end
end
if dat == false then
    print("A kapcsolat nem létesíthető")
    print("     Nem létező host!")
    os.exit()
end
