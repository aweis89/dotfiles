-- Placeholder for EmmyLua Spoon (PR #240)
-- Replace this file with the PR's Source/EmmyLua.spoon/init.lua contents.

local obj = {}
obj.__index = obj
obj.name = 'EmmyLua'
obj.version = '0.0.0-placeholder'

function obj:init()
  -- This placeholder does not generate annotations.
  -- After replacing with the real Spoon, annotations will be written under:
  --   ~/.hammerspoon/Spoons/EmmyLua.spoon/annotations
  hs.printf('[EmmyLua placeholder] Replace Source/EmmyLua.spoon/init.lua with PR code.')
end

return obj

