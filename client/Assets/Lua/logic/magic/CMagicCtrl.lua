local CMagicCtrl = class("CMagicCtrl")
define.Magic = {
	Defend_ID = 102,
	Action = {
		Attack = 1,
		Seal = 2,
		Assist = 3,
		Cure = 4,
	},
	Target = {
		Ally = 1,
		Enemy = 2,
		Self = 3,
		AllyNotSelf = 4,
	},
	Status = {
		Alive = 1,
		Died = 2,
		All = 3,
	},
	SpcicalID = {
		GoBack = 99,
	}
}

function CMagicCtrl.ctor(self)
	self.m_Units = {}
	self.m_CurUnitIdx = 0
	self.m_DontDestroyEffects = {}
	self.m_CalcPosObject = CObject.New(UnityEngine.GameObject.New("CalcPosObject"))
end

function CMagicCtrl.ResetCalcPosObject(self)
	self.m_CalcPosObject:SetParent(nil, false)
	self.m_CalcPosObject:SetPos(Vector3.zero)
	self.m_CalcPosObject:SetLocalEulerAngles(Vector3.zero)
end

--requireddata 必须传的数据
function CMagicCtrl.NewMagicUnit(self, id, shape, index, requireddata, isPursued)
	local oWarrior = getrefobj(requireddata.refAtkObj)
	local oWarriorName = oWarrior and oWarrior:GetName() or "警告:没有名字"
	print(string.format("<color=#F75000> >>> .%s | %s </color>", "NewMagicUnit", "加载技能"), string.format("Name：%s | ID：%s | Shape：%s | Index：%s", oWarriorName, id, shape, index))
	id = id or 1
	shape = shape or 1110
	index = index or 1
	local dFileData = self:GetFileData(id, shape, index)
	if not dFileData then
		printerror("错误：默认法术文件都没有")
		return
	end
	
	self.m_CurUnitIdx = self.m_CurUnitIdx + 1
	local oUnit = CMagicUnit.New(self.m_CurUnitIdx, shape)
	--TODO:追击表现待修改，先置false
	oUnit.m_IsPursued = false--isPursued
	oUnit:SetMagicIDAndIdx(tonumber(id), tonumber(index))
	oUnit:SetRequiredData(requireddata)
	oUnit:ParseFileDict(dFileData, isPursued)
	self.m_Units[self.m_CurUnitIdx] = oUnit
	return oUnit
end

function CMagicCtrl.GetMagicUnit(self, id)
	return self.m_Units[id]
end

function CMagicCtrl.GetMagcAnimStartTime(self, id, shape, index)
	local dFile = self:GetFileData(id, shape, index)
	return dFile.magic_anim_start_time
end

function CMagicCtrl.GetMagcAnimEndTime(self, id, shape, index)
	local dFile = self:GetFileData(id, shape, index)
	return dFile.magic_anim_end_time
end

function CMagicCtrl.TryGetFile(self, id, shape, index)
	-- local s = string.format("magic_%d_%d_%d", id, shape, index)
	local s = string.format("magic_%d", id)
	if shape then
		s = s .. "_" .. shape
	end
	if index then
		s = s .. "_" .. index
	end
	local b, m = pcall(require, "logic.magic.magicfile." .. s)
	if b then
		return m.DATA
	end
end

function CMagicCtrl.GetFileData(self, id, shape, index)
	local dFile = self:TryGetFile(id, shape, index)
	if not dFile then
		if tostring(id) == "101" then
			-- 当ID=101（普通攻击）直接读默认
			dFile = self:TryGetFile(id, shape)
			if not dFile then
				dFile = self:TryGetFile(101, 1110)
			end
		else

			-- 向下遍历查找对应的技能
			local function getFile(iid, ishape, iindex)
				local file = nil
				local idx = iindex
				while (idx > 0) do
					file = self:TryGetFile(iid, ishape, idx)
					if file then
						return file
					end
					idx = idx - 1
				end
				if not file then
					while (iindex > 0) do
						file = self:TryGetFile(iid, nil, iindex)
						if file then
							return file
						end
						iindex = iindex - 1
					end
				end
			end

			dFile = getFile(id, shape, index)
			if not dFile then
				local name = string.format("maigc_%s_%s", id, shape)
				if index then
					name = name .. "_" .. index
				end
				printerror(string.format("未找到法术文件:%s | 开始加载通用法术:magic_1_1_1 | 缺失法术@客户端沟通后通知美术支持", name))
				dFile = self:TryGetFile(1, 1, 1)
			end
		end
	end
	return dFile
end

function CMagicCtrl.Update(self, dt)
	for id, oUnit in pairs(self.m_Units) do
		if oUnit:IsGarbage() then
			self.m_Units[id] = nil
		else
			local bSuc, ret = xxpcall(oUnit.Update, oUnit, dt)
			if not bSuc then
				self.m_Units[id] = nil
			end
		end
	end
end

function CMagicCtrl.Clear(self, sEnv)
	for id, oUnit in pairs(self.m_Units) do
		if oUnit.m_RunEnv == sEnv then
			oUnit:ClearUnit()
			self.m_Units[id] = nil
		end
	end
	local list = self.m_DontDestroyEffects[sEnv]
	if list and next(list) ~= nil then
		for i, oEffect in ipairs(list) do
			oEffect:Destroy()
		end
		self.m_DontDestroyEffects[sEnv] = nil
	end
end

function CMagicCtrl.AddDontDestroyEffect(self, sEnv, oEff)
	table.safeinsert(self.m_DontDestroyEffects, oEff, sEnv)
end

function CMagicCtrl.IsExcuteMagic(self)
	for id, oUnit in pairs(self.m_Units) do
		if not oUnit:IsGarbage() and oUnit:IsRunning() then
			return true
		end
	end
	return false
end

return CMagicCtrl