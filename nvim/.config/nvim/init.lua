-- Automatically install packer if not installed 
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({
    'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path
  })
  vim.cmd([[packadd packer.nvim]])
end

-- Enable line numbers
vim.o.number = true

-- Enable relative line numbers
vim.o.relativenumber = true

-- Set tabs to 2 spaces (for example)
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

-- Enable line wrapping
vim.o.wrap = true

-- Search settings
vim.o.ignorecase = true
vim.o.smartcase = true

vim.opt.termguicolors = true

vim.o.splitbelow = true
vim.o.splitright = true

-- Lexplore
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 18
vim.g.netrw_altfile = 1
vim.g.netrw_browse_split = 3

-- Folding
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldlevel = 99
vim.o.viewoptions = "folds,cursor"

-- Set the color scheme (assuming you've installed gruvbox)
vim.g.catppuccin_flavour = "macchiato"
vim.cmd("colorscheme catppuccin")

require("colorizer").setup({
  "*";  -- Enable for all file types
}, {
  names = false;  -- Disable color name highlighting (no "red", "blue", etc.)
  RGB = true;      -- Highlight #RRGGBB hex color codes
  RRGGBB = true;   -- Highlight #RRGGBB color codes
  RRGGBBAA = true; -- Highlight #RRGGBBAA color codes
  rgb_fn = true;   -- Highlight rgb() and rgba() CSS functions
  hsl_fn = true;   -- Highlight hsl() and hsla() CSS functions
  mode = 'background';  -- You can try 'foreground' or 'virtualtext'
})

-- Initialize packer
require('packer').startup(function(use)

  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Syntax highlighting and other language tools (nvim-treesitter)
  use 'nvim-treesitter/nvim-treesitter'

  -- Fuzzy finder (Telescope)
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- Status line (lualine)
  use 'hoob3rt/lualine.nvim'

  -- Autocompletion (nvim-cmp)
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'

  -- LSP support (nvim-lspconfig)
  use 'neovim/nvim-lspconfig'

  -- Git integration (vim-fugitive)
  use 'tpope/vim-fugitive'

  -- Color scheme (gruvbox)
  use { "catppuccin/nvim", as = "catppuccin" }

  use 'norcalli/nvim-colorizer.lua'

  use 'famiu/bufdelete.nvim'

  -- image
  use {
    '3rd/image.nvim',
    config = function()
      require('image').setup({
        backend = "kitty",  -- or "ueberzug" for non-kitty terminals
        max_height_window_percentage = 50,
        hijack_file_patterns = {
          "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.svg"
        },
      })
    end
  }

  --image_preview
  use {
  'adelarsq/image_preview.nvim',
  config = function()
    require('image_preview').setup()
  end
}

  -- bufferline
  use {
    'akinsho/bufferline.nvim',
    tag = "*",
    requires = 'nvim-tree/nvim-web-devicons',
    config = function()
      require("bufferline").setup({
        options = {
          close_command = "Bdelete! %d",
          right_mouse_command = "Bdelete! %d",
          show_close_icon = false,
          show_buffer_close_icons = false,
          offsets = {
            {
              filetype = "neo-tree",
              text = "File Explorer",
              text_align = "left",
              separator = true
            }
          }
        }
      })
    end
  }

  -- neo-tree
  use {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- Clean file icons
      "MunifTanjim/nui.nvim",
    },
    config = function()
      -- Minimal clean setup
      require("neo-tree").setup({
        close_if_last_window = true,
        window = {
          width = 30,
          mappings = {
            ["<leader>p"] = "image_wezterm",
            },
          },
        filesystem = {
          follow_current_file = { enabled = true }, -- Automatically focus active file in tree
          filtered_items = {
            hide_dotfiles = false, -- Show hidden files like .zshrc or .gitignore
          },
        },
        commands = {
          image_wezterm = function(state)
            local node = state.tree:get_node()
            if node.type == "file" then
              require("image_preview").PreviewImage(node.path)
            end
          end,
        },
      })
    end
  }
  
  -- Supermaven
  use {
    'supermaven-inc/supermaven-nvim',
    config = function()
      require('supermaven-nvim').setup({
        keymaps = {
          accept_suggestion = "<Tab>",      -- accept full suggestion
          clear_suggestion = "<C-]>",       -- dismiss
          accept_word = "<C-j>",            -- accept one word at a time
        },
      })
    end
  }
-- Avante
  use {
    'yetone/avante.nvim',
    run = 'make',
    requires = {
      'nvim-treesitter/nvim-treesitter',
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
      --- OPTIONAL: Add support for pulling in code context from current files
      { 'hrsh7th/nvim-cmp', optional = true }, 
    },
    config = function()
      require('avante').setup({
        --- Tell Avante to use openrouter as the primary engine
        provider = "or20b",
        providers = {
          -- OpenRouter: GPT-OSS 20B (free)
          or20b = {
            __inherited_from = "openai",
            endpoint = "https://openrouter.ai/api/v1",
            model = "openai/gpt-oss-20b:free",
            api_key_name = "OPENROUTER_API_KEY",
          },

          -- OpenRouter: GPT-OSS 120B (free)
          or120b = {
            __inherited_from = "openai",
            endpoint = "https://openrouter.ai/api/v1",
            model = "openai/gpt-oss-120b:free",
            api_key_name = "OPENROUTER_API_KEY",
          },

          -- Ollama: local Qwen2.5 Coder 7B
          ollama = {
            __inherited_from = "openai",
            endpoint = "http://127.0.0.1:11434/v1",
            model = "qwen2.5-coder:7b",
            api_key_name = "",  -- Ollama doesn't need a key
          },
        },
      })
    end
  }
end)

