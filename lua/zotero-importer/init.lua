local database = require 'zotero.database'
local bib = require 'zotero.bib'
local parsers = require("nvim-treesitter.parsers")

local M = {}
M.references = {}

local default_opts = {
  zotero_db_path = '/root/projects/zotero-importer.nvim/test/snippets/zotero.sqlite',
  better_bibtex_db_path = '/root/projects/zotero-importer.nvim/test/snippets/better-bibtex.sqlite',
  zotero_storage_path = '~/Zotero/storage',
  ft = {
    tex = {
      insert_key_formatter = function(citekey)
        return '\\cite{' .. citekey .. '}'
      end,
      locate_bib = "./bib.bib",
    }
  }
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
  local return_entry = {}
  for key, item in pairs(M.references) do
    if item[1].citekey == citekey then
      return_entry["value"] = item[1]
    end
  end
  return return_entry
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

M.insert_entry = function(entry, locate_bib_fn)
  local citekey = entry.value.citekey
  -- Get bib file path
  local bib_path = nil
  if type(locate_bib_fn) == 'string' then
    bib_path = locate_bib_fn
  elseif type(locate_bib_fn) == 'function' then
    bib_path = locate_bib_fn()
  end
  if bib_path == nil then
    vim.notify_once('Could not find a bibliography file', vim.log.levels.WARN)
    return
  end
  bib_path = vim.fn.expand(bib_path)

  -- Check if bib file exists at bib_path
  local ok, lines = pcall(io.lines, bib_path)
  if not ok then
    if vim.fn.confirm("Bibliography file missing. Create '" .. bib_path .. "'?", '&Yes\n&No', 1) == 1 then
      vim.fn.writefile({}, bib_path)
      lines = io.lines(bib_path)
    end
  end

  -- Check if citation has already been placed in bib file at bib_path
  for line in lines do
    if string.match(line, '^@') and string.match(line, citekey) then
      return
    end
  end

  -- Otherwise, append the entry to the bib file at bib_path
  local bib_entry = bib.entry_to_bib_entry(entry)
  local file = io.open(bib_path, 'a')
  if file == nil then
    vim.notify('Could not open ' .. bib_path .. ' for appending', vim.log.levels.ERROR)
    return
  end
  file:write(bib_entry)
  file:close()
  vim.print('wrote ' .. citekey .. ' to ' .. bib_path)
end

M.update_bibliography = function()
  M.references = get_items()
  local citekeys = M.get_citekeys_in_buffer()
  local ft_options = M.config.ft[vim.bo.filetype] or M.config.ft.default

  for index, key in ipairs(citekeys) do
    local entry = M.get_entry_from_citekey(key)
    M.insert_entry(entry, ft_options.locate_bib)
  end
end

M.setup = function(opts)
   M.config = vim.tbl_extend('force', default_opts, opts or {})

   vim.keymap.set("n", "<Leader>zb", M.update_bibliography, {})
end

return M

