local com = require("component")
if com.isAvailable("gpu") == false then
    print("component not found: gpu")
    os.exit()
end
if com.isAvailable("internet") == false then
    print("component not found: internet")
    os.exit()
end
if com.isAvailable("robot") == false then
    print("component not found: robot")
    os.exit()
end
local invcont = com.inventory_controller
local bot = com.robot
local gpu = com.gpu
local sides = require("sides")
local fs = require("filesystem")
local ser = require("serialization")
local event = require("event")
local thread = require("thread")
local colors = require("colors")
local shell = require("shell")
local moneys = {["minecraft:iron_ingot"]="100",["minecraft:gold_ingot"]="500",["minecraft:diamond"]="1000"}
local bolts = {["minecraft:planks"]="100"}

function cont(table, data)
    for _, value in pairs(table) do
        if value == data then
            return true
        end
    end
    return false
end

function getle(table) 
    local le = 0
    for k,v in pairs(table) do
        le = le + 1
    end
    return le
end

local nowmon = {["minecraft:iron_ingot"]="1.0",["minecraft:gold_ingot"]="1.0",["minecraft:diamond"]="1.0"}

bot.select(4)
while true do
    bot.suck(sides.forward)
    local item = invcont.getStackInInternalSlot(4)
    if item then
        print(item.name)
        if bolts[item.name] then
            local vaitfor = tonumber(bolts[item.name])
            print("I needed money: "..bolts[item.name])
            local itema = invcont.getStackInInternalSlot(1)
            local itemb = invcont.getStackInInternalSlot(2)
            local itemc = invcont.getStackInInternalSlot(3)
            while itema.size < tonumber(nowmon[itema.name]) or itemb.size < tonumber(nowmon[itemb.name]) or itemc.size < tonumber(nowmon[itemc.name]) or itema.size == tonumber(nowmon[itema.name]) or itemb.size == tonumber(nowmon[itemb.name]) or itemc.size == tonumber(nowmon[itemc.name]) do
                bot.select(1)
                bot.suck(sides.forward)
                os.sleep(1)
                bot.select(2)
                bot.suck(sides.forward)
                os.sleep(1)
                bot.select(3)
                bot.suck(sides.forward)
                os.sleep()
            end
            bot.select(4)
            if moneys[itema.name] then
                vaitfor = vaitfor - tonumber(moneys[itema.name])
                nowmon[itema.name] = tostring(tonumber(nowmon[itema.name] + 1))
                print("I needed money: "..vaitfor)
            end
            if moneys[itemb.name] then
                vaitfor = vaitfor - tonumber(moneys[itemc.name])
                nowmon[itema.name] = tostring(tonumber(nowmon[itemb.name] + 1))
                print("I needed money: "..vaitfor)
            end
            if moneys[itemc.name] then
                vaitfor = vaitfor - tonumber(moneys[itemc.name])
                nowmon[itema.name] = tostring(tonumber(nowmon[itemc.name] + 1))
                print("I needed money: "..vaitfor)
            end
            if vaitfor == 0 then
                print("ok")
                bot.drop(sides.forward)
            end
            if vaitfor < 0 then
                print("ok")
                bot.drop(sides.forward)
            end
        else
            bot.drop(sides.forward)
        end
    end
    os.sleep()
end