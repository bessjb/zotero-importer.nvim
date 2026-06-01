-- Integration test helper utilities for database testing

local M = {}

local test_db_path = '/tmp/test_zotero_integration.sqlite'

-- Execute SQL against the test database
local function exec_sql(db_path, sql)
  local cmd = string.format("sqlite3 '%s' \"%s\" 2>/dev/null", db_path, sql:gsub('"', '\\"'))
  return os.execute(cmd) == 0
end

-- Create test database schema
local function create_schema(db_path)
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
  
  exec_sql(db_path, schema_sql)
end

-- Insert test data into database
local function insert_test_data(db_path)
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
    exec_sql(db_path, sql)
  end
end

-- Setup test database with schema and data
function M.setup_test_db(db_path)
  db_path = db_path or test_db_path
  
  -- Remove old database
  os.remove(db_path)
  
  create_schema(db_path)
  insert_test_data(db_path)
end

-- Clean up test database
function M.cleanup_test_db(db_path)
  db_path = db_path or test_db_path
  os.remove(db_path)
end

-- Get default test database path
function M.get_test_db_path()
  return test_db_path
end

return M
