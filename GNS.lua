-- GNS - Goblin Naming System
-- Adds custom naming functionality to the Goblin Brainwashing Device

-- Saved variables
GNS_SpecNames = {}

-- Local variables
local editButtons = {}
local currentPlayerName = nil
local lastSavedSpec = nil

-- Frame for event handling
local GNSFrame = CreateFrame("Frame")
GNSFrame:RegisterEvent("ADDON_LOADED")
GNSFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
GNSFrame:RegisterEvent("GOSSIP_SHOW")
GNSFrame:RegisterEvent("GOSSIP_CLOSED")

-- Initialize saved variables for the current player
local function InitPlayerData()
    local playerName = UnitName("player")
    if not GNS_SpecNames[playerName] then
        GNS_SpecNames[playerName] = {
            [1] = "1st Specialization",
            [2] = "2nd Specialization",
            [3] = "3rd Specialization",
            [4] = "4th Specialization"
        }
    end
    currentPlayerName = playerName
end

-- Get the custom name for a specialization
local function GetSpecName(specNum)
    if currentPlayerName and GNS_SpecNames[currentPlayerName] then
        return GNS_SpecNames[currentPlayerName][specNum] or ("Spec " .. specNum)
    end
    return "Spec " .. specNum
end

-- Set the custom name for a specialization
local function SetSpecName(specNum, name)
    if currentPlayerName and name and name ~= "" then
        if not GNS_SpecNames[currentPlayerName] then
            GNS_SpecNames[currentPlayerName] = {}
        end
        GNS_SpecNames[currentPlayerName][specNum] = name
    end
end

-- Prompt for spec name
local function PromptForSpecName(specNum, defaultName)
    StaticPopupDialogs["GNS_NAME_SPEC"] = {
        text = "Enter name for Specialization " .. specNum .. ":",
        button1 = "Save",
        button2 = "Cancel",
        hasEditBox = 1,
        maxLetters = 30,
        OnShow = function()
            getglobal(this:GetName().."EditBox"):SetText(defaultName or GetSpecName(specNum))
            getglobal(this:GetName().."EditBox"):HighlightText()
        end,
        OnAccept = function()
            local editBox = getglobal(this:GetParent():GetName().."EditBox")
            local newName = editBox:GetText()
            if newName and newName ~= "" then
                SetSpecName(specNum, newName)
                DEFAULT_CHAT_FRAME:AddMessage("GNS: Specialization " .. specNum .. " renamed to '" .. newName .. "'", 0.3, 1.0, 0.3)
            end
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1
    }
    StaticPopup_Show("GNS_NAME_SPEC")
end

-- Create edit button for a specialization line
local function CreateEditButton(parent, specNum)
    local button = CreateFrame("Button", "GNSEditButton" .. specNum, parent)
    button:SetWidth(50)
    button:SetHeight(20)
    
    -- Create font string for the button text
    local fontString = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fontString:SetPoint("CENTER")
    fontString:SetText("[Edit]")
    button:SetFontString(fontString)
    
    -- Add hover effect
    button:SetScript("OnEnter", function()
        fontString:SetTextColor(1, 1, 0)
    end)
    button:SetScript("OnLeave", function()
        fontString:SetTextColor(1, 1, 1)
    end)
    
    button:SetScript("OnClick", function()
        PromptForSpecName(specNum)
    end)
    
    return button
end

-- Position edit button to the right side of the gossip frame
local function PositionEditButton(button, gossipButton)
    button:ClearAllPoints()
    button:SetPoint("LEFT", gossipButton, "RIGHT", 10, 0)
    button:Show()
end

-- Hide all edit buttons
local function HideAllEditButtons()
    for i = 1, 4 do
        if editButtons[i] then
            editButtons[i]:Hide()
        end
    end
end

-- Update gossip frame with custom names and edit buttons
local function UpdateGossipFrame()
    HideAllEditButtons()
    
    for i = 1, NUMGOSSIPBUTTONS do
        local titleButton = getglobal("GossipTitleButton" .. i)
        if titleButton and titleButton:IsVisible() then
            local buttonText = titleButton:GetText()
            
            -- Store the ORIGINAL text on first sight, before any modifications
            if not titleButton.GNS_OriginalText then
                titleButton.GNS_OriginalText = buttonText
            end
            
            -- Always pattern match against the ORIGINAL unmodified text
            local textToMatch = titleButton.GNS_OriginalText
            
            -- Check for "Activate Nth Specialization" or "Save Nth Specialization"
            local specType, specNum, specMod, talents
            
            -- Try Activate pattern first - match "Activate 1st Specialization (20/31/0)"
            -- Note: there's a space before the parenthesis, so use %s* to match any spaces
            _, _, specNum, specMod, talents = string.find(textToMatch, "Activate (%d+)(..) Specialization%s*%(([%d/]+)%)")
            if specNum then
                specType = "Activate"
            end
            
            -- Try Save pattern - match "Save 1st Specialization"
            if not specNum then
                _, _, specNum, specMod = string.find(textToMatch, "Save (%d+)(..) Specialization")
                if specNum then
                    specType = "Save"
                end
            end
            
            if specType and specNum then
                specNum = tonumber(specNum)
                local customName = GetSpecName(specNum)
                local newText
                
                -- Only modify Activate lines, leave Save lines as default
                if specType == "Activate" and talents then
                    newText = string.format("Activate %s (%s)", customName, talents)
                    titleButton:SetText(newText)
                end
                
                -- TODO: Add edit buttons later
                -- Create edit button if it doesn't exist
                --if not editButtons[specNum] then
                --    editButtons[specNum] = CreateEditButton(GossipFrame, specNum)
                --end
                
                -- Position and show edit button
                --PositionEditButton(editButtons[specNum], titleButton)
            end
        end
    end
