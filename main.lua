-- This addon lets you inspect WoW interface frames.
-- This is the file for addon main frame and globals


--[[ 
    **************************************************
    * SECTION: for me

    TODO
    NOTE

    **************************************************
--]]

InterfaceInspector = InterfaceInspector or {
    frames={}, functions={},
    topmostFrame = nil,             -- This global is for saving which frame displays on top
}

--[[ 
    **************************************************
    * SECTION: mainFrame
    **************************************************
--]]


InterfaceInspector.frames.mainFrame = CreateFrame("Frame", "InterfaceInspector", UIParent, "BasicFrameTemplateWithInset")
InterfaceInspector.frames.mainFrame:SetSize(100, 120)
InterfaceInspector.frames.mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
InterfaceInspector.frames.mainFrame.TitleBg:SetHeight(30)
InterfaceInspector.frames.mainFrame.title = InterfaceInspector.frames.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
InterfaceInspector.frames.mainFrame.title:SetPoint("TOP", InterfaceInspector.frames.mainFrame.TitleBg, "CENTER", 0, 10)
InterfaceInspector.frames.mainFrame.title:SetText("IInspector")
-- InterfaceInspector.frames.mainFrame:SetClipsChildren(true) -- Prevents rendering outside the frame
InterfaceInspector.frames.mainFrame:Hide() -- Frame is hidden by default
-- Making frame movable
InterfaceInspector.frames.mainFrame:EnableMouse(true)
InterfaceInspector.frames.mainFrame:SetMovable(true)
InterfaceInspector.frames.mainFrame:RegisterForDrag("LeftButton")
InterfaceInspector.frames.mainFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
InterfaceInspector.frames.mainFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)


-- Adding frame to WoW special list to make it closeable by Esc
table.insert(UISpecialFrames, "InterfaceInspector")


-- Making addon recognize slash commands.
SLASH_INTERFACEINSPECTOR1 = "/ii"

SlashCmdList["INTERFACEINSPECTOR"] = function(msg)
    if msg == "" then
        if InterfaceInspector.frames.mainFrame:IsShown() then
            InterfaceInspector.frames.mainFrame:Hide()
        else
            InterfaceInspector.frames.mainFrame:Show()
        end
    elseif msg == "settings" then
        -- If the 'settings' argument is provided, open the settings
        SlashCmdList["MYADDONSETTINGS"]()
    else
        -- If invalid argument is provided
        print("Invalid command usage.")
    end
end

--[[ 
    **************************************************
    * SECTION: Contents of mainFrame
    **************************************************
--]]

local iconFrame = CreateFrame("Frame", "iconFrame", InterfaceInspector.frames.mainFrame, "BackdropTemplate") -- Frame to show item icon
iconFrame:SetSize(64, 64)  -- Width, Height
iconFrame:SetPoint("CENTER", InterfaceInspector.frames.mainFrame, "CENTER", 0, -10)  -- Position on the screen
iconFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
iconFrame:SetBackdropColor(0, 0, 0, 1)  -- Black background

local iconTexture = iconFrame:CreateTexture(nil, "ARTWORK")-- Item icon texture
iconTexture:SetSize(40, 40)  -- Icon size
iconTexture:SetPoint("CENTER", iconFrame, "CENTER")
iconTexture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

local glow = CreateFrame("Frame", "GrindGoals.frames.glow", InterfaceInspector.frames.mainFrame, "GlowBorderTemplate") -- glowing border for item icon 
glow:SetSize(62, 62)  -- Width, Height
glow:SetPoint("CENTER", iconFrame, "CENTER", 0, 0)

local eventListenerFrame = CreateFrame("Frame", "InterfaceInspectorEventListenerFrame", UIParent)

local function eventHandler(self, event, ...)

end
--[[ 
    **************************************************
    * SECTION: Table to string function
    **************************************************
--]]

