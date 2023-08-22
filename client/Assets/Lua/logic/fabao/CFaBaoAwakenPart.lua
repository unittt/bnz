local CFaBaoAwakenPart = class("CFaBaoAwakenPart", CPageBase)

function CFaBaoAwakenPart.ctor(self, obj)
	CPageBase.ctor(self, obj)

	self.m_SelectIndex = 1
end

function CFaBaoAwakenPart.OnInitPage(self)
	self.m_FaBaoScroll = self:NewUI(1, CScrollView)
	self.m_FaBaoGrid = self:NewUI(2, CGrid)
	self.m_FaBaoClone = self:NewUI(3, CBox)

	self.m_SkillBox = self:NewUI(4, CBox)

	self.m_SkillBox.m_Icon = self.m_SkillBox:NewUI(1, CSprite)
	self.m_SkillBox.m_Name = self.m_SkillBox:NewUI(2, CLabel)
	self.m_SkillBox.m_Level = self.m_SkillBox:NewUI(3, CLabel)

	self.m_SkillEffectDesc = self:NewUI(5, CLabel)
	self.m_SkillConsumeLbl = self:NewUI(6, CLabel)
	--self.m_UpGradeLbl = self:NewUI(7, CLabel)

	self.m_Slider = self:NewUI(8, CSlider)

	self.m_ConsumeLbl = self:NewUI(9, CLabel)

	--self.m_ItemScroll = self:NewUI(10, CScrollView)
	self.m_ItemGrid = self:NewUI(11, CGrid)
	self.m_ItemClone = self:NewUI(12, CBox)

	self.m_Btn = self:NewUI(13, CButton)
	self.m_StarGrid = self:NewUI(14, CGrid)
	self.m_TipL = self:NewUI(15, CLabel)

	self.m_ConsumeNode = self:NewUI(16, CObject)
	
	self:InitContent()
end

function CFaBaoAwakenPart.OnShowPage(self)
	CPageBase.OnShowPage(self)
	
	self:Reset()
	self:RefreshFaBaolist()
	self:RefreshAwakenNode()
end

function CFaBaoAwakenPart.InitContent(self)
	self.m_ItemClone:SetActive(false)
	self.m_Btn:AddUIEvent("click", callback(self, "OnBtnClick"))
	g_FaBaoCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFaBaoEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemEvent"))

	local function init(obj, idx)
		local oStar = CSprite.New(obj)
		return oStar
	end
	self.m_StarGrid:InitChild(init)

	--self.m_UpGradeLbl:SetActive(false)
end


function CFaBaoAwakenPart.Reset(self)
	self.m_FaBaoStatus = 0 -- 0未觉醒、1可升级、2可突破
	self.m_Itemlist = nil
end

function CFaBaoAwakenPart.RefreshFaBaolist(self)
	local fabaolist = g_FaBaoCtrl:GetFaBaoOnWear()
	local dInfo = data.fabaodata.INFO
	local groupId = self.m_FaBaoGrid:GetInstanceID()

	self.m_FaBaoGrid:Clear()
	for i, v in ipairs(fabaolist) do
		local oFaBao = self.m_FaBaoGrid:GetChild(i)
		if oFaBao == nil then
			oFaBao = self.m_FaBaoClone:Clone()
			oFaBao.m_Icon = oFaBao:NewUI(1, CSprite)
			oFaBao.m_Level = oFaBao:NewUI(2, CLabel)
			oFaBao.m_Name = oFaBao:NewUI(3, CLabel)
			oFaBao.m_SelName = oFaBao:NewUI(4, CLabel)
			
			oFaBao:SetGroup(groupId)
			oFaBao:AddUIEvent("click", callback(self, "OnFaBaoSelect", i))
			oFaBao:SetActive(true)
			self.m_FaBaoGrid:AddChild(oFaBao)
		end
		local info = dInfo[v.fabao]
		oFaBao.m_Icon:SpriteItemShape(info.icon)
		oFaBao.m_Name:SetText(info.name)
		oFaBao.m_SelName:SetText(info.name)
		oFaBao.m_Level:SetText("等级: "..v.level)
	end
	self.m_FaBaoGrid:Reposition()
	self.m_FaBaoScroll:ResetPosition()

	local oFabao = self.m_FaBaoGrid:GetChild(self.m_SelectIndex)
	if not oFabao then
		oFabao = self.m_FaBaoGrid:GetChild(1)
		self.m_SelectIndex = 1
	end
	oFabao:SetSelected(true)
