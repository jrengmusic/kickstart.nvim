-- GFX color scheme for Neovim
-- Converted from Xcode theme

local M = {}

M.setup = function()
  -- Reset highlights
  vim.cmd 'highlight clear'
  if vim.fn.exists 'syntax_on' then
    vim.cmd 'syntax reset'
  end

  vim.o.background = 'dark'
  vim.g.colors_name = 'gfx'

  -- Helper function to convert RGB float (0-1) to hex
  local function rgb_to_hex(r, g, b)
    return string.format('#%02x%02x%02x', math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
  end

  -- Define colors (converted from Xcode's RGB float values)
  local colors = {
    -- Base colors
    bg = '#000000', -- DVTSourceTextBackground
    fg = '#c0c0c0', -- xcode.syntax.plain (0.752941 * 255)
    cursor = '#ffffff',

    -- UI colors
    current_line = '#1a1919', -- DVTSourceTextCurrentLineHighlightColor
    selection = '#4a4740', -- DVTSourceTextSelectionColor
    visual = '#4a4740',
    invisibles = '#333333', -- DVTSourceTextInvisiblesColor

    -- Console colors
    console_bg = '#070d0e', -- DVTConsoleTextBackgroundColor
    console_fg = '#a2e7e7', -- DVTConsoleDebuggerOutputTextColor
    console_prompt = '#00ffff', -- DVTConsoleDebuggerPromptTextColor

    -- Syntax colors
    comment = '#80a0ff', -- Same as koehler theme
    keyword = '#4080ff', -- Bright blue for keywords
    string = '#ffc0c0', -- 1 0.752941 0.752941
    character = '#ffadb0', -- 1 0.679933 0.685268
    number = '#00ff00', -- 0 1 0
    boolean = '#00ff00',

    -- Types and declarations
    type = '#ffa0ff', -- 1 0.446703 0.396389 (identifier.type)
    type_system = '#00a0ff', -- 0 0.626 1 (identifier.type.system)
    declaration = '#00c0ff', -- 0 0.752941 1
    class = '#00c0ff', -- 0 0.752941 1
    class_system = '#00fffd', -- 0 1 0.991667

    -- Functions and identifiers
    func = '#80ffff', -- Bright cyan (back to original)
    constant = '#ffff66', -- 1 1 0.397946
    constant_system = '#00a0ff', -- 0 0.626 1
    variable = '#00c6ff', -- 0 0.776368 1
    variable_system = '#00a0ff', -- 0 0.626 1

    -- Preprocessor and macros
    macro = '#9aff00', -- 0.603793 1 0
    preprocessor = '#9aff00',

    -- Markup and documentation
    markup_code = '#aa0d91', -- 0.665 0.052 0.569
    url = '#4164ff', -- 0.255 0.392 1

    -- Regex
    regex = '#ff2b38', -- 1 0.171 0.219
    regex_capture = '#23ff83', -- 0.137 1 0.512
    regex_number = '#00ff00',

    -- Diagnostics and scrollbar markers
    error = '#f74a4a', -- 0.968627 0.290196 0.290196
    warning = '#efb759', -- 0.937255 0.717647 0.34902
    info = '#a482ff', -- 0.643137 0.509804 1
    hint = '#6767f7', -- 0.403922 0.372549 1
    breakpoint = '#4a4af7', -- 0.290196 0.290196 0.968627

    -- Special
    special = '#ff2b38',
    attribute = '#2d43b9', -- 0.177359 0.265488 0.608972
  }

  -- Helper function to set highlights
  local function hi(group, opts)
    local cmd = 'highlight ' .. group
    if opts.fg then
      cmd = cmd .. ' guifg=' .. opts.fg
    end
    if opts.bg then
      cmd = cmd .. ' guibg=' .. opts.bg
    end
    if opts.gui then
      cmd = cmd .. ' gui=' .. opts.gui
    end
    if opts.sp then
      cmd = cmd .. ' guisp=' .. opts.sp
    end
    vim.cmd(cmd)
  end

  -- Helper function for linking highlights
  local function link(from, to)
    vim.cmd('highlight link ' .. from .. ' ' .. to)
  end

  -- Editor UI
  hi('Normal', { fg = colors.fg, bg = colors.bg })
  hi('NormalFloat', { fg = colors.fg, bg = '#0a0a0a' })
  hi('Cursor', { fg = colors.bg, bg = colors.cursor })
  hi('CursorLine', { bg = colors.current_line })
  hi('CursorLineNr', { fg = colors.number, gui = 'bold' })
  hi('LineNr', { fg = '#4a4a4a' })
  hi('SignColumn', { bg = colors.bg })
  hi('Visual', { bg = colors.visual })
  hi('VisualNOS', { bg = colors.visual })
  hi('Search', { fg = colors.bg, bg = colors.warning })
  hi('IncSearch', { fg = colors.bg, bg = colors.number })
  hi('MatchParen', { fg = colors.cursor, bg = colors.keyword, gui = 'bold' })

  -- Statusline
  hi('StatusLine', { fg = colors.fg, bg = '#1a1a1a', gui = 'bold' })
  hi('StatusLineNC', { fg = '#666666', bg = '#0d0d0d' })
  hi('VertSplit', { fg = '#1a1a1a', bg = colors.bg })
  hi('WinSeparator', { fg = '#1a1a1a', bg = colors.bg })

  -- Tabline
  hi('TabLine', { fg = '#808080', bg = '#1a1a1a' })
  hi('TabLineFill', { bg = '#0d0d0d' })
  hi('TabLineSel', { fg = colors.fg, bg = colors.bg, gui = 'bold' })

  -- Popups
  hi('Pmenu', { fg = colors.fg, bg = '#1a1a1a' })
  hi('PmenuSel', { fg = colors.bg, bg = colors.func })
  hi('PmenuSbar', { bg = '#2a2a2a' })
  hi('PmenuThumb', { bg = '#4a4a4a' })

  -- Folds
  hi('Folded', { fg = colors.comment, bg = '#0d0d0d' })
  hi('FoldColumn', { fg = colors.comment, bg = colors.bg })

  -- Diff
  hi('DiffAdd', { bg = '#1a2a1a' })
  hi('DiffChange', { bg = '#1a1a2a' })
  hi('DiffDelete', { fg = colors.error, bg = '#2a1a1a' })
  hi('DiffText', { bg = '#2a2a4a', gui = 'bold' })

  -- Spelling
  hi('SpellBad', { sp = colors.error, gui = 'undercurl' })
  hi('SpellCap', { sp = colors.warning, gui = 'undercurl' })
  hi('SpellRare', { sp = colors.info, gui = 'undercurl' })
  hi('SpellLocal', { sp = colors.hint, gui = 'undercurl' })

  -- Diagnostics
  hi('DiagnosticError', { fg = colors.error })
  hi('DiagnosticWarn', { fg = colors.warning })
  hi('DiagnosticInfo', { fg = colors.info })
  hi('DiagnosticHint', { fg = colors.hint })
  hi('DiagnosticUnderlineError', { sp = colors.error, gui = 'undercurl' })
  hi('DiagnosticUnderlineWarn', { sp = colors.warning, gui = 'undercurl' })
  hi('DiagnosticUnderlineInfo', { sp = colors.info, gui = 'undercurl' })
  hi('DiagnosticUnderlineHint', { sp = colors.hint, gui = 'undercurl' })

  -- Syntax highlighting
  hi('Comment', { fg = colors.comment, gui = 'italic' })
  hi('Constant', { fg = colors.constant })
  hi('String', { fg = colors.string })
  hi('Character', { fg = colors.character })
  hi('Number', { fg = colors.number })
  hi('Boolean', { fg = colors.boolean })
  hi('Float', { fg = colors.number })

  hi('Identifier', { fg = colors.variable })
  hi('Function', { fg = colors.func })

  hi('Statement', { fg = colors.keyword, gui = 'bold' })
  hi('Conditional', { fg = colors.keyword, gui = 'bold' })
  hi('Repeat', { fg = colors.keyword, gui = 'bold' })
  hi('Label', { fg = colors.keyword, gui = 'bold' })
  hi('Operator', { fg = colors.keyword })
  hi('Keyword', { fg = colors.keyword, gui = 'bold' })
  hi('Exception', { fg = colors.keyword, gui = 'bold' })

  hi('PreProc', { fg = colors.preprocessor })
  hi('Include', { fg = colors.preprocessor })
  hi('Define', { fg = colors.macro, gui = 'bold' })
  hi('Macro', { fg = colors.macro, gui = 'bold' })
  hi('PreCondit', { fg = colors.preprocessor })

  hi('Type', { fg = colors.type })
  hi('StorageClass', { fg = colors.keyword, gui = 'bold' })
  hi('Structure', { fg = colors.type })
  hi('Typedef', { fg = colors.type })

  hi('Special', { fg = '#b0b0b0' }) -- Brighter gray for brackets
  hi('SpecialChar', { fg = colors.character })
  hi('Tag', { fg = colors.attribute })
  hi('Delimiter', { fg = '#808080' }) -- Gray for braces and delimiters
  hi('SpecialComment', { fg = colors.comment, gui = 'bold' })
  hi('Debug', { fg = colors.error })

  hi('Error', { fg = colors.error, gui = 'bold' })
  hi('ErrorMsg', { fg = colors.error, gui = 'bold' })
  hi('WarningMsg', { fg = colors.warning, gui = 'bold' })
  hi('Todo', { fg = colors.info, bg = colors.bg, gui = 'bold' })

  hi('Title', { fg = colors.class, gui = 'bold' })
  hi('Directory', { fg = colors.func })
  hi('Underlined', { fg = colors.url, gui = 'underline' })

  -- Treesitter highlights
  link('TSComment', 'Comment')
  link('TSConstant', 'Constant')
  link('TSString', 'String')
  link('TSCharacter', 'Character')
  link('TSNumber', 'Number')
  link('TSBoolean', 'Boolean')
  link('TSFloat', 'Float')

  link('TSFunction', 'Function')
  link('TSFunctionBuiltin', 'Function')
  link('TSMethod', 'Function')

  link('TSKeyword', 'Keyword')
  link('TSConditional', 'Conditional')
  link('TSRepeat', 'Repeat')
  link('TSLabel', 'Label')
  link('TSOperator', 'Operator')
  link('TSException', 'Exception')

  link('TSVariable', 'Identifier')
  hi('TSVariableBuiltin', { fg = colors.variable_system })

  hi('TSType', { fg = colors.type })
  hi('TSTypeBuiltin', { fg = colors.type_system })
  hi('TSConstructor', { fg = colors.class })

  hi('TSProperty', { fg = colors.variable })
  hi('TSField', { fg = colors.variable })
  hi('TSParameter', { fg = colors.variable })

  link('TSInclude', 'Include')
  link('TSDefine', 'Define')
  link('TSMacro', 'Macro')

  hi('TSTag', { fg = colors.attribute })
  hi('TSTagAttribute', { fg = colors.variable })
  link('TSTagDelimiter', 'Delimiter')

  -- Brackets and punctuation
  hi('TSPunctBracket', { fg = '#808080' })
  hi('TSPunctDelimiter', { fg = '#808080' })

  -- LSP semantic tokens
  hi('LspClass', { fg = colors.class })
  hi('LspStruct', { fg = colors.type })
  hi('LspEnum', { fg = colors.type })
  hi('LspInterface', { fg = colors.class_system })
  hi('LspFunction', { fg = colors.func })
  hi('LspMethod', { fg = colors.func })
  hi('LspVariable', { fg = colors.variable })
  hi('LspParameter', { fg = colors.variable })
  hi('LspProperty', { fg = colors.variable })
  hi('LspMacro', { fg = colors.macro, gui = 'bold' })

  -- Git signs
  hi('GitSignsAdd', { fg = colors.number })
  hi('GitSignsChange', { fg = colors.warning })
  hi('GitSignsDelete', { fg = colors.error })

  -- Telescope
  hi('TelescopeBorder', { fg = '#4a4a4a' })
  hi('TelescopePromptBorder', { fg = colors.func })
  hi('TelescopeSelection', { bg = colors.current_line })
  hi('TelescopeMatching', { fg = colors.number, gui = 'bold' })
end

-- Auto-load the theme
M.setup()

return M
