local CSummonWarehouseBox = class("CSummonWarehouseBox", CBox)

function CSummonWarehouseBox.ctor(self, obj)
	-- body
	CBox.ctor(self, obj)
	self.m_GradeTitle  = self:NewUI(1, CLabel)
	self.m_Icon        = self:NewUI(2, CSprite)
	self.m_PetTag      = self:NewUI(3, CSprite)
	self.m_PetNameLab  = self:NewUI(4, CLabel)
	self.m_PetGradeLab = self:NewUI(5, CLabel)
	self.m_PetScoreLab = self:NewUI(6, CLabel)
	self.m_SkillCntLab = self:NewUI(7, CLabel)
	self.m_PetLevelLab = self:NewUI(8, CLabel)
	self.m_LockPart    = self:NewUI(9, CBox)
	self.m_LockLab     = self:NewUI(10 ,CLabel)
	self.m_CostSpr     = self:NewUI(11, CLabel)
end

function CSummonWarehouseBox.SetSummonBoxData(self, petinfo , lockbox)
	-- body
	-- 1 含有宠物，2 空格子， 3 需要解锁
	if petinfo then
		self.data = petinfo
		self.lock = define.Summon.Grid.SummonBox
	else
		if lockbox then
			self.lock = define.Summon.Grid.LockBox
		else
			self.lock = define.Summon.Grid.EmptyBox
		end
	end
	-- 解锁
	if self.lock == define.Summon.Grid.LockBox then
		self.m_LockPart:SetActive(true)
		self.m_LockLab:SetActive(false)
		self.m_CostSpr:SetActive(false)
		self.m_PetScoreLab:SetActive(false)
		self.m_GradeTitle:SetActive(false)
		self.m_PetTag:SetActive(false)
		self:AddUIEvent("click", callback(self, "OnLockSize"))
		self.m_Icon:AddUIEvent("click", callback(self, "OnLockSize"))
		return
	end
	-- 空格
	if self.lock == define.Summon.Grid.EmptyBox then 
		self.m_Icon:SetActive(false)
		self.m_GradeTitle:SetActive(false)
		self.m_PetTag:SetActive(false)
		self:AddUIEvent("click", callback(self, "OnSelectSummon"))
		return
	end
	-- 含有宠物
	if self.lock == define.Summon.Grid.SummonBox  then
		self.m_Icon:SpriteAvatar(petinfo.model_info.shape)
		self.m_Icon:MakePixelPerfect()
		local PetTypeInfo = data.summondata.SUMMTYPE
		self.m_PetTag:SetSpriteName( PetTypeInfo[petinfo.type].icon)
		self.m_PetNameLab:SetText(petinfo.name)
		self.m_PetScoreLab:SetText("("..petinfo.summon_score..")")
		local grd =""
		for i=1,#petinfo.rank  do
			grd = grd.."#score_"..string.lower(string.sub(petinfo.rank,i,i))
		end
		self.m_PetGradeLab:SetText(grd)
		local equipskillcount = 0
		if petinfo.equipinfo then
			for i,v in ipairs(petinfo.equipinfo) do
				if v. equip_info and v. equip_info.skills then
					equipskillcount = equipskillcount + table.count(v. equip_info.skills)
				end
			end

		end
		self.m_SkillCntLab:SetText(table.count(petinfo.skill)+equipskillcount+table.count(petinfo.talent).."个\n技能")
		self.m_PetLevelLab:SetText(petinfo.grade.."级")
		self:AddUIEvent("click", callback(self, "OnSelectSummon"))
	end

end

function CSummonWarehouseBox.OnSelectSummon(self)

	g_SummonCtrl.m_CKChooseSum = self.data

end

function CSummonWarehouseBox.OnLockSize(self)
	-- body
	local costinfo = data.globaldata.SUMMONCK[1].extend_ck_cost[g_SummonCtrl.m_CKExtSize - 3]
	local str = ""
	if costinfo.id == 1 then
		str = "金币"
	elseif costinfo.id == 2 then
		str = "银币"
	elseif costinfo.id == 3 then
		str = "元宝"
	end
	local okCb = function()
		if costinfo.id == 2 then
			if g_AttrCtrl.silver < costinfo.count then
				g_QuickGetCtrl:CheckLackItemInfo({
		            coinlist = {{sid = 1002, amount = costinfo.count, count = g_AttrCtrl.silver}},
		            exchangeCb = function()
		                netsummon.C2GSExtendSummonCkSize()
		            end
		        })
		        return
		    end
	    end
	    netsummon.C2GSExtendSummonCkSize()
    end
	local windowConfirmInfo = {
		title = "提示",
        msg = "是否消耗"..costinfo.count..str.."开启一格宠物仓库空间?",
        okCallback = okCb,
        pivot = enum.UIWidget.Pivot.Center  
    }
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)

end

return CSummonWarehouseBox