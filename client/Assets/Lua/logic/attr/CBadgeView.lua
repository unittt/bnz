local CBadgeView = class("CBadgeView", CViewBase)  --徽章界面

function CBadgeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Attr/BadgeView.prefab", cb)

	--self.m_OpenBadge = 40  --開啟徽章等級
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CBadgeView.OnCreateView(self)
	self.m_NameLabel = self:NewUI(1, CLabel)  --徽章等級名字
	self.m_BadgeSprite = self:NewUI(2, CSprite) --徽章圖標
	self.m_LvLabel = self:NewUI(3, CLabel)   --人物等級
	self.m_MarkLabel = self:NewUI(4, CLabel)  --人物評分
	self.m_worldcmdLabel = self:NewUI(5, CLabel) --道具數量
	self.m_PromoteBtn = self:NewUI(6, CButton)  --提升按鈕
	self.m_curAtt = self:NewUI(7, CBadgeAttrBox) --当前徽章等级属性
	self.m_nextAtt = self:NewUI(8, CBadgeAttrBox) --下一级等级属性
	self.m_itemIconSprite = self:NewUI(9, CSprite) --道具圖標
	self.m_Max = self:NewUI(10, CObject)
	self.m_Bot = self:NewUI(11, CObject)
	self.m_Arrow = self:NewUI(12,CObject)
	self.m_CloseBtn = self:NewUI(13, CButton)
	self.m_ItemName = self:NewUI(14,CLabel)
	self.m_GudieWidget = self:NewUI(15, CWidget)

	g_GuideCtrl:AddGuideUI("badge_promote_btn", self.m_PromoteBtn)
	g_GuideCtrl:AddGuideUI("badge_guide_widget", self.m_GudieWidget)
	--g_GuideCtrl:AddGuideUI("badge_close_btn", self.m_CloseBtn)

	self:InitContent()
	self:RefreshUI()
end

--初始化事件監聽
function CBadgeView.InitContent(self)
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnBadgeEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnBadgeEvent"))

	self.m_PromoteBtn:AddUIEvent("click", callback(self, "OnPromote")) 
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_itemIconSprite:AddUIEvent("click", callback(self, "OnClickItem"))
	g_SysUIEffCtrl:DelSysEff("BADGE")
end

function CBadgeView.OnBadgeEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.UpgradeTouxianInfo or oCtrl.m_EventID == define.Attr.Event.Change or oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem or oCtrl.m_EventID == define.Item.Event.AddBagItem then
		self:RefreshUI()
	end
end

--點擊提升按鈕，響應
function CBadgeView.OnPromote(self)
	if self:JudgeIsPromote() == true  then
		g_AttrCtrl:C2GSUpgradeTouxian()
	end

	if self.m_IsLackCostItem then

	end
end

--刷新界面
function CBadgeView.RefreshUI(self)
	-- table.print(g_AttrCtrl.m_BadgeInfo,"---徽章信息--")
	local tid = g_AttrCtrl.m_BadgeInfo and g_AttrCtrl.m_BadgeInfo.tid or 5002
	self.badgeLevel = tid
	local tTouxiandata = tid and data.touxiandata.DATA[tid + 1]
	if not tTouxiandata then
		self.m_Bot:SetActive(false)
		self.m_Max:SetActive(true)
		self.m_Arrow:SetActive(false)
		self.m_curAtt:SetInfo(tid, true)
		self.m_nextAtt:SetActive(false)
		self.m_curAtt:SetLocalPos(Vector3.New(179, -55, 0)) 
	else
		self:RefreshPromote()
		self:RefreshAtt()
	end
end

--刷新屬性新信息
function CBadgeView.RefreshAtt(self)
	self.m_curAtt:SetInfo(self.badgeLevel)
	self.m_nextAtt:SetInfo(self.badgeLevel + 1)
end 

