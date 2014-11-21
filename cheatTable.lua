--local cheatPath = os.getenv("HOME").."/cheatCodes";

return {
    ["LUA"] = {
        sticky  = false,
        path    = "lua",
        icon    = "",
        pattern = { "%a%.lua"},
        links   = {"http://www.lua.org/manual/5.2/"},

    },
    ["Vim"] = {
        sticky      = false,
        path    = "vim",
        icon        = "",
        pattern       = { " vim " },
        links   = {"aaa"},
    }
}