-- ============================================================================
-- NEOVIM CONFIGURATION
-- ============================================================================

-- Leader key setup (must be before plugins load)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- ============================================================================
-- EDITOR OPTIONS
-- ============================================================================

vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10

-- Clipboard sync
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- ============================================================================
-- KEYMAPS
-- ============================================================================

-- Clear search highlights
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostics
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Format on ESC
local function format_on_esc()
  local filetype = vim.bo.filetype
  if filetype == 'cpp' or filetype == 'c' or filetype == 'objc' or filetype == 'objcpp' then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
    vim.schedule(function()
      FormatBuffer()
    end)
    return ''
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
    vim.schedule(function()
      FormatWithConform()
    end)
    return ''
  end
end

vim.keymap.set('i', '<Esc>', format_on_esc, { expr = true, desc = 'Format on exit insert mode' })
vim.keymap.set('v', '<Esc>', format_on_esc, { expr = true, desc = 'Format on exit visual mode' })

vim.keymap.set('n', '<Esc><Esc>', function()
  local filetype = vim.bo.filetype
  if filetype == 'cpp' or filetype == 'c' or filetype == 'objc' or filetype == 'objcpp' then
    vim.schedule(function()
      FormatBuffer()
    end)
    return '<Nop>'
  else
    vim.schedule(function()
      FormatWithConform()
    end)
    return '<Nop>'
  end
end, { expr = true, desc = 'Format in normal mode with double ESC' })

-- ============================================================================
-- AUTOCOMMANDS
-- ============================================================================

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Format on mode change
vim.api.nvim_create_autocmd('ModeChanged', {
  pattern = { 'c:n' },
  callback = function()
    local filetype = vim.bo.filetype
    if filetype == 'cpp' or filetype == 'c' or filetype == 'objc' or filetype == 'objcpp' then
      vim.schedule(function()
        FormatBuffer()
      end)
    else
      vim.schedule(function()
        FormatWithConform()
      end)
    end
  end,
  desc = 'Format on mode change',
})

-- ============================================================================
-- PLUGIN MANAGER (lazy.nvim)
-- ============================================================================

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- PLUGINS
-- ============================================================================

