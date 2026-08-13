package.path = package.path
  .. ';/plugin/test/?.lua'
  .. ';/plugin/lua/?.lua'
  .. ';/plugin/lua/?/init.lua'
  .. ';/opt/sqlite.lua/lua/?.lua'
  .. ';/opt/sqlite.lua/lua/?/init.lua'

local ok = require('test_integration_db').run()

if ok then
  vim.cmd('qa!')
else
  vim.cmd('cquit')
end
