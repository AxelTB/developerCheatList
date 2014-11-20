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
local cheatTable = require("cheatCode.cheatTable")

local module = {}
capi ={client=client}


-- Create a cheatCode widget
--          basePath = absolute path to cheatCodes tree
local function new(basePath)
    local glob = nil
    local widget = nil
    local idle = nil
    local layouts = {}

    local cheatsPath= basePath or os.getenv("HOME")..'/cheatCodes/'

    function searchClientCheats()
        local cheatList={}
        cheatList['foo']={path='../.cheatCode'}
        --Scan clients
        for i,c in ipairs(capi.client.get()) do
            print("Client",c.name)
            --Confront with cheatTable
            for name,obj in pairs(cheatTable) do
                --print(name,":",obj.pathName)
                for ii,pattern in pairs(obj.pattern) do
                    --print("P:",pattern)
                    --If pattern found
                    if string.match(c.name,pattern) then
                        cheatList[name]=obj
                        print("Load",c.name,":",pattern,"@",obj.l)
                    end
                end
            end
        end
        return cheatList
    end

    function show(geometry)
        print("Show")
        if glob == nil then
            glob = radical.context()
            glob.parent_geometry = geometry
            local cheatList = searchClientCheats()
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
                                                                        util.spawn("xdg-open "..link)
                                                                    end}))
                                                    end
                                                    return linkMenu
                                                end}))
                                else
                                    print("No link for",name)
                                end
                                -- Local files
                                local lsDir=io.popen('ls '..cheatsPath..cheat.path)
                                for line in lsDir:lines() do
                                    parent:add_item(util.table.join({text=line,button1= function()
                                                    util.spawn("xdg-open "..cheatsPath..cheat.path.."/"..line)
                                                end}))
                                end
                                lsDir:close()

                                return parent
                            end})

                end
            else
                print("ERR@cheatCode: Unable to load cheat")
            end


        end


        if geometry then
            glob.parent_geometry = geometry
        end
        glob.visible = not glob.visible
        --Destroy menu when closed
        if not glob.visible then glob = nil end
    end

    --Constructor operations-----------------------------------------------------------------------------------------

    if not widget then
        widget = wibox.widget.imagebox()
    else
        print("WTF???")
    end
    widget.fit = function(self,w,h) return h,h end

    widget:buttons( util.table.join(
            button({ }, 3, function(geometry) show(geometry)  end))
    )

    widget:set_image(util.getdir("config").."/data/flags-24x24/ag.png")

    return widget
end


return setmetatable(module, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;
