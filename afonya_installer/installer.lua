local com = require("component")
if com.isAvailable("gpu") == false then
    print("component not found: gpu")
    os.exit()
end
if com.isAvailable("internet") == false then
    print("component not found: internet")
    os.exit()
end
local gpu = com.gpu
local fs = require("filesystem")
local ser = require("serialization")
local event = require("event")
local thread = require("thread")
local colors = require("colors")
local shell = require("shell")

function runcmd(data)
    shell.execute(data)
end

function getle(table) 
    local le = 0
    for k,v in pairs(table) do
        le = le + 1
    end
    return le
end

function bar(x,y,dat,max)
    local i = 1
    while i < max do
        i = i + 1
        bar.gpu.setForeground(0xe02514)
        bar.gpu.set(x + i - 1,y,"█")
    end
    i = 1
    while i < dat do
        i = i + 1
        bar.gpu.setForeground(0x34e00d)
        bar.gpu.set(x + i - 1,y,"█")
    end
end

inst = {["serverc_server"]={"Server","This is a server","0.5 developer","EUKUKA","true","server.lua","https://raw.githubusercontent.com/afonya2/oc_softs/main/server.lua"},["serverc_client"]={"Client","This is a client","0.5 developer","EUKUKA","true","serverclient.lua","https://raw.githubusercontent.com/afonya2/oc_softs/main/server_client.lua"}}

gpu.setBackground(colors.blue, true)
runcmd("clear")
print("enter the want soft or type ls to list the softs >> ")
local asd = io.read()
print("where want to install >> ")
local asda = io.read()

if asd == "ls" then
    nyam = {"serverc_server","serverc_client"}
    local iu = 1
    while iu < getle(nyam) + 1 do
        print(nyam[iu])
        iu = iu + 1
    end
    os.exit()
end

local i = 1
local nyam = false
while i < getle(inst) + 1 do
    if inst[asd] then
        nyam = true
        print(inst[asd][1].." ver: "..inst[asd][3])
        print(inst[asd][2])
        print("-----------------")
        print(inst[asd][4])
        print("accept this shit?")
        local acc = io.read()
        if acc == "y" then
            local ia = 6
            while ia < getle(inst[asd]) + 1 do
                print("downloading file: "..inst[asd][ia+1].." ...")
                runcmd("wget "..inst[asd][ia+1].." /home/"..asda.."/"..inst[asd][ia])
                print("ok!")
                ia = ia + 1
                ia = ia + 1
            end
            print("done!")
            if inst[asd][5] == "true" then
               print("you soft requires reboot!")
               local acca = io.read()
               if acca == "y" then
                    runcmd("reboot")
               else
                    print("returning to shell....")
                    os.exit()
               end
            else
                print("returning to shell....")
                os.exit()
            end 
        else
            print("Why not accept this shit?")
            os.exit()
        end
    end
    i = i + 1
end
if nyam == false then
    print("not found this: "..asd)
    os.exit()
end

