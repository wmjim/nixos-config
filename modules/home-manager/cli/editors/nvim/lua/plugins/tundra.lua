return {
    "sam4llis/nvim-tundra",
    -- 关闭懒加载，启动时立即加载
    lazy = false,
    priority = 1000,
    init = function()
        -- arctic-冷色调，jungle-暖色调
        vim.g.tundra_biome = "jungle"
    end,
    opts = {
        transparent_background = false,
    },
    config = function (_, opts)
        require("nvim-tundra").setup(opts)
        vim.cmd("colorscheme tundra")
    end 
}
