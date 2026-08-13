-- Test helper utilities for zotero-importer tests

local M = {}

-- Setup package paths for loading modules
function M.setup_package_paths()
  local home = os.getenv("HOME")
  package.path = package.path .. ";../lua/?/init.lua;../lua/?.lua"
  package.path = package.path .. ";../lua/zotero-importer/?.lua"
  package.path = package.path .. ";./?/init.lua;./?.lua"
  package.path = package.path .. ";" .. home .. "/.local/share/nvim/lazy/sqlite.lua/lua/?/init.lua;" .. home .. "/.local/share/nvim/lazy/sqlite.lua/lua/?.lua"
  package.path = package.path .. ";" .. home .. "/.local/share/nvim/nvim-treesitter/lua/?/init.lua"
end

-- Mock vim API for testing without Neovim
function M.setup_vim_mock()
  _G.vim = {
    fn = {},
    api = {},
    bo = {},
    loop = {},
    treesitter = {},
    notify = function() end,
    notify_once = function() end,
    print = function() end,
    ui = { select = function() end, open = function() end },
    log = { levels = { WARN = 1, ERROR = 2, INFO = 3 } },
    keymap = { set = function() end },
    tbl_extend = function(_, a, b) 
      local t = {} 
      for k,v in pairs(a) do t[k] = v end 
      for k,v in pairs(b or {}) do t[k] = v end 
      return t 
    end,
    api = {
      nvim_get_current_buf = function() return 0 end,
      nvim_get_option_value = function() return 'latex' end,
      nvim_buf_set_lines = function() end,
      nvim_set_option_value = function() end,
      nvim_put = function() end,
    },
    bo = { filetype = 'latex' },
  }
end

-- Load or create luaunit
function M.setup_luaunit()
  local luaunit
  local ok, result = pcall(function() return require('luaunit') end)
  
  if ok then
    return result
  end
  
  -- Create minimal luaunit fallback with basic test runner
  local test_failures = {}
  
  luaunit = {
    assertEquals = function(a, b, msg) 
      if a ~= b then 
        local err = "Expected " .. tostring(b) .. " but got " .. tostring(a)
        if msg then err = err .. " - " .. msg end
        table.insert(test_failures, err)
        error(err)
      end 
    end,
    assertIsNil = function(v, msg) 
      if v ~= nil then 
        local err = "Expected nil but got " .. tostring(v)
        if msg then err = err .. " - " .. msg end
        table.insert(test_failures, err)
        error(err)
      end 
    end,
    assertIsNotNil = function(v, msg) 
      if v == nil then 
        local err = "Expected non-nil value"
        if msg then err = err .. " - " .. msg end
        table.insert(test_failures, err)
        error(err)
      end 
    end,
    assertNotNil = function(v, msg)
      if v == nil then
        local err = "Expected non-nil value"
        if msg then err = err .. " - " .. msg end
        table.insert(test_failures, err)
        error(err)
      end
    end,
    LuaUnit = {
      run = function()
        local test_classes = {}
        for name, obj in pairs(_G) do
          if string.match(name, '^Test') and type(obj) == 'table' then
            table.insert(test_classes, {name = name, tests = obj})
          end
        end
        
        local total_tests = 0
        local passed_tests = 0
        local failed_tests = {}
        
        for _, test_class in ipairs(test_classes) do
          for method_name, method in pairs(test_class.tests) do
            if string.match(method_name, '^test') and type(method) == 'function' then
              total_tests = total_tests + 1
              local instance = {}
              setmetatable(instance, {__index = test_class.tests})
              
              local ok, err = pcall(method, instance)
              if ok then
                passed_tests = passed_tests + 1
                print("✓ " .. test_class.name .. ":" .. method_name)
              else
                table.insert(failed_tests, {
                  test = test_class.name .. ":" .. method_name,
                  error = err
                })
                print("✗ " .. test_class.name .. ":" .. method_name)
              end
            end
          end
        end
        
        print("\n" .. passed_tests .. "/" .. total_tests .. " tests passed")
        if #failed_tests > 0 then
          print("\nFailed tests:")
          for _, failed in ipairs(failed_tests) do
            print("  - " .. failed.test .. ": " .. failed.error)
          end
          return 1
        end
        return 0
      end
    }
  }
  
  return luaunit
end

-- Safely load a module with error handling
function M.safe_require(module_name)
  local ok, result = pcall(function()
    return require(module_name)
  end)
  
  if ok then
    return result
  else
    print("Warning: Could not load " .. module_name .. " (expected in test environment)")
    return nil
  end
end

return M