require('lazy').setup({

  -- ══════════════════════════════════════════════════════════════════════════
  -- vim-sleuth: Auto-detect indentation
  -- ══════════════════════════════════════════════════════════════════════════
  'tpope/vim-sleuth',

  -- ══════════════════════════════════════════════════════════════════════════
  -- gitsigns.nvim: Git signs in gutter
  -- No keybinds (visual only)
  -- ══════════════════════════════════════════════════════════════════════════
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  -- ══════════════════════════════════════════════════════════════════════════
  -- lualine.nvim: Status line
  -- No keybinds (visual only)
  -- ══════════════════════════════════════════════════════════════════════════
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = 'auto',
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
        },
      }
    end,
  },

  -- ══════════════════════════════════════════════════════════════════════════
  -- which-key.nvim: Keybind menu helper
  -- Press Space to see available commands
  -- ══════════════════════════════════════════════════════════════════════════
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },
      spec = {
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>f', group = '[F]ind' },
        { '<leader>g', group = '[G]en' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

  -- ══════════════════════════════════════════════════════════════════════════
  -- snacks.nvim: Swiss-army knife plugin (picker, notifier, etc)
  -- Keybinds: <Space>f* (Find commands)
  --   <Space>ff: Find files
  --   <Space>fg: Live grep in workspace
  --   <Space>fb: Find buffers
  --   <Space>fh: Find help tags
  --   <Space>fk: Find keymaps
  --   <Space>fw: Find current word
  --   <Space>fd: Find diagnostics
  --   <Space>fr: Resume last find
  --   <Space>f.: Find recent files
  --   <Space>/: Fuzzy search in current buffer
  --   <Space>f/: Live grep in open files
  --   <Space>fn: Find nvim config files
  -- ══════════════════════════════════════════════════════════════════════════
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      picker = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          header = [[
     ██╗██████╗ ███████╗███╗   ██╗ ██████╗ ██╗
     ██║██╔══██╗██╔════╝████╗  ██║██╔════╝ ██║
     ██║██████╔╝█████╗  ██╔██╗ ██║██║  ███╗██║
██   ██║██╔══██╗██╔══╝  ██║╚██╗██║██║   ██║╚═╝
╚█████╔╝██║  ██║███████╗██║ ╚████║╚██████╔╝██╗
 ╚════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝
          ]],
        },
        sections = {
          { section = 'header' },
          { section = 'keys', gap = 1, padding = 1 },
          { section = 'startup' },
        },
      },
    },
    keys = {
      {
        '<leader>ff',
        function()
          Snacks.picker.files()
        end,
        desc = '[F]ind [F]iles',
      },
      {
        '<leader>fg',
        function()
          Snacks.picker.grep()
        end,
        desc = '[F]ind by [G]rep',
      },
      {
        '<leader>fb',
        function()
          Snacks.picker.buffers()
        end,
        desc = '[F]ind [B]uffers',
      },
      {
        '<leader>fh',
        function()
          Snacks.picker.help()
        end,
        desc = '[F]ind [H]elp tags',
      },
      {
        '<leader>fk',
        function()
          Snacks.picker.keymaps()
        end,
        desc = '[F]ind [K]eymaps',
      },
      {
        '<leader>fw',
        function()
          Snacks.picker.grep_word()
        end,
        desc = '[F]ind current [W]ord',
      },
      {
        '<leader>fd',
        function()
          Snacks.picker.diagnostics()
        end,
        desc = '[F]ind [D]iagnostics',
      },
      {
        '<leader>fr',
        function()
          Snacks.picker.resume()
        end,
        desc = '[F]ind [R]esume',
      },
      {
        '<leader>f.',
        function()
          Snacks.picker.recent()
        end,
        desc = '[F]ind recent files',
      },
      {
        '<leader>/',
        function()
          Snacks.picker.lines()
        end,
        desc = '[/] Search in current buffer',
      },
      {
        '<leader>f/',
        function()
          Snacks.picker.grep_buffers()
        end,
        desc = '[F]ind [/] in open files',
      },
      {
        '<leader>fn',
        function()
          Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
        end,
        desc = '[F]ind [N]eovim files',
      },
    },
  },

  -- ══════════════════════════════════════════════════════════════════════════
  -- nvim-lspconfig: LSP configuration
  -- Dependencies: mason, mason-lspconfig, mason-tool-installer, fidget
  -- Keybinds (LSP-based):
  --   gd: Goto definition
  --   gr: Goto references
  --   gI: Goto implementation
  --   <Space>D: Type definition
  --   <Space>ds: Document symbols
  --   <Space>ws: Workspace symbols
  --   <Space>rn: Rename
  --   <Space>ca: Code action
  --   gD: Goto declaration
  --   <Space>th: Toggle inlay hints
  -- ══════════════════════════════════════════════════════════════════════════
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', function()
            Snacks.picker.lsp_definitions()
          end, '[G]oto [D]efinition')
          map('gr', function()
            Snacks.picker.lsp_references()
          end, '[G]oto [R]eferences')
          map('gI', function()
            Snacks.picker.lsp_implementations()
          end, '[G]oto [I]mplementation')
          map('<leader>D', function()
            Snacks.picker.lsp_type_definitions()
          end, 'Type [D]efinition')
          map('<leader>ds', function()
            Snacks.picker.lsp_symbols()
          end, '[D]ocument [S]ymbols')
          map('<leader>ws', function()
            Snacks.picker.lsp_workspace_symbols()
          end, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- C/C++ formatting setup
      vim.env.PATH = '/opt/homebrew/bin:' .. vim.env.PATH
      local stylePath = '/Users/jreng/Documents/Poems/kuassa/___lib___/JUCE.clang-format'
      vim.g.clang_format_command = 'clang-format --style=file:' .. stylePath

      function FormatBuffer()
        local filetype = vim.bo.filetype
        if filetype == 'cpp' or filetype == 'c' or filetype == 'objc' or filetype == 'objcpp' then
          vim.schedule(function()
            local command = vim.g.clang_format_command
            local tmpfile = vim.fn.tempname()
            vim.cmd('write! ' .. tmpfile)
            local formatted = vim.fn.system(command .. ' < ' .. tmpfile)
            vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.fn.split(formatted, '\n'))
            os.remove(tmpfile)
          end)
        end
      end

      function FormatWithConform()
        local filetype = vim.bo.filetype
        if filetype ~= 'cpp' and filetype ~= 'c' and filetype ~= 'objc' and filetype ~= 'objcpp' then
          vim.schedule(function()
            require('conform').format { async = true, lsp_format = 'fallback' }
          end)
        end
      end

      vim.cmd [[
augroup FormatOnSave
  autocmd!
  autocmd BufWritePre *.cpp,*.c,*.h,*.hpp,*.objc,*.objcpp lua FormatBuffer()
augroup END
]]

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, { 'stylua' })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  -- ══════════════════════════════════════════════════════════════════════════
  -- conform.nvim: Code formatter
  -- Keybind: <Space>f (Format buffer)
  -- ══════════════════════════════════════════════════════════════════════════
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true, objc = true, objcpp = true }
        local lsp_format_opt = disable_filetypes[vim.bo[bufnr].filetype] and 'never' or 'fallback'
        return { timeout_ms = 500, lsp_format = lsp_format_opt }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
      },
    },
  },

  -- ══════════════════════════════════════════════════════════════════════════
  -- nvim-cmp: Autocompletion engine (LSP only)
  -- Keybinds:
  --   <C-n>: Next item
  --   <C-p>: Previous item
  --   <C-b>: Scroll docs back
  --   <C-f>: Scroll docs forward
  --   <CR>: Confirm
  --   <Tab>: Next item
  --   <S-Tab>: Previous item
  --   <C-Space>: Complete
  -- ══════════════════════════════════════════════════════════════════════════
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      local cmp = require 'cmp'

      cmp.setup {
        completion = { completeopt = 'menu,menuone,noinsert' },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<CR>'] = cmp.mapping.confirm { select = true },
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
          ['<C-Space>'] = cmp.mapping.complete {},
        },
        sources = {
          { name = 'nvim_lsp' },
        },
      }
    end,
  },

  -- ══════════════════════════════════════════════════════════════════════════
  -- onedark.nvim: Color scheme
  -- No keybinds (theme only)
  -- ══════════════════════════════════════════════════════════════════════════
  {
    'navarasu/onedark.nvim',
    priority = 1000,
    init = function()
      vim.cmd 'colorscheme gfx'
      vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'EndOfBuffer', { fg = '#121212' })
      vim.api.nvim_set_hl(0, 'LineNr', { fg = '#222222' })
      vim.api.nvim_set_hl(0, 'WinSeparator', { fg = '#5B8181' })
      vim.cmd.hi 'Comment gui=none'
    end,
  },

  -- ══════════════════════════════════════════════════════════════════════════
  -- todo-comments.nvim: Highlight TODO, NOTE, etc in comments
  -- No keybinds (syntax highlighting only)
  -- ══════════════════════════════════════════════════════════════════════════
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  -- ══════════════════════════════════════════════════════════════════════════
  -- mini.nvim: Collection of minimal utilities
  -- Components: ai, surround, statusline
  -- No keybinds (visual/integration only)
  -- ══════════════════════════════════════════════════════════════════════════
  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },

  -- ══════════════════════════════════════════════════════════════════════════
  -- nvim-treesitter: Syntax highlighting and parsing
  -- No keybinds (syntax/parsing only)
  -- ══════════════════════════════════════════════════════════════════════════
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
  },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
