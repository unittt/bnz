local CWarriorBuffHud = class("CWarriorBuffHud", CAsynHud)

function CWarriorBuffHud.ctor(self, cb)
	CAsynHud.ctor(self, "UI/Hud/WarriorBuffHud.prefab", cb)
end

function CWarriorBuffHud.OnCreateHud(self)
	self.m_Table = self:NewUI(1, CTable)
	self.m_BuffBox = self:NewUI(2, CBox)
	self.m_FloatTable = self:NewUI(3, CTable)
	self.m_FloatBox = self:NewUI(4, CFloatBox)
	self.m_JiHuoSprite = self:NewUI(5, CSprite)
	self.m_Table:SetActive(false)
	self.m_BuffBox:SetActive(false)
	self.m_FloatTable:SetActive(false)
	self.m_FloatBox:SetActive(false)
	self.m_JiHuoSprite:SetActive(false)
	self.m_Buffs = {}
end

function CWarriorBuffHud.SetJiHuo(self, bShow)
	self.m_JiHuoSprite:SetActive(bShow)
end

function CWarriorBuffHud.OnShowDetail(self)
	local oWarrior = self:GetOwner()
	if oWarrior then
		CWarTargetDetailView:ShowView(function(oView)
			oView:SetWarrior(oWarrior)
		end)
	end
end

function CWarriorBuffHud.RefreshBuff(self, buffid, bout, level, bTips)
	local dCurBuff = self.m_Buffs[buffid]
	local iCurLevel = dCurBuff and dCurBuff.level or 0
	local iNewLevel = (bout <= 0) and 0 or (level or 0)
	local iCnt = iNewLevel - iCurLevel
	-- print("buff hud:", self:GetOwner().m_ID, buffid, iCurLevel, iNewLevel)
	if iNewLevel == 0 then
		self.m_Buffs[buffid] = nil
	else
		self.m_Buffs[buffid] = {level=level}
	end
	local lBoxes = self.m_Table:GetChildList()
	if iCnt > 0 then
		local iSilbingIndex
		for i, oBox in ipairs(lBoxes) do
			if oBox.m_BuffID == buffid then
				iSilbingIndex = i
				break
			end
		end
		for i=1, iCnt do
			bTips = bTips and (i==1 and iCurLevel==0)
			local oBox = self:CreateBox(buffid, bTips)
			self.m_Table:AddChild(oBox, iSilbingIndex)
		end
	elseif iCnt < 0 then
		local lDelList = {}
		for i, oBox in ipairs(lBoxes) do
			if oBox.m_BuffID == buffid then
				table.insert(lDelList, oBox)
				if #lDelList == math.abs(iCnt) then
					break
				end
			end
		end
		for i, oBox in ipairs(lDelList) do
			self.m_Table:RemoveChild(oBox)
		end
	end
	for i, oBox in ipairs(self.m_Table:GetChildList()) do
		if oBox.m_BuffID == buffid then
			oBox.m_BoutLabel:SetText(tostring(bout))
		end
	end
	self.m_Table:Reposition()
end


function CWarriorBuffHud.CreateBox(self, buffid, bTips)
	local oBox = self.m_BuffBox:Clone()
	oBox:SetActive(true)
	oBox.m_BuffID = buffid
	oBox.m_BoutLabel = oBox:NewUI(1, CLabel)
	oBox.m_BuffSpr = oBox:NewUI(2, CSprite)
	oBox.m_BuffSpr:SpriteBuff(buffid)
	oBox.m_BuffSpr:AddUIEvent("click", callback(self, "OnShowDetail"))
	self.m_Table:AddChild(oBox)
	local dBuff = data.buffdata.DATA[buffid]
	if bTips and dBuff and dBuff.name and dBuff.name ~= "" then
		self:AddBuffTips(dBuff.name)
	end
	return oBox
end

function CWarriorBuffHud.AddBuffTips(self, text)
	local oBox = self.m_FloatBox:Clone()
	oBox:SetActive(true)
	oBox:SetText(text)
	oBox:SetTimer(2, callback(self, "OnTimerUp"))
	self.m_FloatTable:AddChild(oBox)
	local v3 = oBox:GetLocalPos()
	oBox:SetLocalPos(Vector3.New(v3.x, v3.y-20, v3.z))
	oBox:SetAsFirstSibling()
end

function CWarriorBuffHud.OnTimerUp(self, oBox)
	self.m_FloatTable:RemoveChild(oBox)
	self.m_FloatTable:Reposition()
end

function CWarriorBuffHud.Recycle(self)
	self.m_Table:Clear()
	self:SetJiHuo(false)
	self.m_Wid = nil
	self.m_Buffs = {}
end


return CWarriorBuffHud