-- Integration tests for database module
-- Run this in Neovim with: :lua require('test.test_integration_db').run()

local M = {}

local test_db_path = '/tmp/test_zotero_integration.sqlite'

local function exec_sql(db_path, sql)
  local cmd = string.format("sqlite3 '%s' \"%s\" 2>/dev/null", db_path, sql:gsub('"', '\\"'))
  return os.execute(cmd) == 0
end

local function setup_test_db()
  -- Remove old database
  os.remove(test_db_path)
  
  -- Create schema
  local schema_sql = [[
    CREATE TABLE items (
      itemID INTEGER PRIMARY KEY,
      itemTypeID INTEGER NOT NULL,
      dateAdded TEXT NOT NULL,
      dateModified TEXT NOT NULL,
      key TEXT NOT NULL UNIQUE
    );
    CREATE TABLE itemTypes (
      itemTypeID INTEGER PRIMARY KEY,
      typeName TEXT NOT NULL UNIQUE
    );
    CREATE TABLE fields (
      fieldID INTEGER PRIMARY KEY,
      fieldName TEXT NOT NULL UNIQUE
    );
    CREATE TABLE itemDataValues (
      valueID INTEGER PRIMARY KEY,
      value TEXT NOT NULL UNIQUE
    );
    CREATE TABLE itemData (
      itemDataID INTEGER PRIMARY KEY,
      itemID INTEGER NOT NULL,
      fieldID INTEGER NOT NULL,
      valueID INTEGER NOT NULL,
      UNIQUE(itemID, fieldID)
    );
    CREATE TABLE creators (
      creatorID INTEGER PRIMARY KEY,
      firstName TEXT,
      lastName TEXT,
      fieldMode INTEGER
    );
    CREATE TABLE creatorTypes (
      creatorTypeID INTEGER PRIMARY KEY,
      creatorType TEXT NOT NULL UNIQUE
    );
    CREATE TABLE itemCreators (
      itemCreatorID INTEGER PRIMARY KEY,
      itemID INTEGER NOT NULL,
      creatorID INTEGER NOT NULL,
      creatorTypeID INTEGER NOT NULL,
      orderIndex INTEGER NOT NULL
    );
    CREATE TABLE itemAttachments (
      itemAttachmentID INTEGER PRIMARY KEY,
      parentItemID INTEGER,
      itemID INTEGER NOT NULL,
      attachmentType TEXT,
      path TEXT,
      title TEXT,
      contentType TEXT,
      charset TEXT,
      linkMode INTEGER
    );
    CREATE TABLE citationkey (
      itemID INTEGER PRIMARY KEY,
      citationKey TEXT NOT NULL UNIQUE
    );
  ]]
  
  exec_sql(test_db_path, schema_sql)
  
  -- Insert test data
  local test_data = {
    "INSERT INTO itemTypes (itemTypeID, typeName) VALUES (1, 'journalArticle');",
    "INSERT INTO itemTypes (itemTypeID, typeName) VALUES (2, 'book');",
    "INSERT INTO fields (fieldID, fieldName) VALUES (1, 'title');",
    "INSERT INTO fields (fieldID, fieldName) VALUES (2, 'author');",
    "INSERT INTO fields (fieldID, fieldName) VALUES (3, 'year');",
    "INSERT INTO fields (fieldID, fieldName) VALUES (4, 'journal');",
    "INSERT INTO fields (fieldID, fieldName) VALUES (5, 'DOI');",
    "INSERT INTO creatorTypes (creatorTypeID, creatorType) VALUES (1, 'author');",
    "INSERT INTO items (itemID, itemTypeID, dateAdded, dateModified, key) VALUES (1, 1, '2024-01-01', '2024-01-01', 'ITEM1K');",
    "INSERT INTO itemDataValues (valueID, value) VALUES (1, 'A Novel Framework for Research');",
    "INSERT INTO itemDataValues (valueID, value) VALUES (2, 'Journal of Testing');",
    "INSERT INTO itemDataValues (valueID, value) VALUES (3, '2024');",
    "INSERT INTO itemDataValues (valueID, value) VALUES (4, '10.1234/test.2024');",
    "INSERT INTO itemData (itemID, fieldID, valueID) VALUES (1, 1, 1);",
    "INSERT INTO itemData (itemID, fieldID, valueID) VALUES (1, 4, 2);",
    "INSERT INTO itemData (itemID, fieldID, valueID) VALUES (1, 3, 3);",
    "INSERT INTO itemData (itemID, fieldID, valueID) VALUES (1, 5, 4);",
    "INSERT INTO creators (creatorID, firstName, lastName, fieldMode) VALUES (1, 'John', 'Smith', 0);",
    "INSERT INTO itemCreators (itemID, creatorID, creatorTypeID, orderIndex) VALUES (1, 1, 1, 0);",
    "INSERT INTO citationkey (itemID, citationKey) VALUES (1, 'Smith2024');",
  }
  
  for _, sql in ipairs(test_data) do
    exec_sql(test_db_path, sql)
  end
end

local function cleanup_test_db()
  os.remove(test_db_path)
end

function M.test_database_connection()
  setup_test_db()
  
  local database = require('zotero-importer.database')
  local success = database.connect({
    zotero_db_path = test_db_path,
    better_bibtex_db_path = '',
    zotero_storage_path = '/tmp/zotero_storage'
  })
  
  if success then
    vim.notify('✓ Database connection test passed', vim.log.levels.INFO)
  else
    vim.notify('✗ Database connection test failed', vim.log.levels.ERROR)
  end
  
  cleanup_test_db()
  return success
end

function M.test_get_items()
  setup_test_db()
  
  local database = require('zotero-importer.database')
  database.connect({
    zotero_db_path = test_db_path,
    better_bibtex_db_path = '',
    zotero_storage_path = '/tmp/zotero_storage'
  })
  
  local items = database.get_items()
  local success = items and #items > 0
  
  if success then
    vim.notify('✓ Get items test passed (found ' .. #items .. ' items)', vim.log.levels.INFO)
  else
    vim.notify('✗ Get items test failed', vim.log.levels.ERROR)
  end
  
  cleanup_test_db()
  return success
end

function M.run()
  vim.notify('Running integration tests...', vim.log.levels.INFO)
  local results = {}
  
  table.insert(results, M.test_database_connection())
  table.insert(results, M.test_get_items())
  
  local passed = 0
  for _, result in ipairs(results) do
    if result then passed = passed + 1 end
  end
  
  vim.notify(string.format('Integration tests: %d/%d passed', passed, #results), vim.log.levels.INFO)
  return passed == #results
end

return M
