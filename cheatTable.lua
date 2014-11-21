--local cheatPath = os.getenv("HOME").."/cheatCodes";
local module = {
    table = {
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
            pattern       = { "vim" },
            links   = {"aaa"},
        },
        ["Bash"] = {
            sticky      = false,
            path    = "vim",
            icon        = "",
            pattern       = { "bash" },
            links   = {"aaa"},
        },
    }
}
module.search =function (string)
    for name,obj in pairs(module.table) do
        for ii,pattern in pairs(obj.pattern) do
            --If patterns found
            if string.match(string,pattern) then
                print("Load",string,":",name)
                --Search hit
                return name,obj
            end
        end
    end
    --Search miss
    return nil,nil
end

return module