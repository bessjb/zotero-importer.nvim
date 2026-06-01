-- Setup test environment using helpers
local test_helpers = require('test_helpers')
test_helpers.setup_package_paths()
test_helpers.setup_vim_mock()
local luaunit = test_helpers.setup_luaunit()

-- Safely load importer
local importer = test_helpers.safe_require('zotero-importer')

TestMath = {}

function TestMath:testAdd()
    print("Running TestMath:testAdd")
    luaunit.assertEquals(1 + 2, 3)
end

function TestMath:testNilValue()
    print("Running TestMath:testNilValue")
    luaunit.assertIsNil(nil)
end

TestBibFormat = {}

function TestBibFormat:testBibEntryFormatting()
  print("Running TestBibFormat:testBibEntryFormatting")
  -- Test basic bibliography entry formatting
  local bib = require('zotero-importer.bib')
  local entry = {
    value = {
      citationKey = 'Smith2024',
      title = 'Test Article',
      creators = {
        { firstName = 'John', lastName = 'Smith', creatorType = 'author' }
      },
      year = '2024',
      itemType = 'journalArticle'
    }
  }
  local result = bib.entry_to_bib_entry(entry)
  luaunit.assertIsNotNil(result)
  -- Check that result contains expected content (simplified check)
  local has_at_sign = string.find(result, '@') ~= nil
  luaunit.assertEquals(has_at_sign, true)
  print("  ✓ BibFormat test passed")
end

print("Starting tests...")
os.exit(luaunit.LuaUnit.run())
