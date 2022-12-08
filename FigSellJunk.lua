local maxNumBags = 4
local function sellJunk()
  local vendorItemTicker
  local itemsToSell = {}
  local numJunkItemsSold = 0

  local function sellItem()
    if table.getn(itemsToSell) > 0 then
      -- sell an item from the list
      local itemIndices = table.remove(itemsToSell)
      local bagIndex = itemIndices[1]
      local slotIndex = itemIndices[2]
      C_Container.UseContainerItem(bagIndex, slotIndex)
      numJunkItemsSold = numJunkItemsSold + 1
    else
      -- clean up and report
      vendorItemTicker:Cancel()
      if numJunkItemsSold > 0 then
        print(format('<FigSellJunk> sold %i items', numJunkItemsSold))
      end
    end
  end

  -- iterate through every bag
  for bagIndex = 0, maxNumBags do
    local numSlotsInBag = C_Container.GetContainerNumSlots(bagIndex)

    if numSlotsInBag > 0 then
      -- there is a bag in this slot, let's iterate through each slot
      for slotIndex = 1, numSlotsInBag do
        local itemInfo = C_Container.GetContainerItemInfo(bagIndex, slotIndex)
        if itemInfo ~= nil and itemInfo.quality == Enum.ItemQuality.Poor then
          -- mark the item to be vendored
          table.insert(itemsToSell, { bagIndex, slotIndex })
        end
      end
    end
  end

  -- every 0.1 seconds, vendor an item (this avoids some items becoming busy due to trying to sell too fast)
  vendorItemTicker = C_Timer.NewTicker(0.1, sellItem)
end

local function onEvent(frame, event, ...)
  if event == 'MERCHANT_SHOW' then
    -- create vendor junk button (if necessary)
    local sellJunkBtn = _G['FigSellJunkButton']
    if not sellJunkBtn then
      local merchantFrame = _G['MerchantFrame']
      sellJunkBtn = CreateFrame('button', 'FigSellJunkButton', merchantFrame, 'UIPanelButtonTemplate')
      sellJunkBtn:SetSize(80, 30)
      sellJunkBtn:SetText('Sell Junk')
      sellJunkBtn:SetPoint('TOPRIGHT', merchantFrame, 'BOTTOMRIGHT')
      sellJunkBtn:SetScript('OnClick', sellJunk)
    end

    -- listen for when the merchant window switches tabs
    EventRegistry:RegisterCallback('MerchantFrame.BuyBackTabShow', sellJunkBtn.Hide, sellJunkBtn)
    EventRegistry:RegisterCallback('MerchantFrame.MerchantTabShow', sellJunkBtn.Show, sellJunkBtn)
    
    -- show button
    sellJunkBtn:Show()
    
  elseif event == 'MERCHANT_CLOSED'  then
    -- hide button
    if _G['FigSellJunkButton'] then
      _G['FigSellJunkButton']:Hide()
    end
  end
end

-- create an invisible frame that listens for when the merchant window is opened and closed
local f = CreateFrame('frame', 'FigSellJunk', UIParent)
f:RegisterEvent('MERCHANT_SHOW')
f:RegisterEvent('MERCHANT_CLOSED')
f:SetScript('OnEvent', onEvent)
