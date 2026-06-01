-- Integration tests for database module
-- Run this in Neovim with: :lua require('test.test_integration_db').run()

local M = {}
local integration_helpers = require('integration_test_helpers')

local test_db_path = integration_helpers.get_test_db_path()

function M.test_database_connection()
  integration_helpers.setup_test_db(test_db_path)
  
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
  
  integration_helpers.cleanup_test_db(test_db_path)
  return success
end

function M.test_get_items()
  integration_helpers.setup_test_db(test_db_path)
  
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
  
  integration_helpers.cleanup_test_db(test_db_path)
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
