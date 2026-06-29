-- lua/plugins/theme.lua
return {
  -- Install gruvbox
  { 
    "ellisonleao/gruvbox.nvim", 
    priority = 1000, -- Make sure it loads before other plugins
    config = true 
  },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}