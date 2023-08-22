local CLongChatView = class("CLongChatView", CViewBase)


function CLongChatView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Chat/LongDisChatView.prefab", cb)
	self.m_ExtendClose = "ClickOut"
    
    self.m_BubbleType = {[101] = "h7_talkpaopao_1",
                         [102] = "h7_talkpaopao_2",
                         [103] = "h7_talkpaopao_3",
                        }
end

function CLongChatView.OnCreateView(self)
	self.m_InputLabel = self:NewUI(1, CChatInput,true,define.Chat.ChatInputArgs)
	self.m_FaceBtn = self:NewUI(3, CButton)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_itemGrid = self:NewUI(4, CGrid)
	self.m_ItemClone = self:NewUI(5, CBox)
	self.m_BoxGrid = self:NewUI(6, CGrid)
	self.m_BoxClone = self:NewUI(7, CBox)
	self.m_spendIcon = self:NewUI(8,CSprite)
	self.m_SendBtn = self:NewUI(9,CButton)
	self.m_Spend = self:NewUI(10,CLabel)
    self.m_ShowLabel = self:NewUI(11,CLabel)
    
    --self.m_InputLabel:SetForbidChars({"{", "}"})
	self:InitContent()
    
    g_ChatCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEvent"))
end

--初始化执行
function CLongChatView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_FaceBtn:AddUIEvent("click", callback(self, "OnFace"))
	self.m_SendBtn:AddUIEvent("click", callback(self, "OnSend"))
	self.m_InputLabel:AddUIEvent("change",callback(self,"RefreshBubble"))

	self:RefreshUI()
end

--刷新界面
function CLongChatView.RefreshUI(self)
	self:RefreshBubble()
	self:ShowItemBoxList()
end

function CLongChatView.OnEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem or oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem  then
	   self:OnRefreshNum()
	end
	if oCtrl.m_EventID == define.Chat.Event.Chuanyin then
	   
	end
end

--刷新气泡
function CLongChatView.RefreshBubble(self)
	self.m_InputLabel:OnInputChange()
    self.m_ShowLabel:SetLocalPos(Vector3.New(-127,-3,0))
	local des_str = self.m_InputLabel:GetText()
	if des_str then
		for i, oBox in ipairs(self.m_BoxGrid:GetChildList()) do
			--printc(i,oBox.id,self.m_CurBubbleId)
			if oBox.id == self.m_CurBubbleId then 
               local sMsg = self:CheckInput(des_str)
			   oBox.des:SetRichText(sMsg)
			else
			   oBox.des:SetRichText("")
			end
		end
	end
end

--刷新元宝消耗
function CLongChatView.RefreshGold(self)
	 local bubbleInfo = data.chatdata.MILES[self.m_CurBubbleId]
	 local goldPrice = DataTools.GetItemData(bubbleInfo.cost_item).buyPrice
	 local bagNum = g_ItemCtrl:GetBagItemAmountBySid(bubbleInfo.cost_item)
	 local needNum = bubbleInfo.cost_num > bagNum and bubbleInfo.cost_num-bagNum  or 0
	 local needGold = needNum*goldPrice
	 self.m_Spend:SetText(needGold)
end

--刷新道具消耗
function CLongChatView.OnRefreshNum(self)
	local itemList = self:GetItemTypeList()	
	local i = 1
	for k,v in pairs(itemList) do
		local child = self.m_itemGrid:GetChild(i)
		local bagNum = g_ItemCtrl:GetBagItemAmountBySid(k)
	 	if child.id == k then
           child.num:SetText(bagNum) 
	 	end
	 	i = i + 1
	 end 
	 self:RefreshGold()
end
--显示消耗道具列表
function CLongChatView.ShowItemBoxList(self)
	local itemList = self:GetItemTypeList()
	local i = 1
	for k,v in pairs(itemList) do
		local itemData = DataTools.GetItemData(k)
		local item = self.m_itemGrid:GetChild(i)
        if item == nil then
            item = self.m_ItemClone:Clone()
            item.icon = item:NewUI(1, CSprite)
            item.num = item:NewUI(2, CLabel)
            --item.name = item:NewUI(3, CLabel)
            item.id = k
            self.m_itemGrid:AddChild(item)
            item:SetGroup(self.m_itemGrid:GetInstanceID())
        end
        item:SetActive(true)
        item.icon:SetSpriteName(itemData.icon)
        --item.icon:SetLocalRotation(Vector3.New(0,180,0))
        local num = g_ItemCtrl:GetBagItemAmountBySid(k)
        item.num:SetText(num) 
        item:AddUIEvent("click", callback(self, "OnShowBubble",k, v))
        if self.m_CurSelId == nil then           --默认选择第一个
            item:SetSelected(true)
            self:OnShowBubble(k,v)
        elseif self.m_CurSelId == k then
            self:OnShowBubble(k,v) 
        end 
        i = i + 1 
	end
end

