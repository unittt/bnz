local CTreasurePrizeView = class("CTreasurePrizeView", CViewBase)

function CTreasurePrizeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Treasure/TreasurePrizeView.prefab", cb)
	self.m_DepthType = "Dialog"
	-- self.m_ExtendClose = "ClickOut"	

	self.m_PrizeBoxList = {}
	self.m_TimeCount = 0
	self.m_MoneyType = "银币"
	self.m_MoneyNum = nil
	self.m_MoneyItemId = DataTools.GetItemData(1002, "VIRTUAL").icon
	self.m_Sessionidx = nil
end

function CTreasurePrizeView.OnCreateView(self)
	self.m_PrizeBox = self:NewUI(1,CTreasurePrizeBox)
	self.m_DescLabel = self:NewUI(2,CLabel)
	self.m_CloseBtn = self:NewUI(3,CButton)
	-- self.m_BgTexture = self:NewUI(8, CTexture)
	self.m_GoldSp = self:NewUI(4, CSprite)
	self.m_SilverSp = self:NewUI(5, CSprite)
	self.m_DescSp = self:NewUI(6, CSprite)
	self.m_Grid = self:NewUI(7, CGrid)
	self.m_FrameSpr = self:NewUI(8, CSprite)

	self.m_DescLabel:SetActive(false)
	self.m_GoldSp:SetActive(false)
	self.m_DescSp:SetActive(false)
	self.m_SilverSp:SetActive(false)
	self.m_PrizeBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

--设置金钱的总共数值
function CTreasurePrizeView.SetPrizeNum(self, prizenum, sType, sessionidx)
	-- table.print(g_TreasureCtrl:GetEachNumList(prizenum, define.Treasure.MoneyEffect.Total),"数字列表")
	self.m_IsShowDesc = false
	self.m_IsFloat = true
	self.m_MoneyType = sType
	self.m_MoneyNum = prizenum
	self.m_Sessionidx = sessionidx
	-- local sTextureName = "Texture/Treasure/h7_yinwabao.png"
	local Color = Color.New(0x00/0xff, 0x81/0xff, 0xab/0xff, 1)
	local TypeStr = "#silver_"
	if sType == "金币" then
		-- sTextureName = "Texture/Treasure/h7_jinwabao.png"
		Color = Color.New(0xa6/0xff, 0x4e/0xff, 0x00/0xff, 1)
		TypeStr = "#gold_"
		self.m_MoneyItemId = DataTools.GetItemData(1001, "VIRTUAL").icon
	else
		-- sTextureName = "Texture/Treasure/h7_yinwabao.png"
		Color = Color.New(0x00/0xff, 0x81/0xff, 0xab/0xff, 1)
		TypeStr = "#silver_"
		self.m_MoneyItemId = DataTools.GetItemData(1002, "VIRTUAL").icon
	end
	-- g_ResCtrl:LoadAsync(sTextureName, callback(self, "SetTexture"))
	for k,v in pairs(self.m_PrizeBoxList) do
		v:SetLabelColor(Color)
	end
	local numStr = ""
	local iCnt = string.len(tostring(prizenum))
	self:CreateNumBoxs(iCnt)
	local PrizeNumList,realPrizeNumList = g_TreasureCtrl:GetEachNumList(prizenum, iCnt)
	--从个位开始赋值
	for i=iCnt,1,-1 do
		self.m_PrizeBoxList[i]:SetEachNum(PrizeNumList[iCnt+1-i])	
	end
	for k,v in ipairs(realPrizeNumList) do
		numStr = TypeStr..v..numStr
	end
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil			
	end
	self.m_TimeCount = 0
	
	local totalCount = define.Treasure.Time.PrizeTotal/define.Treasure.Time.Delta
	local LabelCount = define.Treasure.Time.LabelTotal/define.Treasure.Time.Delta
	local isUpdate = false
	local function progress()
		isUpdate = true
		self.m_TimeCount = self.m_TimeCount + 1
		if self.m_TimeCount >= LabelCount then
			if not self.m_DescLabel:IsDestroy() and not self.m_IsShowDesc then
				self.m_DescLabel:SetActive(true)
				self.m_DescLabel:SetText(numStr)
				self.m_DescSp:SetActive(true)
				if sType == "金币" then
					self.m_GoldSp:SetActive(true)
					self.m_SilverSp:SetActive(false)
				else
					self.m_GoldSp:SetActive(false)
					self.m_SilverSp:SetActive(true)
				end
				if self.m_MoneyType == "金币" then
					g_NotifyCtrl:ShowTreasurePrizeEffect(1)
				else
					g_NotifyCtrl:ShowTreasurePrizeEffect(0)
				end
				self.m_IsShowDesc = true
			end
			-- if self.m_IsFloat and tonumber(self.m_MoneyNum) > 0 then
				-- g_NotifyCtrl:FloatMsg("获得#G"..self.m_MoneyNum.."#n#cur_4"self.m_MoneyType)
			-- 	self.m_IsFloat = false
			-- end
		end
		if self.m_TimeCount >= totalCount then
			self:OnFinish(tonumber(self.m_MoneyNum))
			isUpdate = false
		end
		return isUpdate
	end
	self.m_Timer = Utils.AddTimer(progress, 0.02, 0.02)
end

function CTreasurePrizeView.SetTexture(self, prefab, errcode)
	if prefab then
		-- self.m_BgTexture:SetMainTexture(prefab)
	else
		print(errcode)
	end
end

function CTreasurePrizeView.CreateNumBoxs(self, iCnt)
	for i = 1, iCnt do
		local oBox = self.m_Grid:GetChild(i)
		if not oBox then
			oBox = self.m_PrizeBox:Clone()
			self.m_Grid:AddChild(oBox)
			table.insert(self.m_PrizeBoxList,oBox)
		end
		oBox:SetActive(true)
	end
	if iCnt > 1 then
		local iGridWidth = self.m_Grid.m_UIGrid.cellWidth
		local iFrameWidth = 107 + (iCnt - 1)*iGridWidth
		self.m_FrameSpr:SetWidth(iFrameWidth)
		if iCnt > 5 then
			local scale = (107 + 4 * iGridWidth)/iFrameWidth
			local vec = Vector3.one*scale
			self.m_FrameSpr:SetLocalScale(vec)
			self.m_Grid:SetLocalScale(vec)
		end
	end
	self.m_Grid:Reposition()
end

--抽奖过程结束
function CTreasurePrizeView.OnFinish(self, moneyNum)
	if moneyNum > 0 then
		if self.m_MoneyType == "金币" then
			g_NotifyCtrl:FloatMsg("获得#G"..moneyNum.."#n#cur_3")
		else
			g_NotifyCtrl:FloatMsg("获得#G"..moneyNum.."#n#cur_4")
		end
		g_NotifyCtrl:FloatItemBox(self.m_MoneyItemId)
	end
	g_TreasureCtrl.m_IsTreasureMoney = nil
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil			
	end
	self.m_TimeCount = 0
	self:CloseView()
	
	--自动挖宝
	if self.m_Sessionidx then
		netother.C2GSCallback(self.m_Sessionidx)
	end
end

function CTreasurePrizeView.OnClose(self)
	self:OnFinish(tonumber(self.m_MoneyNum))
	self:CloseView()
end

return CTreasurePrizeView