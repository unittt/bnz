local CFaBaoCtrl = class("CFaBaoCtrl", CCtrlBase)

function CFaBaoCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:Clear()
end

function CFaBaoCtrl.Clear(self)
	self.m_FaBaoList = {}
end

CFaBaoCtrl.m_Attr = {
	physique = "体质",
	magic = "魔力", 
	strength = "力量", 
	endurance = "耐力", 
	agility = "敏捷", 
}

function CFaBaoCtrl.GS2CAllFaBao(self, list)
	self.m_FaBaoList = list
end

function CFaBaoCtrl.GS2CRefreshFaBao(self, fabao)
	-- todo(是否需要区分穿戴和未穿戴)
	for i, v in ipairs(self.m_FaBaoList) do
		if v.id == fabao.id then
			self.m_FaBaoList[i] = table.copy(fabao) 
			break
		end
	end
	self:OnEvent(define.FaBao.Event.RefreshFaBaoInfo, fabao)
end

function CFaBaoCtrl.GS2CWieldFaBao(self, pbdata)

	local fabao
	for i, v in ipairs(self.m_FaBaoList) do --首先根据id确定法宝类型
		if v.id == pbdata.wield_id then
			fabao = v.fabao
			break
		end
	end

	for i, v in ipairs(self.m_FaBaoList) do
		if v.fabao == fabao then
			v.equippos = 0   --将同类型法宝位置都设为0
		end
	end

	for i, v in ipairs(self.m_FaBaoList) do
		if v.id == pbdata.wield_id then
			v.equippos = pbdata.equippos --为刚穿戴上的法宝位置赋值
			break
		end
	end

	self:OnEvent(define.FaBao.Event.RefreshFaBaolist)
end

function CFaBaoCtrl.GS2CUnWieldFaBao(self, unwield_id)
	for i, v in ipairs(self.m_FaBaoList) do
		if v.id == unwield_id then
			v.equippos = 0
			break
		end
	end
	self:OnEvent(define.FaBao.Event.RefreshFaBaolist)
end

function CFaBaoCtrl.GS2CAddFaBao(self, fabao)
	table.insert(self.m_FaBaoList, fabao)
	self:OnEvent(define.FaBao.Event.RefreshFaBaolist)
	self:OnEvent(define.FaBao.Event.RefrershFaBaoPatch)
end

function CFaBaoCtrl.GS2CRemoveFaBao(self, id)
	for i, v in ipairs(self.m_FaBaoList) do
		if v.id == id then
			table.remove(self.m_FaBaoList, i)
			break
		end
	end
	self:OnEvent(define.FaBao.Event.RefreshFaBaolist)
end

-- 主界面按钮是否开启
function CFaBaoCtrl.IsShowMainBtn(self)
	local opendata = DataTools.GetViewOpenData(define.System.FaBao)
	return g_AttrCtrl.grade >= opendata.p_level
end

-- 可以穿戴的数量
function CFaBaoCtrl.GetFaBaoWearCount(self)
	local list = {}
	local equipdata = data.fabaodata.EQUIP
	for k, v in pairs(equipdata) do
		table.insert(list, v)
	end
	table.sort(list, function(a, b)
		return a.grade < b.grade
	end)
	return list
end

function CFaBaoCtrl.GetFaBaoList(self)
	return self.m_FaBaoList
end

-- 法宝总评分
function CFaBaoCtrl.GetFaBaoScore(self)
	local score = 0
	local fabaolist = self:GetFaBaoOnWear()
	for i, v in ipairs(fabaolist) do
		score = score + v.score
	end
	return score
end

-- 法宝当前等级的最大经验
function CFaBaoCtrl.GetFaBaoMaxExp(self, grade)
	local uData = data.fabaodata.UPGRADE
	local maxLevel = table.maxn(uData)
	local mGrade = grade + 1
	if mGrade > maxLevel then
		mGrade = maxLevel
	end

	local dExp = uData[mGrade]
	return dExp.exp, maxLevel
end

