local com = require("component")
local modem = com.modem
local gpu = com.gpu
local cport = 0
local fs = require("filesystem")
local ser = require("serialization")
local event = require("event")
local thread = require("thread")
local colors = require("colors")
local shell = require("shell")
local prx = "server."

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

function getle(table) 
    local le = 0
    for k,v in pairs(table) do
        le = le + 1
    end
    return le
end

function runcmd(data)
    local nyam = shell.execute(data)
    return nyam
end

gpu.setBackground(colors.blue, true)
runcmd("clear")
print("port?")
cport = tonumber(io.read())
runcmd("clear")
print("cli port?")
local port = tonumber(io.read())
modem.open(cport)
runcmd("clear")

while true do
    local _,_,whoi,porti,_,msgi = event.pull("modem_message")
    print("data >> "..msgi)
    local ditoo = mysplit(msgi)
    if ditoo[1] == prx.."connect.adcli" then
        modem.send(whoi,port,"client.pong.adcli")
    end
    if ditoo[1] == prx.."connect" then
        modem.send(whoi,port,"PONG!")
    end
    if ditoo[1] == "fs.ls" then
        if ditoo[2] then
        else
            ditoo[2] = ""
        end
        local lol = fs.list("/home/pub/"..ditoo[2]) --runcmd("ls /home/pub/"..ditoo[2])
        local ls = {}
        for file in lol do
            table.insert(ls,file)
        end
        modem.send(whoi,port,ser.serialize(ls))
    end
    if ditoo[1] == "fs.get" then
        if fs.exists("/home/pub/"..ditoo[2]) then
            local asd = ""
            for line in io.lines("/home/pub/"..ditoo[2]) do
                asd=asd..line.."\n"
            end
            modem.send(whoi,port,asd)
        end
    end
    if ditoo[1] == "fs.upload" then
        modem.send(whoi,port,"processing....")
        local handle = fs.open("/home/pub/"..ditoo[2],"w")
        local nyaa = 3
        while nyaa < getle(ditoo) + 1 do
            handle:write(ditoo[nyaa])
        end
        handle:close()
        modem.send(whoi,port,"done!")
    end
end
