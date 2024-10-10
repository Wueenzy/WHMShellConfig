local utils = require('whoami.utils')
return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function() 
        if utils.appearance() == 'light' then
            vim.cmd('colorscheme catppuccin-latte')
        end
    end
}