function CFaBaoCtrl.GetJXUpGradeConsume(self, skillInfo)
	local itemlist = {10157}
	local level = math.clamp(skillInfo.level + 1, 1, 10)
	local exp = skillInfo.exp or 0
	local dExp = data.fabaodata.JUEXING_UPGRADE[level].exp

	-- 根据所需经验，以及每个道具可提供经验，计算所需道具数量
	local list = {}
	for i, v in ipairs(itemlist) do
		local dItem = DataTools.GetItemData(v)
	    local iExp = string.eval(dItem.item_formula, {})

	    local temp = Mathf.Abs(dExp-exp)
	    local amount = math.ceil(temp/iExp)
	    local item = {}
	    item.itemsid = v
	    item.amount = amount
	    table.insert(list, item)
	end
	return list
end

-- 培养标签红点
function CFaBaoCtrl.GetFaBaoPromoteRedPot(self)
	local bRed = false
	local fabaolist = self:GetFaBaoOnWear()
	if #fabaolist > 0 then
		local itemCount1 = g_ItemCtrl:GetBagItemAmountBySid(10155)
		local itemCount2 = g_ItemCtrl:GetBagItemAmountBySid(10156)
		bRed = itemCount1 >= 10 or itemCount2 >= 10
	end
	return bRed
end

-- 觉醒标签红点
function CFaBaoCtrl.GetFaBaoAwakenRedPot(self)
	local fabaolist = self:GetFaBaoOnWear()
	for i, v in ipairs(fabaolist) do
		local sklist = v.skilllist or {}
		if v.level >= 5 or #sklist > 0 then --是否觉醒或觉醒技能升级
			local itemCount = g_ItemCtrl:GetBagItemAmountBySid(10157)
			return itemCount >= 5	
		end
		local status = self:CheckFaBaoSkillStatus(v) --是否魂觉醒
		if status == 2 then
			local itemCount = g_ItemCtrl:GetBagItemAmountBySid(10158)
			return itemCount >= 5
		end
	end
	return false
end

--获取法宝某个属性的提升次数
function CFaBaoCtrl.GetFaBaoPromote(self, id, attr)
	for i, v in ipairs(self.m_FaBaoList) do
		if v.id == id then
			if v.promotelist then
				for _, atr in ipairs(v.promotelist) do
					if atr.attr == attr then
						return atr.promote or 0
					end
				end
			else
				return 0
			end
		end
	end
	return 0
end

-- 获取法宝属性
function CFaBaoCtrl.GetFaBaoAttrInfo(self, id)
	local sFabao = self:GetFaBaoById(id)

	local attrDict = {}
	-- 默认属性
	local dInfo = data.fabaodata.INFO[sFabao.fabao]
	local dXianLing = data.fabaodata.XIANLING

	for k, v in pairs(dXianLing) do
		local promote = self:GetFaBaoPromote(id, k)
		local val = dInfo[k] + v.value * promote --基础属性加上提升的属性
		attrDict[k] = val
	end

	return attrDict
end

-- 获取所有已佩戴法宝的全部属性
function CFaBaoCtrl.GetAllFabaoAttrInfo(self)
	local dXianLing = data.fabaodata.XIANLING
	local fabaolist = self:GetFaBaoOnWear()
	local attrDict = {}

	--没有配戴法宝，属性全为 0 
	if table.count(fabaolist) == 0 then 
		for k, v in pairs(dXianLing) do
			attrDict[k] = 0
		end
		return attrDict
	end 

	-- 遍历所有已佩戴法宝进行属性累加
	for i, v in ipairs(fabaolist) do
		local attr = self:GetFaBaoAttrInfo(v.id)
		for k, v in pairs(attr) do
			if not attrDict[k] then 
				attrDict[k] = v
			else
				attrDict[k] = attrDict[k] + v
			end
		end
	end

	return attrDict
end

function CFaBaoCtrl.GetJueXingConsume(self, fabao) --参数为法宝类型
	local dInfo = data.fabaodata.INFO[fabao]
	local consume = dInfo.juexing_resume[1]
	return consume.itemsid, consume.amount
end

