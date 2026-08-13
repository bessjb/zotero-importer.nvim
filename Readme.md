WIP plugin for adding all references in a tex document to a bibliography

Extending functionality from https://github.com/jmbuhr/telescope-zotero.nvim

## Testing

### Docker

Docker runs both the standalone Lua tests and the headless Neovim/SQLite
integration tests:

```bash
make test
```

To create the demo database and open the plugin in an interactive Neovim
session:

```bash
make nvim
```

The repository is copied into a temporary workspace for the interactive
session, so edits to the sample text and demo database are discarded when
Neovim exits. Local plugin changes are still available without rebuilding the
image. Use `make shell` to open a shell in the test container.

### Unit Tests

Run unit tests with basic Lua:

```bash
cd test
lua test_zotero.lua
```

This runs tests for utility functions like bibliography formatting. Tests use a minimal fallback test runner when luaunit is not available.

### Integration Tests

Integration tests verify the database connectivity and data retrieval. Run these in Neovim:

```vim
:lua require('test.test_integration_db').run()
```

#### Test Database

Integration tests use a minimal SQLite database created at `/tmp/test_zotero_integration.sqlite`. The database includes:

- **tables**: items, itemTypes, fields, itemDataValues, itemData, creators, creatorTypes, itemCreators, itemAttachments, citationkey
- **test data**: 2 sample bibliography items (1 journal article, 1 book) with creators and metadata

The test database is automatically created and destroyed for each test run. No external Zotero installation is required.
