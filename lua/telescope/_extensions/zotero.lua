local ok, zotero_importer = pcall(require, 'zotero-importer')
if not ok then
  error('zotero-importer plugin is not installed or not properly configured')
end

return require('telescope').register_extension {
  exports = {
    zotero = function(opts)
      return zotero_importer.picker(opts)
    end,
  },
}