function CFaBaoCtrl.GethunJueXingConsume(self, hun) --参数为魂觉醒类型
	local dHun = data.fabaodata.HUN[hun]
	local consume = dHun.resume[1]
	return consume.itemsid, consume.amount
end

-- -- 获取已佩戴法宝中可用的主动技能
-- function CFaBaoCtrl.GetFaBaoActiveSkill(self)
-- 	local dInfo = data.fabaodata.INFO
-- 	local list = {}

-- 	local fabaolist = self:GetFaBaoOnWear()
-- 	for i, fabao in ipairs(fabaolist) do
-- 		local sklist = fabao.skilllist or {}
-- 		for _, v in ipairs(sklist) do
-- 			local dData = DataTools.GetMagicData(v.sk)
-- 			if dData.is_active then --是否为主动技能
-- 				table.insert(list, v.sk)
-- 			end
-- 		end
-- 	end

-- 	return list
-- end

-- 获取已佩戴法宝的技能信息(包括是否觉醒)
function CFaBaoCtrl.GetJueXingSkillInfo(self, fabaoId)
	local dInfo = data.fabaodata.INFO

	local fabaolist = {}
	local id = fabaoId or 0
	local fabao = self:GetFaBaoById(id)
	--if fabao and fabao.equippos > 0 then  --有id时选中指定法宝
	if fabao then
		fabaolist[#fabaolist + 1] = fabao
	else  --没有时选全部已穿戴法宝
		fabaolist = self:GetFaBaoOnWear()
	end

	local skillInfo = {}

	for i, v in ipairs(fabaolist) do
		local info = {}
		info.fabao = v.fabao
		info.sk = dInfo[v.fabao].juexing_skill
		info.level = self:GetFaBaoSkillLevel(info.sk, v.id)
		local ret = self:CheckSkillCanUse(info.sk, v.id)
		if ret then
			info.bUse = 1 --已觉醒
		else
			info.bUse = 0 --未觉醒
		end
		table.insert(skillInfo, info)
	end

	table.sort(skillInfo, function(a, b)
		return a.bUse > b.bUse
	end)

	return skillInfo
end

-- 获取某个法宝的全部突破(魂)技能
function CFaBaoCtrl.GetHunSkillInfo(self, id)
	local sFabao = self:GetFaBaoById(id)
	local hunSkill = {"tianhun_skill", "dihun_skill", "renhun_skill"}
	local sklist = {}

	local dInfo = data.fabaodata.INFO[sFabao.fabao]
	for i, v in ipairs(hunSkill) do
		local sk = dInfo[v]
		if type(sk) == "table" then
			for i, val in ipairs(sk) do
				table.insert(sklist, val)
			end
		else
			table.insert(sklist, sk)
		end
	end

	return sklist
end

-- 魂技能信息
function CFaBaoCtrl.GetAllHunSkillInfo(self, fabaoId)
	local dInfo = data.fabaodata.INFO

	local fabaolist = {}
	local id = fabaoId or 0
	local fabao = self:GetFaBaoById(id)
	--if fabao and fabao.equippos > 0 then  --有id时选中指定法宝
	if fabao then
		fabaolist[#fabaolist + 1] = fabao
	else  --没有时选全部已穿戴法宝
		fabaolist = self:GetFaBaoOnWear()
	end
	
	local list = {}
	for i, v in ipairs(fabaolist) do
		local sklist = self:GetHunSkillInfo(v.id)
		for i, sk in ipairs(sklist) do
			local info = {}
			info.sk = sk
			info.fabao = v.fabao
			info.pos = v.equippos
			info.level = self:GetFaBaoSkillLevel(sk, v.id)
			local ret = self:CheckSkillCanUse(info.sk, v.id)
			if ret then
				info.bUse = 1 --已突破
			else
				info.bUse = 0 --未突破
			end
			table.insert(list, info)
		end
	end

	--将已突破的和未突破的分在两个列表，分别排序，再连接列表
	local jueXing = {}
	local noJueXing = {}

	for i, v in ipairs(list) do
		if v.bUse == 1 then
			table.insert(jueXing, v)
		else
			table.insert(noJueXing, v)
		end
	end

	table.sort(jueXing, function(a, b)
		return a.pos < b.pos
	end)

	table.sort(noJueXing, function(a, b)
		return a.pos < b.pos
	end)

	for i, v in ipairs(noJueXing) do
		jueXing[#jueXing + 1] = v
	end

	return jueXing
end

-- 法宝等级
function CFaBaoCtrl.GetFaBaoSkillLevel(self, sk, id)
	local fabaoInfo = self:GetFaBaoById(id)

	if not fabaoInfo.skilllist then
		return 0
	end

	for i, v in ipairs(fabaoInfo.skilllist) do
		if v.sk == sk then
			return v.level
		end
	end
	return 0
end

-- 检测法宝中某技能是否觉醒/突破
function CFaBaoCtrl.CheckSkillCanUse(self, sk, fabaoid)
	local fabaoInfo = self:GetFaBaoById(fabaoid)

	if not fabaoInfo.skilllist then
		return false
	end

	for i, v in ipairs(fabaoInfo.skilllist) do
		if v.sk == sk then
			return true
		end
	end

	return false
end

--判断将要进行的操作
function CFaBaoCtrl.CheckFaBaoSkillStatus(self, fabaoinfo)
	local status = 0  -- 0法宝觉醒  1觉醒升级  2魂觉醒 
	local skilllist = fabaoinfo.skilllist or {}
	local count = table.count(skilllist)
	if count == 0 then
		return status
	end	

	local skillInfo = self:GetJueXingSkill(fabaoinfo)
	local hunInfo = data.fabaodata.HUN

	--根据法宝技能的等级进行判断
	for i, v in ipairs(hunInfo) do
		if skillInfo.level == v.grade then --等级满足魂觉醒条件
			if count <= v.hun then --当前等级是否已魂觉醒过了, true为没有
				status = 2
				return status
			end
		end
	end
	
	return 1
end

-- 觉醒技能信息
function CFaBaoCtrl.GetJueXingSkill(self, fabaoInfo)
	local juexingSkill = data.fabaodata.INFO[fabaoInfo.fabao].juexing_skill
	for i, v in ipairs(fabaoInfo.skilllist) do
		if v.sk == juexingSkill then
			return v
		end
	end	
end

function CFaBaoCtrl.GetHunSkill(self, fabao, hun)
	local dInfo = data.fabaodata.INFO[fabao]
	if hun == 1 then
		return dInfo.tianhun_skill
	elseif hun == 2 then
		return dInfo.dihun_skill
	elseif hun == 3 then
		return dInfo.renhun_skill
	end
end

-- 用于计算下一个要觉醒的魂技能, skilllist数量与hunid相对应, 返回值count即hunid
function CFaBaoCtrl.GetHunJueXingInfo(self, fabaoinfo)
	local skilllist = fabaoinfo.skilllist or {}
	local count = table.count(skilllist)
	if count >= 3 then
		count = 3
	end
	return count
end

-- 已穿戴法宝
function CFaBaoCtrl.GetFaBaoOnWear(self)
	local list = {}
	for i, v in ipairs(self.m_FaBaoList) do
		if v.equippos > 0 then
			table.insert(list, v)
		end
	end
	table.sort(list, function(a, b)
		return a.equippos < b.equippos
	end)
	return list
end

-- 未穿戴法宝
function CFaBaoCtrl.GetFaBaoUnWear(self)
	local list = {}
	for i, v in ipairs(self.m_FaBaoList) do
		if v.equippos == 0 then
			table.insert(list, v)
		end
	end
	return list
end

function CFaBaoCtrl.GetFaBaoById(self, id)
	for i, v in ipairs(self.m_FaBaoList) do
		if v.id == id  then
			return v
		end
	end
end

function CFaBaoCtrl.GetFaBaoByPos(self, pos)
	for i, v in ipairs(self.m_FaBaoList) do
		if v.equippos == pos then
			return v
		end
	end
end

return CFaBaoCtrl