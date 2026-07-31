--TODO: Create a item type that i can use  akso nake tghat that r\ther than going to the data manager directly it uses the player obj instead

local InventoryManager = {}
local RS = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SS = game:GetService("ServerStorage")
local CS = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local DataManager = require(ServerScriptService.Data.Modules.DataManager)
local ItemInfoDictionary = require(SS.Modules.Dictionaries.ItemInfo)
local plr = require(ServerStorage.Modules.Objects.plr)

local Events = RS.Events
local InventoryEvent = Events.InventoryEvent

local ToolBox = RS.Tools
local Models = RS.Models
local ItemFolder = ToolBox.Items
local ItemModelFolder = Models.Items
local ActiveItemFolder = workspace.ActiveItems

local VFX_GROUP = "VFX_Models"

function InventoryManager.AddItem(player, itemname, quantity)
	local ItemInfo = ItemInfoDictionary.getStats(itemname)
	local MaxStack = ItemInfo.MaxStack or 10
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		local itemTemplate: Tool = ItemFolder:FindFirstChild(itemname, true)
		if ItemInfo.StackType == "Stackable" then
			local existingItem = backpack:FindFirstChild(itemname)
			if existingItem then
				local currentCount = existingItem:GetAttribute("Count")
				if currentCount == MaxStack then
					warn("Maximum stack count reached for item: " .. itemname)
					return
				else
					print("Adding " .. quantity .. " to existing stack of " .. itemname)
					existingItem:SetAttribute("Count", currentCount + quantity)
				end
			else
				local NewItem: Tool = itemTemplate:Clone()
				local TrueName = Instance.new("StringValue",NewItem)
				TrueName.Name = "TrueName"
				local Randomnum = math.random(0, 1000000)
				TrueName.Value = itemTemplate.Name
				NewItem.Name = itemTemplate.Name .. "_" .. player.Name .. "_" .. Randomnum
				NewItem.Parent = backpack
				NewItem:SetAttribute("Count", quantity)
			end
		else
			local NewItem = itemTemplate:Clone()
			local TrueName = Instance.new("StringValue",NewItem)
			TrueName.Name = "TrueName"
			local Randomnum = math.random(0,1000000)
			TrueName.Value = itemTemplate.Name
			NewItem.Name = itemTemplate.Name .. "_" .. player.Name .. "_" .. Randomnum
			NewItem.Parent = backpack
			NewItem.Parent = backpack
			NewItem:SetAttribute("Count", 1)
		end

		--- I need to create a table will all the intems info then use that to be addedf to the data base
		--DataManager.UpdateInventory(player, "Add", itemname, quantity)
	else
		warn("Backpack not found for player: " .. player.Name)
	end
end

function InventoryManager.RemoveItem(plr, itemname, quantity)
	local backpack = plr:FindFirstChildOfClass("Backpack")
	if backpack then
		local Item_Target = backpack:FindFirstChild(itemname)

		if Item_Target then
			local itemCount = Item_Target:GetAttribute("Count") or 1
			if itemCount >= quantity then
				Item_Target:SetAttribute("Count", itemCount - quantity)
				DataManager.UpdateInventory(plr, "Remove", itemname, quantity)
				if Item_Target:GetAttribute("Count") <= 0 then
					Item_Target:Destroy()
				end
			else
				warn("Not enough '" .. itemname .. "' items to remove from player: " .. plr.Name)
			end
		else
			-- This means that the call was from the hotbar so
			local HotBarItem = plr.Character:FindFirstChild(itemname)
			if HotBarItem then
				local itemCount = HotBarItem:GetAttribute("Count") or 1
				print(itemCount)
				if itemCount >= quantity then
					HotBarItem:SetAttribute("Count", itemCount - quantity)
					--DataManager.UpdateInventory(plr, "Remove", itemname, quantity)
					if HotBarItem:GetAttribute("Count") <= 0 then
						HotBarItem:Destroy()
					end
				else
					warn("Not enough '" .. itemname .. "' items to remove from player: " .. plr.Name)
				end
			end
		end
	end
end

function InventoryManager.DropItem(plr: Player, item, count: number)
	if item.ToolType == "Skill" then
		return
	end
	local char = plr.Character
	if char then
		local HRP = char:FindFirstChild("HumanoidRootPart")
		if HRP then
			local ToolName = item.Name
			local droppedItem: MeshPart = ItemModelFolder:FindFirstChild(ToolName, true):Clone()
			droppedItem.CollisionGroup = VFX_GROUP
			local Model: Model = Instance.new("Model")
			local Highlight = Instance.new("Highlight")
			Highlight.Parent = droppedItem
			Model.Name = item.Name .. "_Model"
			droppedItem.Parent = Model
			Model.Parent = ActiveItemFolder
			CS:AddTag(droppedItem, "Item")
			droppedItem.CustomPhysicalProperties = PhysicalProperties.new(0.3, 1, 0, 1, 0)
			droppedItem.CFrame = HRP.CFrame * CFrame.new(0, 0, -5)
			Model:ScaleTo(0.55) -- This why i put the item in a model, because it easir to scale the item
			InventoryManager.RemoveItem(plr, ToolName, count) -- This handles the removing of the item from the backpack
			droppedItem.CanCollide = true
			droppedItem.CanTouch = true
			droppedItem.CanQuery = true
			droppedItem:SetAttribute("Count", count)
			droppedItem.Parent = ActiveItemFolder
			Model:Destroy()
			InventoryEvent:FireClient(plr, "ItemDropped", item)
		else
			warn("HumanoidRootPart not found for player: " .. plr.Name)
		end
	else
		warn("Character not found for player: " .. plr.Name)
	end
end

function InventoryManager.LoadInventory(plr)
	local char = plr.Character
	local backpack = plr:FindFirstChildOfClass("Backpack")
	local CurrentSlot = char:GetAttribute("CurrentSlot") or 1
	if backpack == nil then
		return
	end
	local inventoryData = DataManager.Profiles[plr][CurrentSlot].Inventory
	local HotbarData = DataManager.Profiles[plr][CurrentSlot].Hotbar
end

return InventoryManager
