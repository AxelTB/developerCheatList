--local cheatPath = os.getenv("HOME").."/cheatCodes";

return {
    ["LUA"] = {
        sticky      = false,
        path    = "lua",
        icon        = "",
        pattern       = { "%a%.lua" , "lua" },

    },
    ["Vim"] = {
        sticky      = false,
        path    = "vim",
        icon        = "",
        pattern       = { "vim" , " vim " },
    }
}