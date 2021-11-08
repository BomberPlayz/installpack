local api = {}
local costDb = {
iron_ingot= 0.8,
diamond= 60,
clay_item= 0.15,
copper_ingot= 0.45,
copper_cable= {"copper_ingot","copper_ingot","copper_ingot"},
stone= 0.07,
cobblestone= 0.04,
stone_bricks= {"stone","stone","stone","stone"},
rubber= 0.15,
["50v_cable"]= {"rubber","copper_cable"},
["200v_cable"]= {"rubber","50v_cable"},
["800v_cable"]= {"rubber", "200v_cable"},
["3200v_cable"] = {"rubber", "800v_cable"},
thermal_cable = {"copper_cable","cobblestone"},
["200v_switch"]= {"copper_cable","copper_cable","rubber","rubber","rubber","200v_cable","200v_cable"},
silicon= 0.5,
redstone= 0.40,
cheap_chip= {"silicon","redstone","redstone","redstone","redstone"},
advanced_chip= {"silicon","silicon","silicon","silicon","redstone","redstone","redstone","redstone","cheap_chip"},
iron_ingot= 0.6,
iron_cable= {"iron_ingot","iron_ingot"},
antenna= {"iron_cable","iron_cable"},
signal_transmitter= {"antenna","redstone","cheap_chip","iron_cable","iron_cable"},
signal_receiver= {"antenna","cheap_chip","iron_cable","iron_cable"},
signal_cable= {"iron_cable","rubber"},
computer_probe= {"signal_transmitter","signal_receiver","advanced_chip","iron_cable","iron_cable","iron_cable","iron_cable","signal_cable","signal_cable"},
log= 0.65,
arc_clay_ingot= 3.6,
arc_clay_block= {"arc_clay_ingot","arc_clay_ingot","arc_clay_ingot","arc_clay_ingot","arc_clay_ingot","arc_clay_ingot","arc_clay_ingot","arc_clay_ingot","arc_clay_ingot"},
["t1_pole"]= {"log","log","log","log","log","arc_clay_ingot","arc_clay_ingot"},
cheap_ferro_core= {"iron_cable","iron_cable","iron_cable","iron_cable","iron_cable","iron_cable","iron_cable"},
iron_plate= 1.42,
average_ferro_core = {"cheap_ferro_core","iron_plate","iron_plate"},
optimal_ferro_core = {"average_ferro_core","iron_plate","iron_plate","iron_plate","iron_plate"},
dc_dc_converter = {"iron_ingot","iron_ingot","iron_ingot","copper_cable","copper_cable"},
["t1_transformer_pole"] = {"t1_pole","800v_cable","800v_cable","800v_cable","800v_cable","dc_dc_converter","optimal_ferro_core"},
silicon_plate= 3.11,
lapis_dust=0.93,
small_solar_panel= {"silicon_plate","lapis_dust","lapis_dust","lapis_dust","50v_cable","50v_cable","iron_ingot","iron_ingot","iron_ingot"},
arc_metal= 0.98,
arc_metal_block = {"arc_metal","arc_metal","arc_metal","arc_metal","arc_metal","arc_metal","arc_metal","arc_metal","arc_metal"},
["2x3_solar_panel"] = {"small_solar_panel","small_solar_panel","small_solar_panel","small_solar_panel","small_solar_panel","small_solar_panel","arc_metal_block","arc_metal_block"},
glowstone=0.41,
glass_pane=0.18,
["200v_economic_bulb"]={"glass_pane","glass_pane","glass_pane","glowstone","200v_cable"},
["3200v_switch"]={"rubber","rubber","rubber","rubber","rubber","copper_cable","copper_cable","3200v_cable","3200v_cable"},
combustion_chamber={"stone","stone","stone","stone"},
stone_heat_furnace={"stone","stone","stone","stone","stone","stone","stone","combustion_chamber","thermal_cable"},
tree_resin=0.2,
alloy_plate= 3.4,
advanced_machine_box={"tree_resin","tree_resin","tree_resin","tree_resin","alloy_plate","alloy_plate","alloy_plate","alloy_plate","copper_cable"},
advanced_magnet=2.8,
advanced_electric_motor={"redstone","redstone","200v_cable","200v_cable","200v_cable","advanced_magnet","advanced_magnet","iron_ingot"},
["200v_turbine"]={"rubber","rubber","rubber","rubber","200v_cable","thermal_cable","thermal_cable","advanced_electric_motor","advanced_machine_box"},
passive_dissipator={"copper_ingot","copper_ingot","copper_ingot","copper_ingot","copper_ingot","copper_ingot","thermal_cable","thermal_cable"},
["200v_dissipator"]={"passive_dissipator","rubber","rubber","advanced_electric_motor"},
electrical_probe_chip={"800v_cable","redstone","redstone","redstone","redstone"},
electrical_probe={"electrical_probe_chip","electrical_probe_chip","signal_cable"},
steam_turbine={"arc_clay_ingot","arc_clay_ingot","arc_clay_ingot","arc_clay_block","advanced_machine_box"},
generator={"800v_cable","advanced_machine_box","arc_clay_ingot","arc_clay_ingot","advanced_electric_motor","advanced_electric_motor","advanced_electric_motor","advanced_electric_motor"},
gas_turbine={"arc_metal_block","arc_metal","arc_metal","arc_metal","advanced_electric_motor","thermal_cable"},
machine_box={"copper_cable","iron_cable","iron_cable","iron_cable","iron_cable","tree_resin","tree_resin","tree_resin","tree_resin"},
joint={"iron_ingot","iron_ingot","iron_ingot","machine_box"},
joint_hub={"iron_ingot","iron_ingot","iron_ingot","iron_ingot","machine_box"},
lead_ingot=2.4,
flywheel={"lead_ingot","lead_ingot","lead_ingot","lead_ingot","lead_ingot","lead_ingot","lead_ingot","lead_ingot","machine_box"},
tachometer={"machine_box","iron_ingot","iron_ingot","iron_ingot","signal_cable","electrical_probe_chip"},
shaft_motor={"iron_ingot","iron_ingot","advanced_electric_motor","advanced_machine_box","3200v_cable"},
clutch={"iron_ingot","iron_ingot","machine_box","iron_plate"},
iron_block={"iron_ingot","iron_ingot","iron_ingot","iron_ingot","iron_ingot","iron_ingot","iron_ingot","iron_ingot","iron_ingot"},
fixed_shaft={"iron_block","iron_ingot","iron_ingot","machine_box"},
tungsten=7.2,
tungsten_dust={"tungsten"},
iron_clutch_plate={"tungsten_dust","tungsten_dust","tungsten_dust","tungsten_dust","iron_plate"},
clutch_pin={"arc_metal","arc_metal"},
gold=4.8,
gold_plate={"gold_ingot"},
gold_clutch_plate={"tungsten_dust","tungsten_dust","tungsten_dust","tungsten_dust","gold_plater"},
lead_plate={"lead_ingot"},
lead_clutch_plate={"tungsten_dust","tungsten_dust","tungsten_dust","tungsten_dust","lead_plate"},
coal_plate={"coal"},
coal_clutch_plate={"tungsten_dust","tungsten_dust","tungsten_dust","tungsten_dust","coal_plate"}
}



function api.calc(item)
  if type(costDb[item]) == "table" then
    --print(type(costDb[item]))
    local c = 0
    for k,v in ipairs(costDb[item]) do
      --print(c)
      c = c+api.calc(costDb[item][k])
      --print(c)
    end
    
    return c
  end
  if type(costDb[item] ~= "nil") then return costDb[item] else return 0 end

end
--print("cc: "..api.calc("t1_transformer_pole"))

return api
