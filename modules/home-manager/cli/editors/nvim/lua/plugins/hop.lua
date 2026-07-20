return {
    "smoka7/hop.nvim",
    opts = {
        -- 指定高亮字符出现位置
        hint_position = 3,
    },
    keys = {
        { "<leader>hp", ":HopWord<CR>", silent = true }
    }
}
