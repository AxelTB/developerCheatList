local module = {
    table = {
        ["LUA"] = {
            sticky  = true,
            path    = "lua",
            icon    = "",
            pattern = { "%.lua "},
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
            path    = "bash",
            icon        = "",
            pattern       = { "bash","%.sh " },
            links   = {"aaa"},
        },
        ["Javascript"] = {
            sticky      = false,
            path    = "javascript",
            icon        = "",
            pattern       = { "%.js " },
            links   = {"aaa"},
        },
        ["C++"] = {
            sticky      = false,
            path    = "cpp",
            icon        = "",
            pattern       = { "%.cpp " },
            links   = {"aaa"},
        },
        ["C"] = {
            sticky      = false,
            path    = "c",
            icon        = "",
            pattern       = { "%.c ","%.h " },
            links   = {"aaa"},
        },
    }
}
--String: string to search in
--excludeSticky: exclude sticky item into search
module.search =function (string,excludeSticky)
    for name,obj in pairs(module.table) do
        for ii,pattern in pairs(obj.pattern) do
            -- Check for sticky
            if not excludeSticky or not obj.sticky then
                --If patterns found
                if string.match(string,pattern) then
                    --Search hit
                    return name,obj
                end
            end
        end
    end
    --Search miss
    return nil,nil
end

module.getSticky = function()
    local stickyCheats = {}
    for name,obj in pairs(module.table) do
        --Save sticky cheats
        if obj.sticky then
            stickyCheats[name]=obj
        end
    end

    return stickyCheats
end
return module