end

function CFaBaoAwakenPart.RefreshAwakenNode(self)
	local fabaolist = g_FaBaoCtrl:GetFaBaoOnWear()

	local sFabao = fabaolist[self.m_SelectIndex]
	local dInfo = data.fabaodata.INFO
	local fabaoInfo = dInfo[sFabao.fabao] --fabao.fabao指法宝的类型编号

	self.m_FaBaoStatus = g_FaBaoCtrl:CheckFaBaoSkillStatus(sFabao)
	-- 觉醒操作
	if self.m_FaBaoStatus == 0 then

		local skilldata = DataTools.GetFaBaoSkillData(fabaoInfo.juexing_skill)
		self.m_SkillBox.m_Icon:SpriteSkill(skilldata.icon)
		self.m_SkillBox.m_Name:SetText(skilldata.name)
		self.m_SkillBox.m_Level:SetText("等级: ".."0/"..skilldata.max_level)
		self.m_Btn:SetText("法宝觉醒")
		
		self:SetSkillInstrucion(skilldata)
	
		self.m_ConsumeLbl:SetText("觉醒消耗")

		self.m_Slider:SetActive(false)

		self.m_ConsumeNode:SetLocalPos(Vector3.zero)

		local itemlist = {}
		for i, v in ipairs(fabaoInfo.juexing_resume) do
			itemlist[#itemlist + 1] = v
		end
		
		local coin = {
			amount = fabaoInfo.juexing_resume_gold,
			itemsid = 1001, --金币
		}
		itemlist[#itemlist + 1] = coin

		self.m_Itemlist = itemlist
		self:ShowItemConsume() --觉醒消耗
		self.m_TipL:SetActive(true)

		local openLevel = fabaoInfo.juexing_open
		self.m_TipL:SetText(string.format("法宝等级达%d级", openLevel))
		self:RecycleClone()

	elseif self.m_FaBaoStatus == 1 then --觉醒升级
		
		self.m_Slider:SetActive(true)
		self.m_ConsumeNode:SetLocalPos(Vector3.New(0, -50, 0))

		local skillinfo = g_FaBaoCtrl:GetJueXingSkill(sFabao)
		local skilldata = DataTools.GetFaBaoSkillData(skillinfo.sk)

		self.m_SkillBox.m_Icon:SpriteSkill(skilldata.icon)
		self.m_SkillBox.m_Name:SetText(skilldata.name)
		local slevel = skillinfo.level or 1
		self.m_SkillBox.m_Level:SetText("等级: "..slevel.."/"..skilldata.max_level)

		self:SetSkillInstrucion(skilldata)

		self.m_ConsumeLbl:SetText("升级消耗")

		local idx = slevel + 1
		if idx >= 10 then
			idx = 10
		end

		local dInfo = data.fabaodata.JUEXING_UPGRADE[idx]
		local dExp = dInfo.exp
		local exp = skillinfo.exp or 0
		if slevel >= 10 then
			exp = dExp
		end 
		local val = exp/dExp
		self.m_Slider:SetValue(val)
		self.m_Slider:SetSliderText(exp.."/"..dExp)

		self.m_Itemlist = g_FaBaoCtrl:GetJXUpGradeConsume(skillinfo)
		self:ShowItemConsume() --觉醒技能升级消耗

		self.m_TipL:SetActive(false)
		self.m_Btn:SetText("技能升级")

		self:RecycleClone()
	else    --魂觉醒
		self.m_Slider:SetActive(false)
		self.m_ConsumeNode:SetLocalPos(Vector3.zero)
		
		local hun = g_FaBaoCtrl:GetHunJueXingInfo(sFabao)

		local sk = g_FaBaoCtrl:GetHunSkill(sFabao.fabao, hun)
		self:SetSkillInfo(sk)

		local hunInfo = data.fabaodata.HUN[hun]

		self.m_ConsumeLbl:SetText("法宝"..hunInfo.name.."觉醒消耗")

		self.m_Itemlist = hunInfo.resume
		self:ShowItemConsume()

		self.m_TipL:SetActive(true)
		self.m_TipL:SetText(string.format("法宝技能等级达%d级", hunInfo.grade))
		self.m_Btn:SetText(hunInfo.name.."觉醒")
	end

	self:RefreshStarCount(sFabao)
end

function CFaBaoAwakenPart.SetSkillInfo(self, skill)
	if type(skill) == "table" then --人魂界面特殊处理
		local sk1, sk2 = skill[1], skill[2]

		local sdata1 = DataTools.GetFaBaoSkillData(sk1)
		self.m_SkillBox.m_Icon:SpriteSkill(sdata1.icon)
		self.m_SkillBox.m_Name:SetText(sdata1.name)
		self.m_SkillBox.m_Level:SetText("")

		self.m_SkillEffectDesc:SetText(sdata1.desc)

		self:RecycleClone()

		local parent = self.m_SkillBox:GetParent()

		self.m_SkillBoxClone = self.m_SkillBox:Clone()
		self.m_SkillBoxClone.m_Icon = self.m_SkillBoxClone:NewUI(1, CSprite)
		self.m_SkillBoxClone.m_Name = self.m_SkillBoxClone:NewUI(2, CLabel)
		self.m_SkillBoxClone.m_Level = self.m_SkillBoxClone:NewUI(3, CLabel)

		local sdata2 = DataTools.GetFaBaoSkillData(sk2)
		self.m_SkillBoxClone.m_Icon:SpriteSkill(sdata2.icon)
		self.m_SkillBoxClone.m_Name:SetText(sdata2.name)
		self.m_SkillBoxClone.m_Level:SetText("")

		self.m_SkillEffectClone = self.m_SkillEffectDesc:Clone()
		self.m_SkillEffectClone:SetParent(parent)
		self.m_SkillEffectClone:SetText(sdata2.desc)
		self.m_SkillEffectClone:SetLocalPos(Vector3.New(-63, 86, 0))
		
		self.m_SkillBoxClone:SetParent(parent)
		self.m_SkillBoxClone:SetLocalPos(Vector3.New(200, 222, 0))

		self.m_SkillConsumeLbl:SetText("")
	else
		local skilldata = DataTools.GetFaBaoSkillData(skill)
		self.m_SkillBox.m_Icon:SpriteSkill(skilldata.icon)
		self.m_SkillBox.m_Name:SetText(skilldata.name)
		self.m_SkillBox.m_Level:SetText("")

		self.m_SkillEffectDesc:SetText(skilldata.desc)

		self.m_SkillConsumeLbl:SetText("")
	end
end

function CFaBaoAwakenPart.RecycleClone(self)
	if self.m_SkillBoxClone then
		self.m_SkillBoxClone:Destroy()
	end

	if self.m_SkillEffectClone then
		self.m_SkillEffectClone:Destroy()
	end
end

-- 技能说明
function CFaBaoAwakenPart.SetSkillInstrucion(self, skilldata)
	self.m_SkillEffectDesc:SetText(skilldata.desc)
	local zhenqi = skilldata.zhengqi
	if string.len(zhenqi) ~= 0 then
		self.m_SkillConsumeLbl:SetText(string.format("招式消耗：真气%d", zhenqi))
	else
		self.m_SkillConsumeLbl:SetText("")
	end
end

function CFaBaoAwakenPart.RefreshStarCount(self, fabaoInfo)
	if self.m_FaBaoStatus == 2 then
		self.m_StarGrid:SetActive(false)
		return
	else
		self.m_StarGrid:SetActive(true)
	end

	local hunData = data.fabaodata.HUN
	local skilllist = fabaoInfo.skilllist or {}
	local starCount = table.count(skilllist) - 1
	if starCount <= 0 then --未觉醒或未魂觉醒
		starCount = 0
	elseif starCount > 3 then --天地人全部觉醒
		starCount = 3
	end

	for i=1, 3 do
		local oStar = self.m_StarGrid:GetChild(i)
		oStar:SetSpriteName("h7_xing_di")
	end
	if starCount > 0 then
		for i=1, starCount do
			local oStar = self.m_StarGrid:GetChild(i)
			oStar:SetSpriteName("h7_xing")
		end
	end
end

-- 物品消耗列表
function CFaBaoAwakenPart.ShowItemConsume(self)
	if not self.m_Itemlist then
		return
	end

	self.m_ItemGrid:Clear()
	for i, v in ipairs(self.m_Itemlist) do
		local oItem = self.m_ItemGrid:GetChild(i)
		if oItem == nil then
			oItem = self.m_ItemClone:Clone()
			oItem.m_Icon = oItem:NewUI(1, CSprite)
			oItem.m_Quality = oItem:NewUI(2, CSprite)
			oItem.m_Count = oItem:NewUI(4, CLabel)
			oItem.m_Amount = oItem:NewUI(3, CLabel)

			oItem:AddUIEvent("click", callback(self, "OnItemClick", i, v.itemsid))
			oItem:SetActive(true)
			self.m_ItemGrid:AddChild(oItem)
		end
		local itemdata = DataTools.GetItemData(v.itemsid)
		oItem.m_Icon:SpriteItemShape(itemdata.icon)
		oItem.m_Quality:SetItemQuality(itemdata.quality)

		local countText
		local curAmount = g_ItemCtrl:GetBagItemAmountBySid(v.itemsid)
		local isGlod = v.itemsid == 1001

		if isGlod then
			oItem.m_Count:SetActive(false)
			curAmount = g_AttrCtrl.gold
			local sCode = ""
			local amount = v.amount
			if curAmount < amount then
				sCode = "[ffb398]"
				oItem.m_Amount:SetEffectColor(Color.RGBAToColor("cd0000"))
			else
				oItem.m_Amount:SetEffectColor(Color.RGBAToColor("003C41"))
			end
			if amount >= 10000 then
				amount = math.floor(amount/10000).."万"
			end
			oItem.m_Amount:SetText(sCode..amount)
		else
			oItem.m_Count:SetActive(true)
			oItem.m_Amount:SetEffectColor(Color.RGBAToColor("003C41"))
			if curAmount < v.amount then
				countText = "[b][ffb398]"..curAmount
				oItem.m_Count:SetEffectColor(Color.RGBAToColor("cd0000"))
			else
		        countText = "[b][0fff32]"..curAmount
		        oItem.m_Count:SetEffectColor(Color.RGBAToColor("003C41"))
			end
			oItem.m_Count:SetText(countText)
			oItem.m_Amount:SetText("/"..v.amount)
		end
	end

	self.m_ItemGrid:Reposition()
end

function CFaBaoAwakenPart.OnFaBaoSelect(self, idx)
	if self.m_SelectIndex == idx then
		return
	end
	 self.m_SelectIndex = idx

	self:RefreshAwakenNode()
end

function CFaBaoAwakenPart.OnBtnClick(self)
	local fabaolist = g_FaBaoCtrl:GetFaBaoOnWear()

	local fabao = fabaolist[self.m_SelectIndex]
	local fabaoId = fabao.id

	if self.m_FaBaoStatus == 0 then -- 觉醒操作
		netfabao.C2GSJueXingFaBao(fabaoId)
	elseif self.m_FaBaoStatus == 1 then -- 升级操作
		netfabao.C2GSJueXingUpGradeFaBao(fabaoId)
	else -- 突破操作
		local hun = g_FaBaoCtrl:GetHunJueXingInfo(fabao)
		netfabao.C2GSJueXingHunFaBao(fabaoId, hun)
	end
end

function CFaBaoAwakenPart.OnFaBaoEvent(self, oCtrl)
	if oCtrl.m_EventID == define.FaBao.Event.RefreshFaBaoInfo then
		self:RefreshAwakenNode()
	end
end

function CFaBaoAwakenPart.OnItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem then
		local sid = oCtrl.m_EventData:GetSValueByKey("sid")
		for i, v in ipairs(self.m_Itemlist) do
			if v.itemsid == sid then
				self:ShowItemConsume()
				break
			end
		end
	elseif oCtrl.m_EventID == define.Item.Event.ItemAmount then
		local sid = oCtrl.m_EventData 
		for i, v in ipairs(self.m_Itemlist) do
			if v.itemsid == sid then
				self:ShowItemConsume()
				break
			end
		end
	end
end

function CFaBaoAwakenPart.OnItemClick(self, idx, sid)
	local oItem = self.m_ItemGrid:GetChild(idx)
		
	-- if sid == 1001 then
	-- 	local args = {
	-- 		widget = oItem,
	-- 	}
	-- 	g_WindowTipCtrl:SetWindowItemTip(sid, args)
	-- else
		g_WindowTipCtrl:SetWindowGainItemTip(sid, function ()
	    local oView = CItemTipsView:GetView()
	    	UITools.NearTarget(oItem, oView.m_MainBox, enum.UIAnchor.Side.Top, Vector2.New(0, 10))
		end)
	--end
end

return CFaBaoAwakenPart