--{{ Key mappings
local map = vim.keymap.set

map('n', '<A-w>', ':w<CR>') -- :w, :q
map('n', '<A-W>', ':wall<CR>')
map('i', '<A-w>', '<Esc>:w<CR>')
map('i', '<A-W>', '<Esc>:wall<CR>')
map('n', '<A-o>', ':only<CR>', { silent = true })
map('n', '<A-c>', '"+y', { noremap = true, silent = false })
map('v', '<A-c>', '"+y', { noremap = true, silent = false })
map('t', '<A-c>', '"+y', { noremap = true, silent = false })
map('n', '<A-n>', ':Neotree toggle left<CR>', { silent = true })

map("n", "<A-l>", ":bnext<CR>", { silent = true })
map("n", "<A-h>", ":bprev<CR>", { silent = true })

-- Folding
map('n', '<A-z>', 'za', { silent = true }) -- Toggle current fold
map('n', '<A-Z>', 'zR', { silent = true }) -- Open all folds

-- Split window width
map('n', '<A-.>', '<C-w>>', { noremap = true, silent = true })
map('n', '<A-,>', '<C-w><', { noremap = true, silent = true })
map('n', '<A-=>', '<C-w>+', { noremap = true, silent = true })
map('n', '<A-->', '<C-w>-', { noremap = true, silent = true })
map('n', '<Leader>=', '<C-w>=', { noremap = true, silent = true })


-- Future-proof smart close function for Alt + q
local function smart_close()
  local bufnr = vim.api.nvim_get_current_buf()
  local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

  -- 1. Get a count of active user-visible file and utility buffers
  local open_buffers = vim.fn.getbufinfo({ buflisted = 1 })

  -- 2. HARD GUARD: If this is the absolute last window open, close out gracefully
  if #open_buffers <= 1 then
    vim.cmd("q")
    return
  end

  -- 3. TERMINAL HANDLING: If it's a terminal split, wipe it completely from memory
  if buftype == "terminal" then
    vim.cmd("bdelete!") -- Kills both the running process and the window split instantly
    return
  end

  -- 4. SIDEBARS / PANELS: UI components get a standard window close
  local panel_filetypes = { ["neo-tree"] = true, ["avante"] = true, ["avante-input"] = true }
  if panel_filetypes[filetype] or buftype == "nofile" then
    vim.cmd("q")
    return
  end

  -- 5. CODE BUFFERS: Run safe layout-preserving deletion
  local success = pcall(function()
    vim.cmd("Bdelete")
  end)

  if not success then
    vim.cmd("q")
  end
end

-- Map Alt + q in normal mode
map("n", "<A-q>", smart_close, { silent = true, desc = "Smart close buffer or panel" })
map('n', '<A-Q>', ':qall<CR>')


-- --- Neovim Terminal and Navigation Mappings (Lua Syntax) ---
-- 1. Easily exit terminal mode with Esc
map('t', '<A-Esc>', [[<C-\><C-n>]])

-- 2. Seamlessly navigate between splits using Alt + hjkl
map('t', '<A-j>', [[<C-\><C-n><C-w>j]])
map('t', '<A-k>', [[<C-\><C-n><C-w>k]])

map('n', '<A-j>', '<C-w>w')
map('n', '<A-k>', '<C-w>W')



-- 3. Open terminals quickly (Leader + t / T)
map('n', '<Leader>t', ':vsplit term://zsh<CR>', { silent = true })
map('n', '<A-t>', ':vsplit term://zsh<CR>', { silent = true })
map('n', '<Leader>T', ':split term://zsh<CR>', { silent = true })
map('n', '<A-T>', ':split term://zsh<CR>', { silent = true })
--}}

-- Automatically writes the file and runs it in a vertical split terminal
local runners = {
  python = "python3",
  sh     = "bash",
  bash   = "bash",
  javascript = "node",
  go     = "go run"
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = vim.tbl_keys(runners),
  callback = function(args)
    -- Unified function name: run_code
    local run_code = function()
      local current_file = vim.api.nvim_buf_get_name(0)
      if current_file == "" then
        print("Error: Save the file with a name first!")
        return
      end

      local filetype = vim.bo[args.buf].filetype
      local interpreter = runners[filetype]

      if not interpreter then return end

      vim.cmd('w')
      local lines = math.floor(vim.api.nvim_win_get_height(0) * 0.3)
      
      -- FIXED: Changed 'python3' to use the dynamic 'interpreter' variable
      vim.cmd(lines .. 'new | terminal ' .. interpreter .. ' ' .. vim.fn.shellescape(current_file))
      
    end

    -- FIXED: Swapped 'run_python' references to point to 'run_code'
    -- Normal Mode
    vim.keymap.set('n', '<F5>', run_code, { buffer = true })
    vim.keymap.set('n', '<A-r>', run_code, { buffer = true })

    -- Insert Mode
    vim.keymap.set('i', '<F5>', run_code, { buffer = true })
    vim.keymap.set('i', '<A-r>', run_code, { buffer = true })
  end
})

vim.o.autoread = true

-- Automatically open Neo-tree in new tab pages
vim.api.nvim_create_autocmd("TabNewEntered", {
  pattern = "*",
  callback = function()
    vim.cmd("Neotree show left")
  end,
})

-- Save and restore folds
vim.api.nvim_create_autocmd("BufWinLeave", {
  pattern = "*",
  command = "silent! mkview"
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "*",
  command = "silent! loadview"
})
