
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.api.nvim_set_keymap("n","<ESC>",":noh<CR>",{noremap=true})
vim.api.nvim_set_keymap("n","gd","<cmd>lua vim.lsp.buf.definition()<CR>",{noremap=true})
vim.api.nvim_set_keymap("n","gD",":noh<CR>",{noremap=true})

vim.opt.number=true
vim.opt.relativenumber=true
vim.opt.clipboard = 'unnamedplus'
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.incsearch = true
vim.opt.termguicolors = true

require("lazy").setup({
  spec = {
    {
      'nvim-telescope/telescope.nvim', tag = '0.1.8',
      dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
      },
      config = function()
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        cmp_lsp.default_capabilities()
        )

        require("fidget").setup({})
        require("mason").setup()

        require('mason-lspconfig').setup({
          ensure_installed = {
            "tsserver",
            "clangd",
            "lua_ls",
            "ruff"
          },
          handlers = {
            function(server_name)
              require('lspconfig')[server_name].setup({
                capabilities = capabilities,
              })
            end,
            lua_ls = function()
              require('lspconfig').lua_ls.setup({
                capabilities = capabilities,
                settings = {
                  Lua = {
                    runtime = {
                      version = 'LuaJIT'
                    },
                    diagnostics = {
                      globals = { 'vim', 'love' },
                    },
                    workspace = {
                      library = {
                        vim.env.VIMRUNTIME,
                      }
                    }
                  }
                }
              })
            end
          }
        })

        local cmp = require('cmp')
        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        -- this is the function that loads the extra snippets to luasnip
        -- from rafamadriz/friendly-snippets
        require('luasnip.loaders.from_vscode').lazy_load()

        cmp.setup({
          sources = {
            { name = 'path' },
            { name = 'nvim_lsp' },
            { name = 'luasnip', keyword_length = 2 },
            { name = 'buffer',  keyword_length = 3 },
          },
          mapping = cmp.mapping.preset.insert({
            ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
            ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
            ['<C-Space>'] = cmp.mapping.complete(),
          }),
          snippet = {
            expand = function(args)
              require('luasnip').lsp_expand(args.body)
            end,
          },
        })
      end
    } 
  },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = true },
})
