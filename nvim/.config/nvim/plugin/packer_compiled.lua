-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/redbeancola/.cache/nvim/packer_hererocks/2.1.1774896198/share/lua/5.1/?.lua;/home/redbeancola/.cache/nvim/packer_hererocks/2.1.1774896198/share/lua/5.1/?/init.lua;/home/redbeancola/.cache/nvim/packer_hererocks/2.1.1774896198/lib/luarocks/rocks-5.1/?.lua;/home/redbeancola/.cache/nvim/packer_hererocks/2.1.1774896198/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/redbeancola/.cache/nvim/packer_hererocks/2.1.1774896198/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["avante.nvim"] = {
    config = { "\27LJ\2\n\4\0\0\5\0\f\0\0156\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\5\0005\4\4\0=\4\6\0035\4\a\0=\4\b\0035\4\t\0=\4\n\3=\3\v\2B\0\2\1K\0\1\0\14providers\vollama\1\0\4\21__inherited_from\vopenai\nmodel\21qwen2.5-coder:7b\rendpoint\30http://127.0.0.1:11434/v1\17api_key_name\5\vor120b\1\0\4\21__inherited_from\vopenai\nmodel\29openai/gpt-oss-120b:free\rendpoint!https://openrouter.ai/api/v1\17api_key_name\23OPENROUTER_API_KEY\nor20b\1\0\3\vor120b\0\vollama\0\nor20b\0\1\0\4\21__inherited_from\vopenai\nmodel\28openai/gpt-oss-20b:free\rendpoint!https://openrouter.ai/api/v1\17api_key_name\23OPENROUTER_API_KEY\1\0\2\rprovider\nor20b\14providers\0\nsetup\vavante\frequire\0" },
    loaded = true,
    path = "/home/redbeancola/.local/share/nvim/site/pack/packer/start/avante.nvim",
    url = "https://github.com/yetone/avante.nvim"
  },
  ["bufdelete.nvim"] = {
    loaded = true,
    path = "/home/redbeancola/.local/share/nvim/site/pack/packer/start/bufdelete.nvim",
    url = "https://github.com/famiu/bufdelete.nvim"
  },
  ["bufferline.nvim"] = {
    config = { "\27LJ\2\n£\2\0\0\6\0\b\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\3\0004\4\3\0005\5\4\0>\5\1\4=\4\5\3=\3\a\2B\0\2\1K\0\1\0\foptions\1\0\1\foptions\0\foffsets\1\0\4\rfiletype\rneo-tree\15text_align\tleft\14separator\2\ttext\18File Explorer\1\0\5\foffsets\0\28show_buffer_close_icons\1\20show_close_icon\1\24right_mouse_command\16Bdelete! %d\18close_command\16Bdelete! %d\nsetup\15bufferline\frequire\0" },
    loaded = true,
    path = "/home/redbeancola/.local/share/nvim/site/pack/packer/start/bufferline.nvim",
    url = "https://github.com/akinsho/bufferline.nvim"
  },
  catppuccin = {
    loaded = true,
    path = "/home/redbeancola/.local/share/nvim/site/pack/packer/start/catppuccin",
    url = "https://github.com/catppuccin/nvim"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/home/redbeancola/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  ["dressing.nvim"] = {
    loaded = true,
    path = "/home/redbeancola/.local/share/nvim/site/pack/packer/start/dressing.nvim",
    url = "https://github.com/stevearc/dressing.nvim"
  },
  ["image.nvim"] = {
    config = { "\27LJ\2\nÄ\1\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\2B\0\2\1K\0\1\0\25hijack_file_patterns\1\a\0\0\n*.png\n*.jpg\v*.jpeg\n*.gif\v*.webp\n*.svg\1\0\3!max_height_window_percentage\0032\fbackend\nkitty\25hijack_file_patterns\0\nsetup\nimage\frequire\0" },
    loaded = true,
    path = "/home/redbeancola/.local/share/nvim/site/pack/packer/start/image.nvim",
    url = "https://github.com/3rd/image.nvim"
  },
  ["image_preview.nvim"] = {
    config = { "\27LJ\2\n;\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\18image_preview\frequire\0" },
    loaded = true,
    path = "/home/redbeancola/.local/share/nvim/site/pack/packer/start/image_preview.nvim",
    url = "https://github.com/adelarsq/image_preview.nvim"
  },
  ["lualine.nvim"] = {
    loaded = true,
    path = "/home/redbeancola/.local/share/nvim/site/pack/packer/start/lualine.nvim",
    url = "https://github.com/hoob3rt/lualine.nvim"
  },
  ["neo-tree.nvim"] = {
    config = { "\27LJ\2\n\127\0\1\5\0\b\0\0149\1\0\0\18\3\1\0009\1\1\1B\1\2\0029\2\2\1\a\2\3\0X\2\6€6\2\4\0'\4\5\0B\2\2\0029\2\6\0029\4\a\1B\2\2\1K\0\1\0\tpath\17PreviewImage\18image_preview\frequire\tfile\ttype\rget_node\ttreeŽ\3\1\0\5\0\18\0\0216\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0005\4\5\0=\4\6\3=\3\a\0025\3\t\0005\4\b\0=\4\n\0035\4\v\0=\4\f\3=\3\r\0025\3\15\0003\4\14\0=\4\16\3=\3\17\2B\0\2\1K\0\1\0\rcommands\18image_wezterm\1\0\1\18image_wezterm\0\0\15filesystem\19filtered_items\1\0\1\18hide_dotfiles\1\24follow_current_file\1\0\2\24follow_current_file\0\19filtered_items\0\1\0\1\fenabled\2\vwindow\rmappings\1\0\2\6l\tedit\14<leader>p\18image_wezterm\1\0\2\rmappings\0\nwidth\3\30\1\0\4\rcommands\0\vwindow\0\25close_if_last_window\2\15filesystem\0\nsetup\rneo-tree\frequire\0" },
    loaded = true,
    path = "/home/redbeancola/.local/share/nvim/site/pack/packer/start/neo-tree.nvim",
    url = "https://github.com/nvim-neo-tree/neo-tree.nvim"
  },
  ["nui.nvim"] = {
    loaded = true,
    path = "/home/redbeancola/.local/share/nvim/site/pack/packer/start/nui.nvim",
    url = "https://github.com/MunifTanjim/nui.nvim"
  },
  ["nvim-cmp"] = {
    loaded = true,
    path = "/home/redbeancola/.local/share/nvim/site/pack/packer/start/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-colorizer.lua"] = {
    loaded = true,
    path = "/home/redbeancola/.local/share/nvim/site/pack/packer/start/nvim-colorizer.lua",
    url = "https://github.com/norcalli/nvim-colorizer.lua"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/home/redbeancola/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/home/redbeancola/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/home/redbeancola/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/nvim-tree/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/redbeancola/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/redbeancola/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["supermaven-nvim"] = {
    config = { "\27LJ\2\n¡\1\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\1K\0\1\0\fkeymaps\1\0\1\fkeymaps\0\1\0\3\22accept_suggestion\n<Tab>\16accept_word\n<C-j>\21clear_suggestion\n<C-]>\nsetup\20supermaven-nvim\frequire\0" },
    loaded = true,
    path = "/home/redbeancola/.local/share/nvim/site/pack/packer/start/supermaven-nvim",
    url = "https://github.com/supermaven-inc/supermaven-nvim"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/home/redbeancola/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["vim-fugitive"] = {
    loaded = true,
    path = "/home/redbeancola/.local/share/nvim/site/pack/packer/start/vim-fugitive",
    url = "https://github.com/tpope/vim-fugitive"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: supermaven-nvim
time([[Config for supermaven-nvim]], true)
try_loadstring("\27LJ\2\n¡\1\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\1K\0\1\0\fkeymaps\1\0\1\fkeymaps\0\1\0\3\22accept_suggestion\n<Tab>\16accept_word\n<C-j>\21clear_suggestion\n<C-]>\nsetup\20supermaven-nvim\frequire\0", "config", "supermaven-nvim")
time([[Config for supermaven-nvim]], false)
-- Config for: neo-tree.nvim
time([[Config for neo-tree.nvim]], true)
try_loadstring("\27LJ\2\n\127\0\1\5\0\b\0\0149\1\0\0\18\3\1\0009\1\1\1B\1\2\0029\2\2\1\a\2\3\0X\2\6€6\2\4\0'\4\5\0B\2\2\0029\2\6\0029\4\a\1B\2\2\1K\0\1\0\tpath\17PreviewImage\18image_preview\frequire\tfile\ttype\rget_node\ttreeŽ\3\1\0\5\0\18\0\0216\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0005\4\5\0=\4\6\3=\3\a\0025\3\t\0005\4\b\0=\4\n\0035\4\v\0=\4\f\3=\3\r\0025\3\15\0003\4\14\0=\4\16\3=\3\17\2B\0\2\1K\0\1\0\rcommands\18image_wezterm\1\0\1\18image_wezterm\0\0\15filesystem\19filtered_items\1\0\1\18hide_dotfiles\1\24follow_current_file\1\0\2\24follow_current_file\0\19filtered_items\0\1\0\1\fenabled\2\vwindow\rmappings\1\0\2\6l\tedit\14<leader>p\18image_wezterm\1\0\2\rmappings\0\nwidth\3\30\1\0\4\rcommands\0\vwindow\0\25close_if_last_window\2\15filesystem\0\nsetup\rneo-tree\frequire\0", "config", "neo-tree.nvim")
time([[Config for neo-tree.nvim]], false)
-- Config for: image_preview.nvim
time([[Config for image_preview.nvim]], true)
try_loadstring("\27LJ\2\n;\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\18image_preview\frequire\0", "config", "image_preview.nvim")
time([[Config for image_preview.nvim]], false)
-- Config for: avante.nvim
time([[Config for avante.nvim]], true)
try_loadstring("\27LJ\2\n\4\0\0\5\0\f\0\0156\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\5\0005\4\4\0=\4\6\0035\4\a\0=\4\b\0035\4\t\0=\4\n\3=\3\v\2B\0\2\1K\0\1\0\14providers\vollama\1\0\4\21__inherited_from\vopenai\nmodel\21qwen2.5-coder:7b\rendpoint\30http://127.0.0.1:11434/v1\17api_key_name\5\vor120b\1\0\4\21__inherited_from\vopenai\nmodel\29openai/gpt-oss-120b:free\rendpoint!https://openrouter.ai/api/v1\17api_key_name\23OPENROUTER_API_KEY\nor20b\1\0\3\vor120b\0\vollama\0\nor20b\0\1\0\4\21__inherited_from\vopenai\nmodel\28openai/gpt-oss-20b:free\rendpoint!https://openrouter.ai/api/v1\17api_key_name\23OPENROUTER_API_KEY\1\0\2\rprovider\nor20b\14providers\0\nsetup\vavante\frequire\0", "config", "avante.nvim")
time([[Config for avante.nvim]], false)
-- Config for: bufferline.nvim
time([[Config for bufferline.nvim]], true)
try_loadstring("\27LJ\2\n£\2\0\0\6\0\b\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\3\0004\4\3\0005\5\4\0>\5\1\4=\4\5\3=\3\a\2B\0\2\1K\0\1\0\foptions\1\0\1\foptions\0\foffsets\1\0\4\rfiletype\rneo-tree\15text_align\tleft\14separator\2\ttext\18File Explorer\1\0\5\foffsets\0\28show_buffer_close_icons\1\20show_close_icon\1\24right_mouse_command\16Bdelete! %d\18close_command\16Bdelete! %d\nsetup\15bufferline\frequire\0", "config", "bufferline.nvim")
time([[Config for bufferline.nvim]], false)
-- Config for: image.nvim
time([[Config for image.nvim]], true)
try_loadstring("\27LJ\2\nÄ\1\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\2B\0\2\1K\0\1\0\25hijack_file_patterns\1\a\0\0\n*.png\n*.jpg\v*.jpeg\n*.gif\v*.webp\n*.svg\1\0\3!max_height_window_percentage\0032\fbackend\nkitty\25hijack_file_patterns\0\nsetup\nimage\frequire\0", "config", "image.nvim")
time([[Config for image.nvim]], false)

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
