local cost = require("costapi")
local args = {...}

--print(args[1])
local c = 0
local k = 1
while true do
if(type(args[k]) == "nil") then break end
  --print(args[k])
  
  for i=1,tonumber(args[k]) do
    --print(args[k+1])
     --print("cc: "..cost.calc("computer_probe"))
    c = c+cost.calc(args[k+1])
  end
  --print("acalc")
  k = k+2
end
print(c*0.75)
