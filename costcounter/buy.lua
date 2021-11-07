local cost = require("costapi")
local args = {...}

--print(args[1])
local c = 0
local k = 1
while true do
if(type(args[k]) == "nil") then break end
  --print(args[k])
  
  for i=1,tonumber(args[k]) do
   -- print(args[k+1])
     --print("cc: "..cost.calc("computer_probe"))
    if args[k+1] == "all" then
      --print("asdsad")
      for kk in pairs(cost.costDb) do
        --print("kk is "..kk.." and vv is "..vv)
       -- print(kk)
        local fora = cost.calc(kk)
        print(kk.." for "..fora)
        c = c+fora
      end
    else
    
    c = c+cost.calc(args[k+1])
    end
  end
  --print("acalc")
  k = k+2
end
print("COST: "..c)
