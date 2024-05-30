--
-- init.lua -- Neovim configuration file
-- tanskudaa 2024, MIT Licence
--

-- Disable "Undefined global `vim`" warnings
---@diagnostic disable: undefined-global


-- vim.* shorthand declarations
local g = vim.g
local opt = vim.opt
local keymap = vim.keymap

local vimrc_augroup = vim.api.nvim_create_augroup('vimrc_augroup', {})


-- Vim set commands
do
    -- Set leader key
    g.mapleader = ' '
    g.maplocalleader = ' '

    -- Make backspace behave as expected
    opt.backspace = 'indent,eol,start'

    -- Enable mouse mode, can be useful for resizing splits etc.
    opt.mouse = 'a'

    -- Search
    opt.ignorecase = true -- case insensitive search
    opt.smartcase = true  -- switch to case sensitive if search term has capital letters

    -- Swap- and undofiles
    opt.swapfile = false
    opt.backup = false
    opt.undodir = os.getenv('HOME') .. '/.vim/undodir'
    opt.undofile = true

    -- Colors
    opt.termguicolors = true

    -- Nerd font (icons)
    g.have_nerd_font = false

    -- Pretty border on hovers
    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
        vim.lsp.handlers.hover,
        { border = 'rounded' }
    )

    -- Pretty border on diagnostics
    vim.diagnostic.config({
        float = {
            border = 'rounded'
        },
    })

    -- Rulers
    opt.colorcolumn = { 80, 120 }

    -- Tab
    local tabwidth = 4        -- these should generally be set to same
    opt.tabstop = tabwidth    -- n columns of whitespace per \t
    opt.shiftwidth = tabwidth -- indentation is n columns of whitespace
    opt.softtabstop = 0       -- soft tab stop off, don't mix spaces and tabs
    opt.expandtab = true      -- use spaces as tabs
    opt.autoindent = true     -- keep indentation on new line
    opt.smartindent = true    -- be smart

    -- Line wrapping
    opt.wrap = false
    opt.breakindent = true -- wrapped lines continue with indentation

    -- Folds
    opt.foldmethod = 'expr'
    opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    opt.foldenable = false -- don't fold code when opening files

    -- Left margin
    opt.relativenumber = true -- relative line numbers
    opt.number = true         -- absolute line number at cursor
    opt.signcolumn = 'yes'    -- leave space for sign column

    -- Highlights
    opt.hlsearch = true   -- highlight search results
    opt.cursorline = true -- highlight current line

    -- Minimum number of lines to keep above and below cursor
    opt.scrolloff = 12

    -- Focus newly created splits
    opt.splitright = true
    opt.splitbelow = true

    -- Save cursor position, folds etc. on buffer exit, load on enter
    vim.api.nvim_create_autocmd('BufWinEnter', {
        group = vimrc_augroup,
        pattern = '*.*',
        command = 'silent! loadview'
    })
    vim.api.nvim_create_autocmd('BufWinLeave', {
        group = vimrc_augroup,
        pattern = '*.*',
        command = 'mkview'
    })
end


-- Vim remap commands
do
    -- Unmap arrow keys
    keymap.set('', '<Up>', '<NOP>')
    keymap.set('', '<Down>', '<NOP>')
    keymap.set('', '<Left>', '<NOP>')
    keymap.set('', '<Right>', '<NOP>')

    -- Buffer switching
    keymap.set('n', '<Tab>', vim.cmd.bnext, { desc = 'Switch to next buffer' })
    keymap.set('n', '<S-Tab>', vim.cmd.bprevious, { desc = 'Switch to previous buffer' })

    -- Explore
    keymap.set('n', '<leader>E', vim.cmd.Explore, { desc = '[E]xplore' })

    -- Clear search highlight
    keymap.set('n', '<leader><backspace>', '<cmd>nohlsearch<CR>', { desc = 'Clear search higlights' })

    -- K as join for above line (like J in default vim)
    keymap.set('n', 'K', 'k_DjA <ESC>pkdd', { desc = 'Join the line above to the end of current line' })

    -- More immediate split navigation
    keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
    keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
    keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
    keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

    -- Yank to system clipboard
    keymap.set('', '<leader>y', '"+y', { desc = 'y to system clipboard' })
    keymap.set('', '<leader>Y', '"+Y', { desc = 'Y to system clipboard' })
    -- NOTE Following is also useful, but enabling it delays <leader>y activation time
    -- keymap.set('', '<leader>yy', '"+yy', { desc = 'yy to system clipboard' })

    -- Paste from system clipboard
    keymap.set('', '<leader>p', '"+p', { desc = 'p from system clipboard' })
    keymap.set('', '<leader>P', '"+P', { desc = 'P from system clipboard' })

    -- Delete to null register
    keymap.set('', '<leader>d', '"_d', { desc = 'd to null register' })
    keymap.set('', '<leader>x', '"_x', { desc = 'x to null register' })

    -- LSP keymaps
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vimrc_augroup,
        callback = function(e)
            local opts = function(desc) return { buffer = e.buf, desc = desc } end

            keymap.set('n', 'gd', function() vim.lsp.buf.definition() end,
                opts('[G]o to symbol [d]efinition')
            )
            keymap.set('n', '<leader>rn', function() vim.lsp.buf.rename() end,
                opts('[R]e[n]ame symbol')
            )
            keymap.set('n', '<leader>f', function() vim.lsp.buf.format() end,
                opts('[F]ormat buffer')
            )
            keymap.set('n', '<leader>h', function() vim.lsp.buf.hover() end,
                opts('[H]over symbol under cursor')
            )
            keymap.set('n', '<leader>l', function() vim.diagnostic.open_float() end,
                opts('Open diagnostic [l]ogs on current line')
            )
        end,
    })