local function tableToString(tbl, indent)
    if not indent then indent = 0 end
    print("Function working. Table level: " .. indent )
    local result = ""
    local indentStr = string.rep("  ", indent)  -- Create indentation

    if type(tbl) ~= "table" then
        print("ABORT!")
        return tostring(tbl)        
    end

    for key, value in pairs(tbl) do
        local keyStr = tostring(key)
        if type(key) == "string" then
            keyStr = "\"|cff00ff00" .. keyStr .. "|r\""
        end

        if type(value) == "table" then
            print(keyStr .. ": " .. type(value))
            result = result .. indentStr .. keyStr .. " = {\n"
            result = result .. tableToString(value, indent + 1)
            result = result .. indentStr .. "},\n"
        else
            local valueStr = tostring(value)
            print(keyStr .. ": " .. type(value))
            if type(value) == "string" then
                valueStr = "\"" .. valueStr .. "\""
            end
            result = result .. indentStr .. keyStr .. " = " .. valueStr .. ",\n"
        end
    end

    return result
end

--[[ 
    **************************************************
    * SECTION: Create dump frame
    **************************************************
--]]

-- Create a frame for the text box to display the dump
local function CreateDumpFrame()
    -- Create a parent frame
    local frame = CreateFrame("Frame", "DumpFrame", UIParent, "BackdropTemplate")
    frame:SetSize(400, 300)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
    })
    frame:SetBackdropColor(0, 0, 0, 0.8)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Create a scroll frame to allow scrolling if content is large
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(360, 260)
    scrollFrame:SetPoint("TOP", -10, -30)

    -- Create the edit box inside the scroll frame
    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetFontObject(ChatFontNormal)
    editBox:SetSize(360, 800)
    editBox:SetTextInsets(10, 10, 10, 10)
    editBox:SetAutoFocus(false)
    editBox:EnableMouse(true)
    editBox:SetScript("OnEscapePressed", editBox.ClearFocus)  -- Allow closing focus by pressing escape

    scrollFrame:SetScrollChild(editBox)

    -- Create a close button for the frame
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)

    -- Return the frame and editbox so you can set text later
    return frame, editBox
end

-- Create and hide the frame until needed
local dumpFrame, dumpEditBox = CreateDumpFrame()
dumpFrame:Hide()

--[[ 
    **************************************************
    * SECTION: Script on update
    **************************************************
--]]

InterfaceInspector.frames.mainFrame:SetScript("OnUpdate", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    local frame = GetMouseFoci()[1]

    local tooltipText = (
        "|cff00ff00Frame:|r " .. (frame:GetName() or "|cFFFF0000No Name|r") .. "\n" ..
        "|cff00ff00Type:|r " .. (frame:GetObjectType() or "|cFFFF0000No Type|r") .. "\n"
    )

    GameTooltip:AddLine("|cff00ff00Frame:|r " .. (frame:GetName() or "|cFFFF0000No Name|r") .. "\n", 1, 1, 1)
    GameTooltip:AddLine("|cff00ff00Type:|r " .. (frame:GetObjectType() or "|cFFFF0000No Type|r") .. "\n", 1, 1, 1)

    if IsShiftKeyDown() then
        for key, value in pairs(frame) do
            local valueType = type(value)
            if valueType == "string" then
                GameTooltip:AddDoubleLine(key, "\"" .. value .. "\"", 0.8, 0.8, 0.8, 1, 1, 1)
            elseif valueType == "number" or valueType == "boolean" then
                GameTooltip:AddDoubleLine(key, tostring(value), 0.8, 0.8, 0.8, 1, 1, 1)
            elseif valueType == "table" then
                GameTooltip:AddDoubleLine(key, "table", 0.8, 0.8, 0.8, 1, 1, 0)
            elseif valueType == "function" then
                GameTooltip:AddDoubleLine(key, "function", 0.8, 0.8, 0.8, 1, 0.8, 0)
            else
                GameTooltip:AddDoubleLine(key, "unknown", 0.8, 0.8, 0.8, 1, 0, 0)
            end
        end
    end
    
    if IsControlKeyDown() and not dumpFrame:IsShown() then
        --[[ local frameData = tableToString(frame)

        -- Set the text of the edit box
        dumpEditBox:SetText(frameData)
        
        dumpFrame:Show() ]]
        print("/dump(frame)")
    end

    GameTooltip:Show()
end)

InterfaceInspector.frames.mainFrame:SetScript("OnHide", function(self)
    GameTooltip:Hide()
end)