end

-- Hook the GossipTitleButton_OnClick to intercept save actions
local GNS_original_GossipTitleButton_OnClick = GossipTitleButton_OnClick
function GNS_GossipTitleButton_OnClick()
    if this.type ~= "Available" and this.type ~= "Active" and GossipFrameNpcNameText and GossipFrameNpcNameText:GetText() == "Goblin Brainwashing Device" then
        -- Use the original text if available, otherwise current text
        local buttonText = this.GNS_OriginalText or this:GetText()
        local _, _, specNum = string.find(buttonText, "Save (%d+).. Specialization")
        
        -- Also check the current text if not found in original
        if not specNum then
            buttonText = this:GetText()
            _, _, specNum = string.find(buttonText, "Save Spec (%d+)")
            if not specNum then
                _, _, specNum = string.find(buttonText, "Save (.+)")
                -- If it's a custom name, find which spec it is by checking all specs
                if specNum then
                    for i = 1, 4 do
                        if GetSpecName(i) == specNum then
                            specNum = i
                            break
                        end
                    end
                end
            end
        end
        
        if specNum then
            specNum = tonumber(specNum)
            lastSavedSpec = specNum
        end
    end
    
    GNS_original_GossipTitleButton_OnClick()
end
GossipTitleButton_OnClick = GNS_GossipTitleButton_OnClick

-- Event handler
GNSFrame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "GNS" then
        DEFAULT_CHAT_FRAME:AddMessage("GNS - Goblin Naming System loaded!", 0.3, 1.0, 0.3)
        
    elseif event == "PLAYER_ENTERING_WORLD" then
        InitPlayerData()
        
    elseif event == "GOSSIP_SHOW" then
        if GossipFrameNpcNameText and GossipFrameNpcNameText:GetText() == "Goblin Brainwashing Device" then
            -- Delay slightly to let SimpleActionSets modify the text first
            local timer = CreateFrame("Frame")
            timer.elapsed = 0
            timer:SetScript("OnUpdate", function()
                this.elapsed = this.elapsed + arg1
                if this.elapsed >= 0.1 then
                    this:SetScript("OnUpdate", nil)
                    UpdateGossipFrame()
                end
            end)
        end
        
    elseif event == "GOSSIP_CLOSED" then
        -- When gossip closes after saving, prompt for name
        if lastSavedSpec then
            -- Delay the prompt slightly so the gossip frame fully closes
            local specToName = lastSavedSpec
            lastSavedSpec = nil
            
            -- Use a timer to delay the popup
            local timer = CreateFrame("Frame")
            timer.elapsed = 0
            timer:SetScript("OnUpdate", function()
                this.elapsed = this.elapsed + arg1
                if this.elapsed >= 0.5 then
                    this:SetScript("OnUpdate", nil)
                    PromptForSpecName(specToName)
                end
            end)
        end
        
        -- Clear stored original text on all gossip buttons
        for i = 1, NUMGOSSIPBUTTONS do
            local titleButton = getglobal("GossipTitleButton" .. i)
            if titleButton then
                titleButton.GNS_OriginalText = nil
            end
        end
        
        HideAllEditButtons()
    end
end)

-- Slash command for manual renaming
SLASH_GNS1 = "/gns"
SLASH_GNS2 = "/goblinname"
SlashCmdList["GNS"] = function(msg)
    local _, _, specNum = string.find(msg, "^(%d+)%s*")
    
    if specNum then
        specNum = tonumber(specNum)
        if specNum >= 1 and specNum <= 4 then
            PromptForSpecName(specNum)
        else
            DEFAULT_CHAT_FRAME:AddMessage("GNS: Please specify a specialization number between 1 and 4", 1.0, 0.3, 0.3)
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("GNS - Goblin Naming System", 0.3, 1.0, 0.3)
        DEFAULT_CHAT_FRAME:AddMessage("Usage: /gns <1-4> - Rename a specialization", 1.0, 1.0, 1.0)
        DEFAULT_CHAT_FRAME:AddMessage("Current names:", 1.0, 1.0, 1.0)
        for i = 1, 4 do
            DEFAULT_CHAT_FRAME:AddMessage("  Spec " .. i .. ": " .. GetSpecName(i), 0.8, 0.8, 0.8)
        end
    end
end
