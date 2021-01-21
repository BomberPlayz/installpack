local component = require("component")
local internet = require("internet")
local gpu = component.gpu
local fs = require("filesystem")
local args, options = require("shell").parse(...)
local ser = require("serialization")

local path = "https://raw.githubusercontent.com/BomberPlayz/installpack/main/"

function status(info, text)
  local _msg = text
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
  print(_msg)
end

function getFullData(url)
local data = ""
local i = 0
status("info","getFullData started, url: "..url)
for chunk in internet.request(url) do
	i = i+1
	status("info","Received data chunk "..i)
	data = data..chunk
end
status("info","getFullData ended.")
return data
end

function checkPackagePath(name)
	status("info","Checking package path of package name '"..name.."'")
	local ret,a = ser.unserialize(getFullData(path.."packages.cfg"))
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
	status("info","Getting table data from '"..file.."'")
	local ret,a = ser.unserialize(getFullData(path..file))
	status("warn",a or "no")
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
	status("warn","dumped: "..ser.serialize(patha))
	if patha ~= "err_no" then
		local packageData = getTableData(patha.path.."/package_info.cfg")
		status("warn",ser.serialize(packageData))
		for k,v in pairs(packageData.files) do
			install(path..patha.path.."/"..k,packageData.files[k])
		end
	end
end
