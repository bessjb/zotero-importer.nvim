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
