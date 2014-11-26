local wibox        = require("wibox"          )
local button       = require( "awful.button"  )
local fd_async     = require("utils.fd_async" )
local util         = require("awful.util"     )
local radical      = require("radical"        )
local cheatTable = require("devCheats.cheatTable")

local moduleCheat = {}
capi ={client=client,timer=timer}


-- Create a cheatCode widget
-- args = {
--          basePath    Absolute path to cheatCodes tree
--          cheatCmd    Cheatsheet command
--          refCmd      Reference command
--          linkCmd     Link Command
--          updateT     Seconds between focused client update
--      }
local function new(args)

    --Global menu and widget
    local globMenu,widget = nil,nil

    --Focused Cheat Variables
    local focusedCheat,focusUpdateTimer = nil,nil
    
    local basePath,cheatCmd,refCmd,linkCmd = nil,nil,nil,nil
    
    --Sticky cheats
    local stickyCheats=cheatTable.getSticky()
    
    -- Parse args:-------------------------------------------------------------------
    if args ~= nil then
        basePath=args.basePath
        cheatCmd=args.cheatCmd
        refCmd=args.refCmd
        linkCmd=args.linkCmd
        if args.updateT then focusUpdateTimer = capi.timer({ timeout = args.updateT }) end
    end
    --Set default on nil variables
    basePath = basePath or os.getenv("HOME")..'/cheatCodes/'
    cheatCmd = (cheatCmd or "xdg-open").." "
    refCmd = (refCmd or "xdg-open").." "
    linkCmd = (linkCmd or "xdg-open").." "
    focusUpdateTimer = focusUpdateTimer or capi.timer({ timeout = 2 })
    
    --Set update timer functions------------------------------------------------------
    focusUpdateTimer:connect_signal("timeout", function()
            findPrincipalCheat()
            updateWidgetIcon()
        end)
    focusUpdateTimer:start()

    
--Spawn cmd and close menu
    function spawnAndClose(command)
        if command ~= nil then
            util.spawn(command)
            toggle();
        end
    end

--Search cheat for open client and running process and returns a list of them
    function searchCheats()
        local cheatList={}
        --Scan clients
        for i,c in ipairs(capi.client.get()) do
            local name,obj

            --print(name,":",obj.pathName)
            name,obj = cheatTable.search(c.name,true)
            --If something found
            if name ~= nil and obj ~= nil then
                cheatList[name]=obj
            end
        end

        --Load All process owned by current user
        local pipe=io.popen("ps -au "..os.getenv("USER").." | awk '{print $4}'")
        for line in pipe:lines() do
            --print(line)
            local name,obj
            --print(name,":",obj.pathName)
            name,obj = cheatTable.search(line,true)
            --If something found
            if name ~= nil and obj ~= nil then
                cheatList[name]=obj
            end
        end
        pipe:close()

        return cheatList
    end

    function toggle(geometry)

        if not globMenu then
            globMenu = radical.context()
            globMenu.parent_geometry = geometry
            local cheatList = searchCheats()
            --Show cheat Lists
            if cheatList ~= nil then 
                --Add cheat for active software
                for name, cheat in pairs(cheatList) do
                    globMenu:add_item({text=name, sub_menu = function() 
                                local parent = radical.context()
                                -- Web links
                                if cheat.links then
                                    parent:add_item(util.table.join({text="Links",sub_menu= function()
                                                    local linkMenu = radical.context()
                                                    for j,link in pairs(cheat.links) do
                                                        linkMenu:add_item(util.table.join({text=link, button1= function()
                                                                        spawnAndClose(linkCmd..link)
                                                                    end}))
                                                    end
                                                    return linkMenu
                                                end}))
                                end
                                -- Local files
                                local lsDir=io.popen('ls '..basePath..cheat.path)
                                for line in lsDir:lines() do
                                    parent:add_item(util.table.join({text=line,button1= function()
                                                    --Spawn Reference
                                                    spawnAndClose(refCmd..basePath..cheat.path.."/"..line)
                                                end}))
                                end
                                lsDir:close()

                                return parent
                            end})
                end
                --AXTODO: Maybe a separator?
                --Add sticky cheats
                for name, cheat in pairs(stickyCheats) do
                    globMenu:add_item({text=name, sub_menu = function() 
                                local parent = radical.context()
                                -- Web links
                                if cheat.links then
                                    parent:add_item(util.table.join({text="Links",sub_menu= function()
                                                    local linkMenu = radical.context()
                                                    for j,link in pairs(cheat.links) do
                                                        linkMenu:add_item(util.table.join({text=link, button1= function()
                                                                        spawnAndClose(linkCmd..link)
                                                                    end}))
                                                    end
                                                    return linkMenu
                                                end}))
                                end
                                -- Local files
                                local lsDir=io.popen('ls '..basePath..cheat.path)
                                for line in lsDir:lines() do
                                    parent:add_item(util.table.join({text=line,button1= function()
                                                    --Spawn Reference
                                                    spawnAndClose(refCmd..basePath..cheat.path.."/"..line)
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
                globMenu.parent_geometry = geometry
            end
            --Show
            globMenu.visible = true
        else
            -- Hide
            globMenu.visible = false
            globMenu = nil
            --Destroy menu when closed
        end
    end

    -- Fast cheatsheet functions------------------------------------------------------
    function findPrincipalCheat()
        -- Search cheat for focused client
        if client.focus ~= nil then
            local name,obj = cheatTable.search(client.focus.name)

            --Save focused cheat
            focusedCheat = obj

            return obj
        else
            print("No focus")
        end
    end
    function updateWidgetIcon()
        local fullPath = basePath..focusedCheat.path.."/icon.png"
        if util.file_readable(fullPath) then
            widget:set_image(fullPath)
        else
            widget:set_image(util.getdir("config").."/data/flags-24x24/ag.png")
        end
    end
    function showCheatSheet()
        -- Local files
        local lsDir=io.popen('ls '..basePath..focusedCheat.path..'| grep cheatsheet')
        local buffer=lsDir:read("*all")

        --Spawn CheatSheet
        if #buffer > 5 then
            util.spawn(cheatCmd..basePath..focusedCheat.path.."/"..buffer)
        end
        lsDir:close()
    end
    --Constructor operations-----------------------------------------------------------------------------------------
    

    --Create widget
    if not widget then
        widget = wibox.widget.imagebox()
    else
        print("WTF???")
    end
    widget.fit = function(self,w,h) return h,h end

    widget:buttons( util.table.join(
            button({ }, 1, showCheatSheet),
            button({ }, 3, function(geometry) toggle(geometry)  end)
        )
    )

    --Set default image
    widget:set_image(util.getdir("config").."/data/flags-24x24/ag.png")

    return widget
end


return setmetatable(moduleCheat, { __call = function(_, ...) return new(...) end })
