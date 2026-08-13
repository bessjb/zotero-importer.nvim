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

TestBibTypeMapping = {}

function TestBibTypeMapping:testJournalArticleMapping()
  print("Running TestBibTypeMapping:testJournalArticleMapping")
  local bib = require('zotero-importer.bib')
  local entry = {
    value = {
      citationKey = 'Smith2024',
      title = 'Test Article',
      journal = 'Nature',
      creators = {
        { firstName = 'John', lastName = 'Smith', creatorType = 'author' }
      },
      year = '2024',
      itemType = 'journalArticle'
    }
  }
  local result = bib.entry_to_bib_entry(entry)
  -- Zotero's 'journalArticle' should map to BibTeX 'article'
  luaunit.assertNotNil(string.find(result, '@article'), "Expected @article but got: " .. result)
end

function TestBibTypeMapping:testPreprintMapping()
  print("Running TestBibTypeMapping:testPreprintMapping")
  local bib = require('zotero-importer.bib')
  local entry = {
    value = {
      citationKey = 'Preprint2024',
      title = 'Test Preprint',
      creators = {
        { firstName = 'Jane', lastName = 'Doe', creatorType = 'author' }
      },
      year = '2024',
      itemType = 'preprint'
    }
  }
  local result = bib.entry_to_bib_entry(entry)
  -- Zotero's 'preprint' should map to BibTeX 'eprint' or 'misc'
  luaunit.assertNotNil(string.find(result, '@') and (string.find(result, 'eprint') or string.find(result, '@misc')),
    "Expected @eprint or @misc but got: " .. result)
end

function TestBibTypeMapping:testConferencePaperMapping()
  print("Running TestBibTypeMapping:testConferencePaperMapping")
  local bib = require('zotero-importer.bib')
  local entry = {
    value = {
      citationKey = 'Conf2024',
      title = 'Test Conference Paper',
      creators = {
        { firstName = 'Bob', lastName = 'Johnson', creatorType = 'author' }
      },
      year = '2024',
      itemType = 'conferencePaper'
    }
  }
  local result = bib.entry_to_bib_entry(entry)
  -- Zotero's 'conferencePaper' should map to BibTeX 'inproceedings'
  luaunit.assertNotNil(string.find(result, '@inproceedings'), "Expected @inproceedings but got: " .. result)
end

print("Starting tests...")
os.exit(luaunit.LuaUnit.run())
