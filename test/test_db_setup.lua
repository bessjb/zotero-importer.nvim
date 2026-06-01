-- Test database setup helper
-- Creates a minimal SQLite database with Zotero schema for integration testing
-- This uses shell commands to create an actual SQLite database file

local M = {}

local function exec_sql(db_path, sql)
  -- Execute SQL using sqlite3 command line
  local cmd = string.format("sqlite3 '%s' \"%s\"", db_path, sql:gsub('"', '\\"'))
  return os.execute(cmd)
end

local function create_schema(db_path)
  -- Create tables matching Zotero database schema (minimal version)
  
  -- Items table
  exec_sql(db_path, [[
    CREATE TABLE IF NOT EXISTS items (
      itemID INTEGER PRIMARY KEY,
      itemTypeID INTEGER NOT NULL,
      dateAdded TEXT NOT NULL,
      dateModified TEXT NOT NULL,
      key TEXT NOT NULL UNIQUE
    );
  ]])
  
  -- Item types
  exec_sql(db_path, [[
    CREATE TABLE IF NOT EXISTS itemTypes (
      itemTypeID INTEGER PRIMARY KEY,
      typeName TEXT NOT NULL UNIQUE
    );
  ]])
  
  -- Fields table
  exec_sql(db_path, [[
    CREATE TABLE IF NOT EXISTS fields (
      fieldID INTEGER PRIMARY KEY,
      fieldName TEXT NOT NULL UNIQUE
    );
  ]])
  
  -- Item data values
  exec_sql(db_path, [[
    CREATE TABLE IF NOT EXISTS itemDataValues (
      valueID INTEGER PRIMARY KEY,
      value TEXT NOT NULL UNIQUE
    );
  ]])
  
  -- Item data mapping
  exec_sql(db_path, [[
    CREATE TABLE IF NOT EXISTS itemData (
      itemDataID INTEGER PRIMARY KEY,
      itemID INTEGER NOT NULL,
      fieldID INTEGER NOT NULL,
      valueID INTEGER NOT NULL,
      UNIQUE(itemID, fieldID)
    );
  ]])
  
  -- Creators table
  exec_sql(db_path, [[
    CREATE TABLE IF NOT EXISTS creators (
      creatorID INTEGER PRIMARY KEY,
      firstName TEXT,
      lastName TEXT,
      fieldMode INTEGER
    );
  ]])
  
  -- Creator types
  exec_sql(db_path, [[
    CREATE TABLE IF NOT EXISTS creatorTypes (
      creatorTypeID INTEGER PRIMARY KEY,
      creatorType TEXT NOT NULL UNIQUE
    );
  ]])
  
  -- Item creators mapping
  exec_sql(db_path, [[
    CREATE TABLE IF NOT EXISTS itemCreators (
      itemCreatorID INTEGER PRIMARY KEY,
      itemID INTEGER NOT NULL,
      creatorID INTEGER NOT NULL,
      creatorTypeID INTEGER NOT NULL,
      orderIndex INTEGER NOT NULL
    );
  ]])
  
  -- Item attachments
  exec_sql(db_path, [[
    CREATE TABLE IF NOT EXISTS itemAttachments (
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
  ]])
  
  -- Citation keys (from Better BibTeX)
  exec_sql(db_path, [[
    CREATE TABLE IF NOT EXISTS citationkey (
      itemID INTEGER PRIMARY KEY,
      citationKey TEXT NOT NULL UNIQUE
    );
  ]])
end

local function insert_test_data(db_path)
  -- Insert item types
  exec_sql(db_path, "INSERT INTO itemTypes (itemTypeID, typeName) VALUES (1, 'journalArticle');")
  exec_sql(db_path, "INSERT INTO itemTypes (itemTypeID, typeName) VALUES (2, 'book');")
  
  -- Insert field types
  exec_sql(db_path, "INSERT INTO fields (fieldID, fieldName) VALUES (1, 'title');")
  exec_sql(db_path, "INSERT INTO fields (fieldID, fieldName) VALUES (2, 'author');")
  exec_sql(db_path, "INSERT INTO fields (fieldID, fieldName) VALUES (3, 'year');")
  exec_sql(db_path, "INSERT INTO fields (fieldID, fieldName) VALUES (4, 'journal');")
  exec_sql(db_path, "INSERT INTO fields (fieldID, fieldName) VALUES (5, 'DOI');")
  exec_sql(db_path, "INSERT INTO fields (fieldID, fieldName) VALUES (6, 'date');")
  exec_sql(db_path, "INSERT INTO fields (fieldID, fieldName) VALUES (7, 'publisher');")
  
  -- Insert creator types
  exec_sql(db_path, "INSERT INTO creatorTypes (creatorTypeID, creatorType) VALUES (1, 'author');")
  exec_sql(db_path, "INSERT INTO creatorTypes (creatorTypeID, creatorType) VALUES (2, 'contributor');")
  
  -- Insert first test item (journal article)
  exec_sql(db_path, "INSERT INTO items (itemID, itemTypeID, dateAdded, dateModified, key) VALUES (1, 1, '2024-01-01', '2024-01-01', 'ITEM1K');")
  
  -- Insert data values for first item
  exec_sql(db_path, "INSERT INTO itemDataValues (valueID, value) VALUES (1, 'A Novel Framework for Research');")
  exec_sql(db_path, "INSERT INTO itemDataValues (valueID, value) VALUES (2, 'Journal of Testing');")
  exec_sql(db_path, "INSERT INTO itemDataValues (valueID, value) VALUES (3, '2024');")
  exec_sql(db_path, "INSERT INTO itemDataValues (valueID, value) VALUES (4, '10.1234/test.2024');")
  
  -- Link item 1 to data values
  exec_sql(db_path, "INSERT INTO itemData (itemID, fieldID, valueID) VALUES (1, 1, 1);")  -- title
  exec_sql(db_path, "INSERT INTO itemData (itemID, fieldID, valueID) VALUES (1, 4, 2);")  -- journal
  exec_sql(db_path, "INSERT INTO itemData (itemID, fieldID, valueID) VALUES (1, 3, 3);")  -- year
  exec_sql(db_path, "INSERT INTO itemData (itemID, fieldID, valueID) VALUES (1, 5, 4);")  -- DOI
  
  -- Insert creator for first item
  exec_sql(db_path, "INSERT INTO creators (creatorID, firstName, lastName, fieldMode) VALUES (1, 'John', 'Smith', 0);")
  exec_sql(db_path, "INSERT INTO itemCreators (itemID, creatorID, creatorTypeID, orderIndex) VALUES (1, 1, 1, 0);")
  
  -- Insert citation key for first item
  exec_sql(db_path, "INSERT INTO citationkey (itemID, citationKey) VALUES (1, 'Smith2024');")
  
  -- Insert second test item (book)
  exec_sql(db_path, "INSERT INTO items (itemID, itemTypeID, dateAdded, dateModified, key) VALUES (2, 2, '2024-01-02', '2024-01-02', 'ITEM2K');")
  
  -- Insert data values for second item
  exec_sql(db_path, "INSERT INTO itemDataValues (valueID, value) VALUES (5, 'Advanced Topics in Software');")
  exec_sql(db_path, "INSERT INTO itemDataValues (valueID, value) VALUES (6, 'Tech Publishers Inc');")
  exec_sql(db_path, "INSERT INTO itemDataValues (valueID, value) VALUES (7, '2023');")
  
  -- Link item 2 to data values
  exec_sql(db_path, "INSERT INTO itemData (itemID, fieldID, valueID) VALUES (2, 1, 5);")  -- title
  exec_sql(db_path, "INSERT INTO itemData (itemID, fieldID, valueID) VALUES (2, 7, 6);")  -- publisher
  exec_sql(db_path, "INSERT INTO itemData (itemID, fieldID, valueID) VALUES (2, 3, 7);")  -- year
  
  -- Insert creators for second item
  exec_sql(db_path, "INSERT INTO creators (creatorID, firstName, lastName, fieldMode) VALUES (2, 'Jane', 'Doe', 0);")
  exec_sql(db_path, "INSERT INTO creators (creatorID, firstName, lastName, fieldMode) VALUES (3, 'Bob', 'Johnson', 0);")
  exec_sql(db_path, "INSERT INTO itemCreators (itemID, creatorID, creatorTypeID, orderIndex) VALUES (2, 2, 1, 0);")
  exec_sql(db_path, "INSERT INTO itemCreators (itemID, creatorID, creatorTypeID, orderIndex) VALUES (2, 3, 1, 1);")
  
  -- Insert citation key for second item
  exec_sql(db_path, "INSERT INTO citationkey (itemID, citationKey) VALUES (2, 'Doe2023');")
end

function M.setup_test_db(db_path)
  -- Remove old test database if it exists
  os.remove(db_path)
  
  create_schema(db_path)
  insert_test_data(db_path)
  
  return true
end

function M.cleanup_test_db(db_path)
  os.remove(db_path)
end

return M
