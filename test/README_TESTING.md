# Testing Guide

This document describes the test setup for zotero-importer.nvim.

## Overview

The test suite is split into two parts:

1. **Unit Tests** - Run in standalone Lua environment
2. **Integration Tests** - Run in Neovim context with SQLite database

## Unit Tests

Unit tests verify the core logic without external dependencies.

### Running Unit Tests

```bash
cd test
lua test_zotero.lua
```

### Test File Structure

- `test/test_zotero.lua` - Main test file with unit tests
- `lua/zotero-importer/bib.lua` - Module being tested (bibliography formatting)

### Current Tests

- `TestMath::testAdd` - Basic sanity check
- `TestMath::testNilValue` - Nil value assertion
- `TestBibFormat::testBibEntryFormatting` - Bibliography entry formatting

### Adding New Unit Tests

Add new test classes to `test_zotero.lua`:

```lua
TestMyFeature = {}

function TestMyFeature:testSomething()
  -- Your test logic
  luaunit.assertEquals(actual, expected)
end
```

## Integration Tests

Integration tests verify database connectivity and data retrieval using a minimal SQLite database.

### Running Integration Tests

Inside Neovim:

```vim
:lua require('test.test_integration_db').run()
```

### Test Database

The integration tests create a temporary SQLite database at `/tmp/test_zotero_integration.sqlite`.

**Schema**:
- `items` - Bibliography item metadata
- `itemTypes` - Item type definitions (journalArticle, book, etc.)
- `fields` - Field names (title, author, year, DOI, etc.)
- `itemDataValues` - Field values
- `itemData` - Mapping between items and field values
- `creators` - Author/contributor names
- `creatorTypes` - Types of creators (author, contributor, etc.)
- `itemCreators` - Mapping between items and creators
- `itemAttachments` - PDF attachments and metadata
- `citationkey` - BibTeX citation keys (from Better BibTeX)

**Test Data**:
1. Journal Article (ITEM1K)
   - Title: "A Novel Framework for Research"
   - Author: John Smith
   - Year: 2024
   - Citation Key: Smith2024
   - DOI: 10.1234/test.2024
   - Journal: Journal of Testing

2. Book (ITEM2K)
   - Title: "Advanced Topics in Software"
   - Authors: Jane Doe, Bob Johnson
   - Year: 2023
   - Citation Key: Doe2023
   - Publisher: Tech Publishers Inc

### Current Integration Tests

- `test_database_connection()` - Verify database connection works
- `test_get_items()` - Verify items can be retrieved from database

### Adding New Integration Tests

Add test functions to `test/test_integration_db.lua`:

```lua
function M.test_your_feature()
  setup_test_db()
  
  -- Your test logic
  local success = database.connect({...})
  
  if success then
    vim.notify('✓ Your test passed', vim.log.levels.INFO)
  else
    vim.notify('✗ Your test failed', vim.log.levels.ERROR)
  end
  
  cleanup_test_db()
  return success
end

-- Then add to M.run():
table.insert(results, M.test_your_feature())
```

## Test Database Setup

### Helper Module

`test/test_db_setup.lua` provides utilities for test database creation:

```lua
local db_setup = require('test_db_setup')

-- Create test database
db_setup.setup_test_db('/path/to/test.sqlite')

-- Clean up
db_setup.cleanup_test_db('/path/to/test.sqlite')
```

### Manual Database Creation

To manually create a test database:

```bash
sqlite3 /tmp/test_manual.sqlite < schema.sql
```

Then insert test data as needed.

## Test Framework

### Unit Tests

Uses a minimal luaunit fallback with the following assertions:

- `luaunit.assertEquals(actual, expected)` - Assert equality
- `luaunit.assertIsNil(value)` - Assert nil
- `luaunit.assertIsNotNil(value)` - Assert non-nil

### Integration Tests

Uses vim.notify() for output and standard Lua assertions.

## Troubleshooting

### Unit Tests Not Running

If tests don't output results, check:
1. Lua version is 5.1+
2. No module loading errors in the output
3. Test class names start with "Test"
4. Test method names start with "test"

### Integration Tests Not Running

If integration tests fail in Neovim, check:
1. sqlite3 command-line tool is installed: `which sqlite3`
2. sqlite.lua plugin is installed: `:echo exists(':SQLiteOpen')`
3. Database file permissions allow creation in `/tmp`

### Database File Not Cleaning Up

If test database files persist in `/tmp`, manually clean them:

```bash
rm /tmp/test_zotero*.sqlite
```

## CI/CD Integration

The Docker workflow is exposed through the Makefile:

```bash
make build
make unit
make integration
make test
make demo-db
make nvim
```

`make nvim` creates `.tmp/test_zotero_demo.sqlite` and opens the sample
LaTeX document in an interactive Neovim container. The generated `.tmp`
directory is ignored by Git.

To run tests in CI/CD pipelines:

```bash
# Unit tests
cd test && lua test_zotero.lua

# Exit code will be 0 if all tests pass, 1 if any fail
```

Integration tests currently require a Neovim environment and cannot be easily automated.
