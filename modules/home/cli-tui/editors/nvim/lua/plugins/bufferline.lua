return {
	"akinsho/bufferline.nvim",
    lazy = true,
    dependencies = {
        "nvim-tree/nvim-web-devicons"
    },
    opts = {
        
    },
    keys = {
        {"<leader>bh", ":BufferLineCyclePrev<CR>", silent = true },
        {"<leader>bl", ":BufferLineCycleNext<CR>", silent = true },
        {"<leader>bp", ":BufferLinePick<CR>", silent = true },
        {"<leader>bd", ":bdelete<CR>", silent = true },

    },
}
