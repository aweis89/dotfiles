-- Wrapper Spoon that delegates to Source/EmmyLua.spoon during development.
-- If the source is present and returns a Spoon object (table), we return it.
-- Otherwise, we return a stub that logs a helpful message.

local function tryLoadSource()
  local sourcePath = hs.configdir .. "/Source/EmmyLua.spoon/init.lua"
  local chunk, loadErr = loadfile(sourcePath)
  if not chunk then
    return nil, loadErr
  end
  local ok, mod = pcall(chunk)
  if not ok then
    return nil, mod
  end
  if type(mod) == "table" then
    return mod, nil
  else
    return nil, "source did not return a Spoon object"
  end
end

local sourceObj, err = tryLoadSource()
if sourceObj then
  return sourceObj
end

local obj = {}
obj.__index = obj
obj.name = "EmmyLua"
obj.version = 'dev-wrapper'

function obj:init()
  hs.printf("EmmyLua source not available: %s", tostring(err))
  hs.printf("Place PR #240 source at ~/.hammerspoon/Source/EmmyLua.spoon/init.lua")
end

return obj