--刷新當前徽章等級信息(此处显示升级下一级所需道具，人物评分)
function CBadgeView.RefreshPromote(self)
	--printc("---RefreshPromote-----",self.badgeLevel)
	local tTouxiandata = data.touxiandata.DATA[self.badgeLevel + 1]
	local curLevelData = data.touxiandata.DATA[self.badgeLevel]
	if tTouxiandata  then
		local itemNum = g_ItemCtrl:GetBagItemAmountBySid(tTouxiandata.cost.itemid)
		local item_data = DataTools.GetItemData(tTouxiandata.cost.itemid)
		self.m_ItemName:SetText(item_data.name..":")
		self.m_CostItemId = tTouxiandata.cost.itemid
		self.m_IsLackCostItem = itemNum < tTouxiandata.cost.amount

		if self.badgeLevel == 1000 then  
			self.m_NameLabel:SetText("无")
			self.m_BadgeSprite:SetSpriteName("")
		else
			self.m_NameLabel:SetText(curLevelData.name)
			self.m_BadgeSprite:SetSpriteName(tTouxiandata.tid)
		end
		self.m_itemIconSprite:SpriteItemShape(item_data.icon)

		if g_AttrCtrl.grade < tTouxiandata.needLevel then
			self.m_LvLabel:SetText("[AF302A]"..g_AttrCtrl.grade.."[-]".."[244B4E]".."/"..tTouxiandata.needLevel.."[-]")
		else
			self.m_LvLabel:SetText("[244B4E]"..g_AttrCtrl.grade.."/"..tTouxiandata.needLevel.."[-]")
		end

		local scoreNum = 0
		if g_AttrCtrl.m_BadgeInfo then
			scoreNum = g_AttrCtrl.score
		end

		if scoreNum < tTouxiandata.score then
			self.m_MarkLabel:SetText("[AF302A]"..scoreNum.."[-]".."[244B4E]".."/"..tTouxiandata.score.."[-]")
		else
			self.m_MarkLabel:SetText("[244B4E]"..scoreNum.."/"..tTouxiandata.score.."[-]")
		end

		if  itemNum < tTouxiandata.cost.amount then
			self.m_worldcmdLabel:SetText("[AF302A]"..itemNum.."[-]".."[502E10]".."/"..tTouxiandata.cost.amount.."[-]")
		else
			self.m_worldcmdLabel:SetText("[1D8E00]"..itemNum.."/"..tTouxiandata.cost.amount.."[-]")
		end 
	end
end


--拆分属性 （返回重新存储的属性表）
function CBadgeView.SplitAtt(self, str, lv)
	local temp_string = string.split(str,",")
	local attConfig = {}
	lv = lv or ""
	for i=1,#temp_string do
		local temp = string.split(temp_string[i],"=")
		local formula = string.gsub(temp[2], "level", lv)
		attConfig[tonumber(temp[1])] = formula
	end
	return attConfig
end

--判断是否能提升
function CBadgeView.JudgeIsPromote(self)
	local bIspromote = false
	--printc("---判断是否能提升----",self.badgeLevel)
	local tTouxiandata = data.touxiandata.DATA[self.badgeLevel + 1]
	if tTouxiandata then
		local item_num = g_ItemCtrl:GetBagItemAmountBySid(tTouxiandata.cost.itemid)
		local item_name = DataTools.GetItemData(tTouxiandata.cost.itemid, "OTHER").name
		if item_num >= tTouxiandata.cost.amount then
			bIspromote = true
		else 
			bIspromote = false
			g_NotifyCtrl:FloatMsg(string.GetContentMacthColor(data.touxiandata.TEXT,1004,item_name))
			return bIspromote
		end
		-- local point = 0
		-- if  g_AttrCtrl.m_BadgeInfo then
		--     point = g_AttrCtrl.m_BadgeInfo.score
		-- end
		-- if point >= tTouxiandata.score then
		--    bIspromote = true
		-- else 
		--    bIspromote = false
		--    g_NotifyCtrl:FloatMsg(data.touxiandata.TEXT[1001].content)
		--    return bIspromote
		-- end    
		if g_AttrCtrl.grade >= tTouxiandata.needLevel then
			bIspromote = true
		else
			bIspromote = false
			g_NotifyCtrl:FloatMsg(string.GetContentMacthColor(data.touxiandata.TEXT,1002,tTouxiandata.needLevel))
			return bIspromote
		end
	end
	return bIspromote
end

function CBadgeView.OnClickItem(self)
	if not self.m_CostItemId then return end
	g_WindowTipCtrl:SetWindowGainItemTip(self.m_CostItemId, function ()
	local oView = CItemTipsView:GetView()
	UITools.NearTarget(self.m_itemIconSprite, oView.m_MainBox, enum.UIAnchor.Side.Top, Vector2.New(0, 10))
	end)
end

function CBadgeView.CloseView(self)
	CViewBase.CloseView(self)
end

return CBadgeView