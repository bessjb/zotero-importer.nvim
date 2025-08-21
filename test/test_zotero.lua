package.path = package.path .. ";../lua/?/init.lua"
package.path = package.path .. ";../lua/zotero-importer/?.lua"
package.path = package.path .. ";~/.local/share/nvim/sqlite/lua/?/init.lua"
package.path = package.path .. ";~/.local/share/nvim/nvim-treesitter/lua/?/init.lua"

local luaunit = require('luaunit')
local importer = require('zotero-importer')

TestMath = {}

function TestMath:testAdd()
    luaunit.assertEquals(1 + 2, 3)
end

function TestMath:testNilValue()
    luaunit.assertIsNil(nil)
end

os.exit(luaunit.LuaUnit.run())
