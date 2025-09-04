local zotero_importer = require 'zotero-importer'

return require('telescope').register_extension {
  exports = {
    zotero = zotero_importer.picker,
  },
}
