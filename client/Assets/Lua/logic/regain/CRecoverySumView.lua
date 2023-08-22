local CRecoverySumView = class("CRecoverySumView",CViewBase)

function CRecoverySumView.ctor(self,cb)
	CViewBase.ctor(self,"UI/Recovery/CRecoverySumView.prefab", cb)
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_CurrSum = nil
	self.m_Cost = nil
	self.m_Money = nil
	self.m_SaveList ={}
end
function CRecoverySumView.OnCreateView(self)
	self.m_TipBtn = self:NewUI(1 ,CButton)
	self.m_GetBtn = self:NewUI(2, CButton)
	self.m_CloseBtn = self:NewUI(3, CButton)
	self.m_SumGrid = self:NewUI(4, CGrid)
	self.m_SumClone = self:NewUI(5 ,CBox)
	self.m_NameLabel = self:NewUI(6, CLabel)
	self.m_DesLabel = self:NewUI(7 , CLabel)
	self.m_CostLabel = self:NewUI(8 , CLabel)
	self.m_MoneyLabel = self:NewUI(9 ,CLabel)
	self.m_CostLabel:SetText(0)
	self.m_CloseBtn:AddUIEvent("click",callback(self, "OnClose"))
	self.m_TipBtn:AddUIEvent("click",callback(self, "OnTipBtn"))
	self.m_GetBtn:AddUIEvent("click",callback(self, "OnSendMsg"))

	g_RecoveryCtrl:AddCtrlEvent(self:GetInstanceID(),callback(self,"RefreshBox"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "RefreshMoney"))
	self:IninContent() 
end

function CRecoverySumView.IninContent(self)
	local str = string.AddCommaToNum(g_AttrCtrl:GetGoldCoin()) or ""
	self.m_MoneyLabel:SetText(str)
	self.m_Money = g_AttrCtrl:GetGoldCoin()
	local gridChildList = self.m_SumGrid:GetChildList()
	
	for i=1,#g_RecoveryCtrl.m_RecoverySumList do
		local oSumBox = nil
		if i > #gridChildList then
			oSumBox = self.m_SumClone:Clone()
			self.m_SumGrid:AddChild(oSumBox)
			oSumBox:SetGroup(self.m_SumGrid:GetInstanceID())
		else
			oSumBox = gridChildList[i]
		end
		oSumBox:SetActive(true) 
	end

	self.m_SumClone:SetActive(false)
	for i,v in ipairs(g_RecoveryCtrl.m_RecoverySumList) do
		local oSumBox = self.m_SumGrid:GetChild(i)
		self:CreateSumBox( oSumBox, v)
		oSumBox:AddUIEvent("click",callback(self,"CurrSumShow" ,v))
		if i == 1 then
			oSumBox:ForceSelected(true)
			self:CurrSumShow(v)
			self.m_CurrSum = v
		end
	end
	self.m_SaveList = g_RecoveryCtrl.m_RecoverySumList
end

function CRecoverySumView.RefreshBox(self)

	if g_RecoveryCtrl.m_DeleteSumID then
		for i,v in ipairs(self.m_SaveList) do
			if g_RecoveryCtrl.m_DeleteSumID  == v.id then
				local box = self.m_SumGrid:GetChild(i)
				box:SetActive(false)
			end
		end
	end
	self.m_CurrSum = nil
	self.m_NameLabel:SetText("")
	self.m_DesLabel:SetText("")
	self.m_SumGrid:Reposition()
	self.m_CostLabel:SetText("")
end

function CRecoverySumView.CreateSumBox(self , oBox, v)
	oBox.m_SumSprite = oBox:NewUI(1 ,CSprite)
	local func = function ()
		-- body
		g_LinkInfoCtrl:ShowSummonInfo(v)
	end
	oBox.m_SumSprite:AddUIEvent("click",func)


	oBox.m_NameLabel = oBox:NewUI(2 ,CLabel)
	oBox.m_SkillLabel = oBox:NewUI(3 ,CLabel)
	oBox.m_LVLabel = oBox:NewUI(4 ,CLabel)
	oBox.m_SumType = oBox:NewUI(5 ,CLabel)
	oBox.m_selectSprite = oBox:NewUI(6 ,CSprite)

	oBox.m_selectSprite:SetActive(true)
	oBox.m_SumSprite:SetSpriteName(tostring(v.model_info.shape))
	oBox.m_NameLabel:SetText(v.name)
	oBox.m_LVLabel:SetText(v.grade.."级")
	if v.type == 2 then
		oBox.m_SumType:SetText("宝宝")
	else
		oBox.m_SumType:SetText(data.summondata.SUMMTYPE[v.type].name)
	end
	local equipskillcount = 0
	if v.equipinfo then
		for i,k in ipairs(v.equipinfo) do
			if k. equip_info and k. equip_info.skills then
				equipskillcount = equipskillcount + table.count(k. equip_info.skills)
			end
		end

	end
	oBox.m_SkillLabel:SetText(table.count(v.skill)+equipskillcount+table.count(v.talent).."个\n技能")
	-- oBox.m_SkillLabel:SetText(#v.skill.."个\n技能")
end

function CRecoverySumView.CurrSumShow(self ,suminfo)
	self.m_CurrSum = suminfo
	local time = g_TimeCtrl:Convert(suminfo.cycreate_time)
	self.m_DesLabel:SetText(time)
	local v = data.recoverydata.RECOVERYSUM[suminfo.typeid] and data.recoverydata.RECOVERYSUM[suminfo.typeid].cost or 0
	v = string.gsub(v,"lv",suminfo.carrygrade) 
	local func = loadstring("return " .. v)
	self.m_CostLabel:SetCommaNum(  func() )
	self.m_NameLabel:SetText(suminfo.name)
end

function CRecoverySumView.RefreshMoney(self ,oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		local data = oCtrl.m_EventData
		if data then
			local str = string.AddCommaToNum(g_AttrCtrl:GetGoldCoin()) or ""
			self.m_MoneyLabel:SetText(str)
			self.m_Money = g_AttrCtrl:GetGoldCoin()
		end
	end
end

function CRecoverySumView.OnSendMsg(self)
	
	if self.m_CurrSum and self.m_CurrSum.id  then
		if self.m_Money < tonumber(self.m_CostLabel:GetText()) then
			g_NotifyCtrl:FloatMsg(data.textdata.TEXT[3005].content)
			-- CNpcShopMainView:ShowView(function (oView)
			-- 	oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge"))
			-- end
			-- )
			g_ShopCtrl:ShowChargeView()
			return 
		end
		g_RecoveryCtrl:C2GSRecoverySum(self.m_CurrSum.id)
	end
end

function CRecoverySumView.OnTipBtn(self)
	-- body
		local Id = define.Instruction.Config.RecoverPet
		if data.instructiondata.DESC[Id]~=nil then
			local Content = {
				 title = data.instructiondata.DESC[Id].title,
			 	 desc = data.instructiondata.DESC[Id].desc
				}
				g_WindowTipCtrl:SetWindowInstructionInfo(Content)
		end
end

return CRecoverySumView