end


-- Install lazy.nvim plugin manager if not already installed
do
    local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
    if not vim.loop.fs_stat(lazypath) then
        local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
        vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
    end ---@diagnostic disable-next-line: undefined-field
    vim.opt.rtp:prepend(lazypath)
end

-- Install and configure plugins
require('lazy').setup({
    { -- Treesitter, syntax highlighting
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup {
                ensure_installed = { 'lua', 'vim', 'vimdoc', },
                sync_install = false,
                auto_install = true,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = { enable = true },
            }
        end,
    },

    { -- Telescope, fuzzy finder
        'nvim-telescope/telescope.nvim',
        tag = '0.1.6',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local actions = require('telescope.actions')

            require('telescope').setup({
                defaults = {
                    mappings = {
                        i = { -- Insert mode
                            ['<C-n>'] = actions.move_selection_next,
                            ['<C-p>'] = actions.move_selection_previous,
                            ['<C-y>'] = actions.select_default,
                            ['<ESC>'] = actions.close,
                        }
                    }
                }
            })

            local builtin = require('telescope.builtin')

            keymap.set('n', '<leader>tf', builtin.find_files, { desc = '[T]elescope - Search [f]files' })
            keymap.set('n', '<leader>tg', builtin.git_files, { desc = '[T]elescope - Search [g]it' })
            keymap.set('n', '<leader>tb', builtin.buffers, { desc = '[T]elescope - Search [b]uffers' })
            keymap.set('n', '<leader>ts', function() builtin.grep_string { search = '' } end, {
                desc = '[T]elescope - Search [s]tring'
            })
            keymap.set('n', '<leader>tk', builtin.keymaps, { desc = '[T]elescope - Search [k]eymaps' })
        end,

    },

    { -- nvim-lspconfig, LSP support
        'neovim/nvim-lspconfig',
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/nvim-cmp',
            'L3MON4D3/LuaSnip',
        },
        config = function()
            local cmp_lsp = require('cmp_nvim_lsp')
            local capabilities = vim.tbl_deep_extend(
                'force',
                {},
                vim.lsp.protocol.make_client_capabilities(),
                cmp_lsp.default_capabilities()
            )

            require('mason').setup()
            require('mason-lspconfig').setup({
                ensure_installed = {
                    'lua_ls',
                },
                handlers = {
                    function(server_name)
                        require('lspconfig')[server_name].setup({
                            capabilities = capabilities
                        })
                    end,
                },
            })

            local cmp = require('cmp')
            local cmp_select = { behavior = cmp.SelectBehavior.Select }

            cmp.setup({
                snippet = { -- required, snippet engine must be specified
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end
                },

                mapping = {
                    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                    ['<Down>'] = cmp.mapping.select_next_item(cmp_select),
                    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                    ['<Up>'] = cmp.mapping.select_prev_item(cmp_select),
                    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                },

                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                }, {
                    { name = 'buffer' },
                })
            })
        end,
    },

    { -- mini.nvim, status bar and auto closing parentheses
        'echasnovski/mini.nvim',
        config = function()
            require('mini.pairs').setup()

            local statusline = require('mini.statusline')
            statusline.setup({ use_icons = g.have_nerd_font })
            statusline.section_location = function()
                return '%2l:%-2v'
            end
            opt.showmode = false -- statusline makes vim showmode redundant
        end,
    },

    { -- gitsigns, display git status symbols in left margin
        'lewis6991/gitsigns.nvim',
        config = function()
            local gitsigns = require('gitsigns')
            gitsigns.setup({
                signs = {
                    add          = { text = '+' },
                    change       = { text = '┃' },
                    delete       = { text = '-' },
                    topdelete    = { text = '-' },
                    changedelete = { text = '~' },
                    untracked    = { text = '┆' },
                },
                signcolumn = true,
                watch_gitdir = { follow_files = true },
                current_line_blame = true,
                current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
            })

            keymap.set('n', '<leader>g', gitsigns.preview_hunk_inline, { desc = 'View git changes inline' })
        end,
    },

    { -- Todo Comments, highlighting for todo, note etc. comments
        'folke/todo-comments.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = {
            signs = false,
            highlight = {
                multiline = true,
                multiline_pattern = '^.',       -- lua pattern
                multiline_context = 10,
                before = 'fg',                  -- highlight line contents before keyword
                keyword = 'bg',                 -- highlight keyword background
                after = 'fg',                   -- highlight the comment contents
                pattern = [[.*<(KEYWORDS)\s*]], -- vim regex
                comments_only = true,
                max_line_len = 200,
                exclude = {},
            },
        },
    },

    { -- rose-pine, colorscheme
        'rose-pine/neovim',
        name = 'rose-pine',
        config = function()
            require("rose-pine").setup({
                variant = "main",
                dark_variant = "main",
                dim_inactive_windows = true,
                extend_background_behind_borders = true,

                enable = {
                    terminal = true
                },

                styles = {
                    bold = true,
                    italic = true,
                    transparency = false,
                },
            })

            vim.cmd("colorscheme rose-pine")
        end,
    }
})
