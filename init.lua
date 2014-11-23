local print = print
--local io,table = io,table
local setmetatable  = setmetatable
local string,ipairs = string,ipairs
local wibox        = require("wibox"          )
--local cairo        = require("lgi"            ).cairo
--local color        = require("gears.color"    )
local button       = require( "awful.button"  )
local fd_async     = require("utils.fd_async" )
local util         = require("awful.util"     )
local radical      = require("radical"        )
--local beautiful    = require("beautiful"      )
--local surface      = require("gears.surface"  )
--local glib         = require("lgi").GLib
--local filetree     = require("customMenu.filetree")
local cheatTable = require("devCheats.cheatTable")

local module = {}
capi ={client=client,timer=timer}


-- Create a cheatCode widget
--          basePath = absolute path to cheatCodes tree
local function new(basePath)

    local glob = nil
    local widget = nil

    local focusedCheat = nil
    local focusUpdateTimer = capi.timer({ timeout = 2 })
    focusUpdateTimer:connect_signal("timeout", function()
            findPrincipalCheat()
            updateWidgetIcon()
        end)
    focusUpdateTimer:start()

    local cheatsPath= basePath or os.getenv("HOME")..'/cheatCodes/'

    function spawnAndClose(command)
        if command ~= nil then
            util.spawn(command)
            show();
        end
    end

    function searchCheats()
        local cheatList={}
        --Scan clients
        for i,c in ipairs(capi.client.get()) do
            local name,obj

            --print(name,":",obj.pathName)
            name,obj = cheatTable.search(c.name)
            --If something found
            if name ~= nil and obj ~= nil then
                cheatList[name]=obj
            end
        end

        print("User:", os.getenv("USER"))
        --Load All process owned by current user
        local pipe=io.popen("ps -au "..os.getenv("USER").." | awk '{print $4}'")
        for line in pipe:lines() do
            print(line)
            local name,obj
            --print(name,":",obj.pathName)
            name,obj = cheatTable.search(line)
            --If something found
            if name ~= nil and obj ~= nil then
                cheatList[name]=obj
            end
        end
        pipe:close()

        return cheatList
    end

    function show(geometry)

        if not glob then
            glob = radical.context()
            glob.parent_geometry = geometry
            local cheatList = searchCheats()
            --Show cheat Lists
            if cheatList ~= nil then 
                for name, cheat in pairs(cheatList) do
                    glob:add_item({text=name, sub_menu = function() 
                                local parent = radical.context()
                                -- Web links
                                if cheat.links then
                                    parent:add_item(util.table.join({text="Links",sub_menu= function()
                                                    local linkMenu = radical.context()
                                                    for j,link in pairs(cheat.links) do
                                                        linkMenu:add_item(util.table.join({text=link, button1= function()
                                                                        spawnAndClose("xdg-open "..link)
                                                                    end}))
                                                    end
                                                    return linkMenu
                                                end}))
                                end
                                -- Local files
                                local lsDir=io.popen('ls '..cheatsPath..cheat.path)
                                for line in lsDir:lines() do
                                    parent:add_item(util.table.join({text=line,button1= function()
                                                    spawnAndClose("xdg-open "..cheatsPath..cheat.path.."/"..line)
                                                end}))
                                end
                                lsDir:close()

                                return parent
                            end})
                end
            else
                print("ERR@cheatCode: Unable to load cheat")
            end

            if geometry then
                glob.parent_geometry = geometry
            end
            --Show
            glob.visible = true
        else
            -- Hide
            glob.visible = false
            glob = nil
            --Destroy menu when closed
        end
    end

    -- Fast cheatsheet functions
    function findPrincipalCheat()
        -- Search cheat for focused client
        if client.focus ~= nil then
            local name,obj = cheatTable.search(client.focus.name)
            print("Focused:",name)

            --Save focused cheat
            focusedCheat = obj

            --Set update when client focus lost
            --client.focus:connect_signal('unfocus',findPrincipalCheat)
            return obj
        else
            print("No focus")
        end
    end
    function updateWidgetIcon()
        local fullPath = cheatsPath..focusedCheat.path.."/icon.png"
        if util.file_readable(fullPath) then
            widget:set_image(fullPath)
        else
            widget:set_image(util.getdir("config").."/data/flags-24x24/ag.png")
        end
    end
    function showCheatSheet()
        -- Local files
        local lsDir=io.popen('ls '..cheatsPath..focusedCheat.path..'| grep cheatsheet')
        local buffer=lsDir:read("*all")
        print("Found cheat sheet:",buffer)
        lsDir:close()
    end
    --Constructor operations-----------------------------------------------------------------------------------------

    if not widget then
        widget = wibox.widget.imagebox()
    else
        print("WTF???")
    end
    widget.fit = function(self,w,h) return h,h end

    widget:buttons( util.table.join(
            button({ }, 1, showCheatSheet),
            button({ }, 3, function(geometry) show(geometry)  end)
        )
    )

    widget:set_image(util.getdir("config").."/data/flags-24x24/ag.png")

    return widget
end


return setmetatable(module, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;
