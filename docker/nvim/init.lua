vim.opt.runtimepath:append('/plugin')
vim.opt.runtimepath:append('/opt/plenary.nvim')
vim.opt.runtimepath:append('/opt/sqlite.lua')
vim.opt.runtimepath:append('/opt/telescope.nvim')
vim.opt.runtimepath:append('/opt/nvim-treesitter')
vim.opt.runtimepath:append('/opt/nvim-lspconfig')

package.path = package.path
  .. ';/plugin/test/?.lua'
  .. ';/plugin/lua/?.lua'
  .. ';/plugin/lua/?/init.lua'

require('zotero-importer').setup({
  zotero_db_path = '/plugin/.tmp/test_zotero_demo.sqlite',
  better_bibtex_db_path = '',
  zotero_storage_path = '/plugin/test/fixtures/storage',
})

vim.keymap.set('n', '<leader>zt', function()
  local ok = require('test.test_integration_db').run()
  vim.notify(ok and 'Integration tests passed' or 'Integration tests failed')
end)
