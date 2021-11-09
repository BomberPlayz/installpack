local component = require("component")
local eln = component.ElnProbe
local inv = component.inventory_controller
local ser = require("serialization")
local printer = component.openprinter

function dat(n,d)
  eln.wirelessSet(n,d)
end

local allsent = 0

local cooldown = 0
local ctab = {[0]="SYSTEM","red","lightblue","cyan","blue"}


function idToColor(id)
return ctab[id] or "UNKNOWN"
end


while true do
os.sleep(0)
dat("posta_go",0)


os.sleep(cooldown)

for k,v in ipairs(ctab) do dat("posta_"..v, 0  ) end
local slot = inv.getStackInSlot(4,2)


if slot then

print("Got a mail, lets check!")
print("Mail metadata: "..slot.label)

local ok,ret = pcall(ser.unserialize, slot.label)
if not ret then
print("Error while parsing metadata: "..tostring(ret)..", pufog to mail empty")
dat("posta_go",1)

else
print("From: "..ret.from.." ("..idToColor(ret.from)..")")
print("To: "..ret.to.." ("..idToColor(ret.to)..")")
allsent = allsent+1
if ret.to == 0 then
dat("posta_"..idToColor(ret.from),1)
else
dat("posta_"..idToColor(ret.to),1)
if not ret.meta or not ret.meta == "_REPLY" then
printer.setTitle("{from=0,to="..ret.from..",meta='_REPLY'}")
printer.writeln("Your §a§lMail§0 has been")
printer.writeln("processed by")
printer.writeln("§6§lSYSTEM§0")
printer.writeln("§a§l=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=")
printer.writeln("FROM: "..ret.from)
printer.writeln("TO: "..ret.to)
printer.writeln("MAIL #"..allsent)
printer.writeln(":: MAIL META ::")
printer.writeln(slot.label)
printer.print()
end
end
dat("posta_go",1)
cooldown = 8


end

end

end