--根据选择道具显示对应的气泡类型
function CLongChatView.OnShowBubble(self, id, tbubble)
    --点击图标显示tip
    if self.m_CurSelId == id then
        g_WindowTipCtrl:SetWindowGainItemTip(id) 
    end

	self.m_CurSelId = id
	self.m_CurBubbleId = nil
	--table.print(tbubble,"道具选择气泡：")
	for i,v in pairs(tbubble) do
		local item = self.m_BoxGrid:GetChild(i)
		if item == nil then
		   item = self.m_BoxClone:Clone()
		   item.icon = item:NewUI(1, CSprite)
		   item.des = item:NewUI(2, CLabel)
		   item.id = v
		   self.m_BoxGrid:AddChild(item)
           item:SetGroup(self.m_BoxGrid:GetInstanceID())
		   item:AddUIEvent("click",callback(self,"OnToggle",v))
		end
		item:SetActive(true)
		item.icon:SetSpriteName(self.m_BubbleType[v])
		if self.m_CurBubbleId == nil then           --默认选择第一个
            item:SetSelected(true)
            self:OnToggle(v)
        elseif self.m_CurBubbleId == v then
            self:OnToggle(v) 
        end 
	end
	for i = #tbubble+1, self.m_BoxGrid:GetCount() do
        self.m_BoxGrid:GetChild(i):SetActive(false)
    end
	self:RefreshBubble()
end

--从配置表获取传音道具类型
function CLongChatView.GetItemTypeList(self)
	local MilesData = data.chatdata.MILES
	local item_data = {}
	for i,v in pairs(MilesData) do
		if item_data[v.cost_item] == nil then
		   item_data[v.cost_item] = {i}
		else
	       table.insert(item_data[v.cost_item],i)
		end
	end
	return item_data
end

--点击表情	
function CLongChatView.OnFace(self)
	CEmojiLinkView:ShowView(
		function(oView)
			oView:SetSendFunc(callback(self, "AppendText"))
		end
	)
end

--添加表情
function CLongChatView.AppendText(self, s, isClearInput)
	if string.match(s, "%b{}") then
		self.m_InputLabel:ClearLink()
	end
	if isClearInput then
		self.m_InputLabel:SetText(s)
	else
		local sOri = self.m_InputLabel:GetText()
		self.m_InputLabel:SetText(sOri..s)
	end
end

--点击发送
function CLongChatView.OnSend(self)
    --判断道具是否足够 1不足弹窗提示
    self:JudgeIsSend()
end

--点击选择气泡
function CLongChatView.OnToggle(self,bubbleId)
	self.m_CurBubbleId = bubbleId
	self:RefreshGold()
	self:RefreshBubble()
end

function CLongChatView.JudgeIsSend(self)
	local bubbleInfo = data.chatdata.MILES[self.m_CurBubbleId]
	local bagNum = g_ItemCtrl:GetBagItemAmountBySid(bubbleInfo.cost_item)
	local isSend = true
	if bagNum >= bubbleInfo.cost_num then
	   isSend = true
	else
	    local goldPrice = DataTools.GetItemData(bubbleInfo.cost_item).buyPrice
	    local needGold = (bubbleInfo.cost_num-bagNum)*goldPrice
	    if g_AttrCtrl:GetGoldCoin() >= needGold then
	       local windowConfirmInfo = {
            msg = "道具不足，花费"..needGold.."元宝代替小喇叭",
            pivot = enum.UIWidget.Pivot.Center,
            cancelCallback = function() isSend = false end,
            okCallback =  function() 
                              self:SendMiles() 
	                       end 
            }
            isSend = false
            g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	    else
            g_ShopCtrl:ShowChargeView()
			g_NotifyCtrl:FloatMsg("元宝不足")
            -- CNpcShopMainView:ShowView(function(oView) oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge")) end)
            --CAttrBuyEnergyView:ShowView()
	    	isSend = false
	    end
	end
	--printc("是否可以发：",isSend)
	if isSend then
       self:SendMiles()
    end
end

function CLongChatView.SendMiles(self)
    local sMsg = self.m_InputLabel:GetText()
    -- if g_MaskWordCtrl:IsContainMaskWord(sMsg) then
    --    sMsg = g_MaskWordCtrl:ReplaceMaskWord(sMsg,false)
    -- end
    sMsg = self:CheckInput(sMsg)
    g_ChatCtrl:SendMilesMsg(sMsg, self.m_CurBubbleId)
    self:CloseView()   --关闭传音界面
    local oView = CChatMainView:GetView()
    if oView then
       oView:CloseView()  --关闭聊天主界面
    end
end

function CLongChatView.CheckInput(self, sMsg)
	--这里是会替换链接内容，主要是不被屏蔽字屏蔽
	local linkStr
	for sLink in string.gmatch(sMsg, "%b{}") do
		linkStr = sLink
	end
    local iEmojiCnt = 0
    local function emoji(s)
        iEmojiCnt = iEmojiCnt + 1
        if iEmojiCnt > 5 then
            return string.sub(s, 5)
        else
            return s
        end
    end
    sMsg = string.gsub(sMsg, "#%d+", emoji)
    sMsg = string.gsub(sMsg, "#%u", "")
    sMsg = string.gsub(sMsg, "#n", "")
    sMsg = g_ChatCtrl:BlockColorInput(sMsg)
    sMsg = g_MaskWordCtrl:ReplaceMaskWord(sMsg)
    for sLink in string.gmatch(sMsg, "%b{}") do
		if linkStr then
			sMsg = string.replace(sMsg, sLink, linkStr)
		end
	end
    return sMsg
end

return CLongChatView