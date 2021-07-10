local maxNumBags = 4
local function sellJunk()
  local numJunkItemsSold = 0

  -- iterate through every bag
  for bagIndex = 0, maxNumBags do
    local numSlotsInBag = GetContainerNumSlots(bagIndex)

    if numSlotsInBag > 0 then
      -- there is a bag in this slot, let's iterate through each slot
      for slotIndex = 1, numSlotsInBag do
        local _, _, _, quality = GetContainerItemInfo(bagIndex, slotIndex)
        if quality == Enum.ItemQuality.Poor then
          -- vendor the item
          UseContainerItem(bagIndex, slotIndex)
          numJunkItemsSold = numJunkItemsSold + 1
        end
      end
    end
  end
  if numJunkItemsSold > 0 then
    print(format('<FigSellJunk> sold %i items', numJunkItemsSold))
  end
end

local function onEvent(frame, event, ...)
  if event == 'MERCHANT_SHOW' then
    -- create vendor junk button (if necessary)
    local sellJunkBtn = _G['FigSellJunkButton']
    if not sellJunkBtn then
      local merchantFrame = _G['MerchantFrame']
      sellJunkBtn = CreateFrame('button', 'FigSellJunkButton', merchantFrame, 'UIPanelButtonTemplate')
      sellJunkBtn:SetSize(80, 30)
      sellJunkBtn:SetText('Sell Junk');
      -- place the junk button at a quarter of the way into the merchant frame
      local xOffset = merchantFrame:GetWidth() / 4
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
