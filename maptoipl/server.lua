--[[
    Author: Nando (https://github.com/Fernando-A-Rocha)

    Converts MTA Map format to GTA:SA IPL format, compatible with newmodels
]]

-- CONFIG
local NEWMODELS_CUSTOM_OBJECT_DATA = "objectID" -- Custom object ID data name

local function outputMsg(msg, executor)
    msg = "[Map to IPL] "..msg
    outputServerLog(msg)
    if isElement(executor) and getElementType(executor) == "player" then
        outputChatBox(msg, executor)
    end
end

-- Euler angles to quaternion
-- posted by thisdp in https://forum.multitheftauto.com/topic/98228-func-euler-angles-into-quaternions/
local function mathSign(x, a)
	return (a < 0) and -math.abs(x) or math.abs(x)
end
local function quaternion(x, y, z)
	local rx = math.rad( -x )
	local ry = math.rad( -y )
	local rz = math.rad( z )
	local fCosX = math.cos(rx)
	local fCosY = math.cos(ry)
	local fCosZ = math.cos(rz)
	local fSinX = math.sin(rx)
	local fSinY = math.sin(ry)
	local fSinZ = math.sin(rz)
	local temp1 = fCosY * fCosZ
	local temp2 = fSinX * fSinY * fSinZ + fCosX * fCosZ
	local temp3 = fCosX * fCosY
	local w = math.sqrt(math.max(0.0, 1.0 + temp1 + temp2 + temp3)) * 0.5
	local x = math.sqrt(math.max(0.0, 1.0 + temp1 - temp2 - temp3)) * 0.5
	local y = math.sqrt(math.max(0.0, 1.0 - temp1 + temp2 - temp3)) * 0.5
	local z = math.sqrt(math.max(0.0, 1.0 - temp1 - temp2 + temp3)) * 0.5
	x = mathSign(x, (fCosZ * fSinX - fCosX * fSinY * fSinZ) - (-fSinX * fCosY))
	y = mathSign(y, fSinY + (fCosX * fSinY * fCosZ + fSinX * fSinZ))
	z = mathSign(z, (fSinX * fSinY * fCosZ - fCosX * fSinZ) - (fCosY * fSinZ))
	return {x, y, z, w}
end

addCommandHandler("maptoipl", function(executor, cmd, mapName)
    if not mapName then
        outputMsg("Syntax: /"..cmd.." <map name (no spaces, it should match map resource name)>", executor)
        return
    end
    local mapFile = ":"..mapName.."/"..mapName..".map"
    if not fileExists(mapFile) then
        outputMsg("Map file '"..mapFile.."' not found", executor)
        return
    end
    local map = xmlLoadFile(mapFile, true) -- Read only
    if not map then
        outputMsg("Failed to open map file '"..mapFile.."'", executor)
        return
    end
    local content = {}
    for index, node in ipairs(xmlNodeGetChildren(map)) do
        local nodeName = xmlNodeGetName(node)
        if nodeName == "object" then
            local posX = tonumber(xmlNodeGetAttribute(node, "posX"))
            local posY = tonumber(xmlNodeGetAttribute(node, "posY"))
            local posZ = tonumber(xmlNodeGetAttribute(node, "posZ"))
            local rotX = tonumber(xmlNodeGetAttribute(node, "rotX")) or 0
            local rotY = tonumber(xmlNodeGetAttribute(node, "rotY")) or 0
            local rotZ = tonumber(xmlNodeGetAttribute(node, "rotZ")) or 0
            local interior = tonumber(xmlNodeGetAttribute(node, "interior")) or 0
            -- Newmodels
            local customModel = xmlNodeGetAttribute(node, NEWMODELS_CUSTOM_OBJECT_DATA) or nil
            local model = customModel or tonumber(xmlNodeGetAttribute(node, "model"))

            if not (posX and posY and posZ and model) then
                outputMsg("WARNING: Invalid object #"..index.." in map file '"..mapFile.."'", executor)
            else
                content[#content+1] = {
                    model = model,
                    interior = interior,
                    posX = posX,
                    posY = posY,
                    posZ = posZ,
                    rotX = rotX,
                    rotY = rotY,
                    rotZ = rotZ,
                }
            end
        end
    end    
    xmlUnloadFile(map)
    if #content == 0 then
        outputMsg("No objects found in map file '"..mapFile.."'", executor)
        return
    end

    local nowTime = getRealTime()
    local iplContent = "# IPL generated by MTA:SA "..getResourceName(resource)
    iplContent = iplContent .. " on "..string.format("%04d-%02d-%02d %02d:%02d:%02d", nowTime.year+1900, nowTime.month+1, nowTime.monthday, nowTime.hour, nowTime.minute, nowTime.second)
    iplContent = iplContent.." from "..mapName..".map\n"
    
    iplContent = iplContent.."inst\n"
    for _, v in ipairs(content) do
        iplContent = iplContent..string.format("%d, dummy, %d, %f, %f, %f, %f, %f, %f, %f, -1\n", v.model, v.interior, v.posX, v.posY, v.posZ, unpack(quaternion(v.rotX, v.rotY, v.rotZ)))
    end
    iplContent = iplContent.."end\n"

    local iplFile = ":"..mapName.."/"..mapName..".ipl"
    local file = fileCreate(iplFile)
    if not file then
        outputMsg("Failed to create IPL file '"..iplFile.."'", executor)
        return
    end
    fileWrite(file, iplContent)
    fileClose(file)
    outputMsg("IPL file '"..iplFile.."' created", executor)

end, false, false)
