local database = require 'zotero.database'
local parsers = require("nvim-treesitter.parsers")

local M = {}
M.references = {}

local default_opts = {
  zotero_db_path = '~/Zotero/zotero.sqlite',
  better_bibtex_db_path = '~/Zotero/better-bibtex.sqlite',
  zotero_storage_path = '~/Zotero/storage',
}

local get_items = function()
  local success = database.connect(M.config)
  local ret_database = {}
  if success then
    table.insert(ret_database, database.get_items())
  end
  return ret_database
end

M.get_entry_from_citekey = function(citekey)
  for key, item in pairs(M.references) do
    if item.citekey == citekey then
      print(item.title)
    end
  end
end

M.get_citekeys_in_buffer = function()
  local buffer = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_buf_get_option(buffer, "ft")
  local lang = parsers.ft_to_lang(filetype)
  local reference_keys = {}
  if lang == 'latex' then
    local query = vim.treesitter.query.parse(lang, [[
      ; query
      (citation (curly_group_text_list (text) @citation))
    ]])
    local tree = vim.treesitter.get_parser():parse()[1]
    for id, node, metadata in query:iter_captures(tree:root(), buffer) do
       -- Print the node name and source text.
       table.insert(reference_keys, vim.treesitter.get_node_text(node, buffer))
    end
  end
  return reference_keys
end

M.update_bibliography = function()
  M.references = get_items()
  local citekeys = M.get_citekeys_in_buffer()
  for index, key in ipairs(citekeys) do
    M.get_entry_from_citekey(key)
  end
end

M.setup = function(opts)
   M.config = vim.tbl_extend('force', default_opts, opts or {})

   vim.keymap.set("n", "<Leader>zb", M.update_bibliography, {})
end

return M

