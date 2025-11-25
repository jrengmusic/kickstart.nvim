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
  if filetype == 'cpp' or filetype == 'c' or filetype == 'objc' or filetype == 'objcpp'
  then
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
  if filetype == 'cpp' or filetype == 'c' or filetype == 'objc' or filetype == 'objcpp'
  then
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
vim.api.nvim_create_autocmd('TextYankPost',
{
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Format on mode change
vim.api.nvim_create_autocmd('ModeChanged',
{
  pattern = { 'c:n' },
  callback = function()
    local filetype = vim.bo.filetype
    if filetype == 'cpp' or filetype == 'c' or filetype == 'objc' or filetype == 'objcpp'
    then
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
if not (vim.uv or vim.loop).fs_stat(lazypath)
then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0
  then
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
    opts =
    {
      signs =
      {
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
    opts =
    {
      delay = 0,
      icons =
      {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or
        {
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
      spec =
      {
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

  -- ══════════════════════════════════════════════════════════════════════════
  -- telescope.nvim: Fuzzy finder for files, grep, diagnostics
  -- Keybinds: <Space>f* (Find commands) and <Space>s* (Search commands)
  --   <Space>ff: Find files
  --   <Space>fg: Live grep in workspace
  --   <Space>fb: Find buffers
  --   <Space>fh: Find help tags
  --   <Space>sh: Search help tags
  --   <Space>sk: Search keymaps
  --   <Space>sf: Search files
  --   <Space>ss: Search telescope builtins
  --   <Space>sw: Search current word
  --   <Space>sg: Live grep in workspace
  --   <Space>sd: Search diagnostics
  --   <Space>sr: Resume last search
  --   <Space>s.: Search recent files
  --   <Space><Space>: Search buffers
  --   <Space>/: Fuzzy search in current buffer
  --   <Space>s/: Live grep in open files
  --   <Space>sn: Search nvim config files
  -- ══════════════════════════════════════════════════════════════════════════
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies =
    {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    keys =
    {
      -- Find commands (f prefix)
      { '<leader>ff', function() require('telescope.builtin').find_files() end, desc = '[F]ind [F]iles' },
      { '<leader>fg', function() require('telescope.builtin').live_grep() end, desc = '[F]ind by [G]rep' },
      { '<leader>fb', function() require('telescope.builtin').buffers() end, desc = '[F]ind [B]uffers' },
      { '<leader>fh', function() require('telescope.builtin').help_tags() end, desc = '[F]ind [H]elp tags' },
      -- Search commands (s prefix)
      { '<leader>sh', function() require('telescope.builtin').help_tags() end, desc = '[S]earch [H]elp' },
      { '<leader>sk', function() require('telescope.builtin').keymaps() end, desc = '[S]earch [K]eymaps' },
      { '<leader>sf', function() require('telescope.builtin').find_files() end, desc = '[S]earch [F]iles' },
      { '<leader>ss', function() require('telescope.builtin').builtin() end, desc = '[S]earch [S]elect Telescope' },
      { '<leader>sw', function() require('telescope.builtin').grep_string() end, desc = '[S]earch current [W]ord' },
      { '<leader>sg', function() require('telescope.builtin').live_grep() end, desc = '[S]earch by [G]rep' },
      { '<leader>sd', function() require('telescope.builtin').diagnostics() end, desc = '[S]earch [D]iagnostics' },
      { '<leader>sr', function() require('telescope.builtin').resume() end, desc = '[S]earch [R]esume' },
      { '<leader>s.', function() require('telescope.builtin').oldfiles() end, desc = '[S]earch Recent Files ("." for repeat)' },
      { '<leader><leader>', function() require('telescope.builtin').buffers() end, desc = '[ ] Find existing buffers' },
      {
        '<leader>/',
        function()
          require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end,
        desc = '[/] Fuzzily search in current buffer'
      },
      {
        '<leader>s/',
        function()
          require('telescope.builtin').live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          }
        end,
        desc = '[S]earch [/] in Open Files'
      },
      {
        '<leader>sn',
        function()
          require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
        end,
        desc = '[S]earch [N]eovim files'
      },
    },
    config = function()
      require('telescope').setup {
        extensions =
        {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
    end,
  },

  -- ══════════════════════════════════════════════════════════════════════════
  -- gen.nvim: AI code generation with Ollama (qwen2.5-coder:14b)
  -- Keybinds:
  --   <Space>gq (visual): Chat with selection
  --   <Space>gq (normal): Chat with buffer
  -- ══════════════════════════════════════════════════════════════════════════
  {
    'David-Kunz/gen.nvim',
    opts =
    {
      model = 'qwen2.5-coder:14b',
      host = 'localhost',
      port = '11434',
      display_mode = 'vertical-split',
      show_model = true,
    },
    keys =
    {
      { '<leader>gq', ':Gen<CR>', mode = 'v', desc = 'Gen: Chat with selection' },
      { '<leader>gq', ':Gen<CR>', mode = 'n', desc = 'Gen: Chat with buffer' },
    },
  },

  -- ══════════════════════════════════════════════════════════════════════════
  -- lazydev.nvim: Lua LSP for Neovim config
  -- No keybinds (auto completion only)
  -- ══════════════════════════════════════════════════════════════════════════
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts =
    {
      library =
      {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
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
    dependencies =
    {
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach',
      {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight)
          then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' },
            {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' },
            {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach',
            {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint)
          then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- C/C++ formatting setup
      vim.env.PATH = '/opt/homebrew/bin:' .. vim.env.PATH
      local stylePath = '/Users/jreng/Documents/Poems/___PROJECT___/___lib___/JUCE.clang-format'
      vim.g.clang_format_command = 'clang-format --style=file:' .. stylePath

      function FormatBuffer()
        local filetype = vim.bo.filetype
        if filetype == 'cpp' or filetype == 'c' or filetype == 'objc' or filetype == 'objcpp'
        then
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
        if filetype ~= 'cpp' and filetype ~= 'c' and filetype ~= 'objc' and filetype ~= 'objcpp'
        then
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

      local servers =
      {
        lua_ls =
        {
          settings =
          {
            Lua =
            {
              completion = { callSnippet = 'Replace' },
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, { 'stylua' })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers =
        {
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
    keys =
    {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts =
    {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true, objc = true, objcpp = true }
        local lsp_format_opt = disable_filetypes[vim.bo[bufnr].filetype] and 'never' or 'fallback'
        return { timeout_ms = 500, lsp_format = lsp_format_opt }
      end,
      formatters_by_ft =
      {
        lua = { 'stylua' },
      },
    },
  },

  -- ══════════════════════════════════════════════════════════════════════════
  -- nvim-cmp: Autocompletion engine
  -- Keybinds:
  --   <C-n>: Next item
  --   <C-p>: Previous item
  --   <C-b>: Scroll docs back
  --   <C-f>: Scroll docs forward
  --   <CR>: Confirm
  --   <Tab>: Next item
  --   <S-Tab>: Previous item
  --   <C-Space>: Complete
  --   <C-l>: Jump forward in snippet
  --   <C-h>: Jump backward in snippet
  -- Dependencies: LuaSnip, cmp_luasnip, cmp-nvim-lsp, cmp-path
  -- ══════════════════════════════════════════════════════════════════════════
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies =
    {
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0
          then
            return
          end
          return 'make install_jsregexp'
        end)(),
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      cmp.setup {
        snippet =
        {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
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
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable()
            then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1)
            then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        },
        sources =
        {
          { name = 'lazydev', group_index = 0 },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
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
    opts =
    {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      auto_install = true,
      highlight =
      {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
  },

  -- ══════════════════════════════════════════════════════════════════════════
  -- neo-tree.nvim: File explorer (from kickstart plugins)
  -- ══════════════════════════════════════════════════════════════════════════
  require 'kickstart.plugins.neo-tree',

}, {
  ui =
  {
    icons = vim.g.have_nerd_font and {} or
    {
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
