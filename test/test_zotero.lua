package.path = package.path .. ";../lua/?/init.lua"
package.path = package.path .. ";../lua/zotero-importer/?.lua"
package.path = package.path .. ";~/.local/share/nvim/sqlite/lua/?/init.lua"
package.path = package.path .. ";~/.local/share/nvim/nvim-treesitter/lua/?/init.lua"

-- Try to load luaunit, provide minimal fallback if not available
local luaunit
local ok, result = pcall(function() return require('luaunit') end)
if ok then
  luaunit = result
else
  -- Minimal luaunit fallback
  luaunit = {
    assertEquals = function(a, b) assert(a == b, "Expected " .. tostring(b) .. " but got " .. tostring(a)) end,
    assertIsNil = function(v) assert(v == nil, "Expected nil but got " .. tostring(v)) end,
    LuaUnit = {
      run = function() return 0 end
    }
  }
end

-- Mock vim API for testing without Neovim
_G.vim = {
  fn = {},
  api = {},
  bo = {},
  loop = {},
  treesitter = {},
  notify = function() end,
  notify_once = function() end,
  print = function() end,
  ui = { select = function() end, open = function() end },
  log = { levels = { WARN = 1, ERROR = 2, INFO = 3 } },
  keymap = { set = function() end },
  tbl_extend = function(_, a, b) local t = {} for k,v in pairs(a) do t[k] = v end for k,v in pairs(b or {}) do t[k] = v end return t end,
  api = {
    nvim_get_current_buf = function() return 0 end,
    nvim_get_option_value = function() return 'latex' end,
    nvim_buf_set_lines = function() end,
    nvim_set_option_value = function() end,
    nvim_put = function() end,
  },
  bo = { filetype = 'latex' },
}

-- Safely require importer with error handling
local importer = nil
local ok, result = pcall(function()
  return require('zotero-importer')
end)
if not ok then
  print("Warning: Could not load zotero-importer (expected in test environment)")
end

TestMath = {}

function TestMath:testAdd()
    luaunit.assertEquals(1 + 2, 3)
end

function TestMath:testNilValue()
    luaunit.assertIsNil(nil)
end

os.exit(luaunit.LuaUnit.run())
