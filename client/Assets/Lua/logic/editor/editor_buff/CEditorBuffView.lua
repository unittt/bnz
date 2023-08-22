local CEditorBuffView = class("CEditorBuffView", CViewBase)

function CEditorBuffView.ctor(self, cb)
	CViewBase.ctor(self, "UI/_Editor/EditorBuff/EditorBuffView.prefab", cb)
	self.m_DepthType = "Base"
	--
	config = require "logic.editor.editor_buff.editor_buff_config"
	self:RedefineFunc()
end

function CEditorBuffView.OnCreateView(self)
	self.m_SaveBtn = self:NewUI(1, CButton)
	self.m_DelBtn = self:NewUI(2, CButton)
	self.m_ArgBoxTable = self:NewUI(3,CTable)
	self.m_BuffTable = self:NewUI(4, CTable)
	self.m_BuffButton = self:NewUI(5, CButton, true, false)
	self.m_SaveData = datauser.warbuffdata.DATA
	self.m_CurBuff = {}
	self.m_ArgBoxDict = {}
	self:InitContent()
end

function CEditorBuffView.InitContent(self)
	local lKey = {"buff_id", "path", "height","pos", "add_cnt", "mat_path", "node"}
	local function initSub(obj, idx)
		local oBox = CEditorNormalArgBox.New(obj)
		local k = lKey[idx]
		local oArgInfo = config.arg.template[k]
		oBox:SetArgInfo(oArgInfo)
		oBox:SetValueChangeFunc(callback(self, "OnArgChange", oArgInfo.change_refresh))
		self.m_ArgBoxDict[k] = oBox
		return oBox
	end
	self.m_ArgBoxTable:InitChild(initSub)
	self.m_SaveBtn:AddUIEvent("click", callback(self, "OnSave"))
	self.m_DelBtn:AddUIEvent("click", callback(self, "OnDel"))
	self.m_BuffButton:SetActive(false)
	local dLast = IOTools.GetClientData("editor_buff")
	if dLast and dLast.buff_info then
		self.m_CurBuff = dLast.buff_info
	end
	self:RefreshWar()
	self:RefreshBuffTable()
end

function CEditorBuffView.OnArgChange(self, ifalg, key)
	local newVal = self.m_ArgBoxDict[key]:GetValue()
	self.m_CurBuff[key] = newVal
	local dLast = IOTools.GetClientData("editor_buff") or {}
	dLast["buff_info"] = self.m_CurBuff
	IOTools.SetClientData("editor_buff", dLast)
	self:DelayRefresh()
end

function CEditorBuffView.RefreshWar(self)
	warsimulate.Start(1, 1110, 1)
end

function CEditorBuffView.RedefineFunc(self)
	CWarCtrl.GetRoot=function(o)
		if not o.m_Root then
			o.m_Root = CWarRoot.New()
			o.m_Root:SetPos(Vector3.New(0, -1.27, 0))
		end
		return o.m_Root
	end

	CWarBuff.GetData = function()
		return self.m_CurBuff
	end

	local function nilfunc() end
	CWarOrderCtrl.Bout = nilfunc
	CWarMainView.ShowView = nilfunc
end

function CEditorBuffView.OnHideView(self)
	local oCam = g_CameraCtrl:GetWarCamera()
	oCam:SetRect(UnityEngine.Rect.New(0, 0, 1, 1))
end

function CEditorBuffView.OnShowView(self)
	local oCam = g_CameraCtrl:GetWarCamera()
	oCam:SetRect(UnityEngine.Rect.New(1-780/1024, 0, 780/1024, 650/768))
end


function CEditorBuffView.RefreshBuffTable(self)
	self.m_BuffTable:Clear()
	local list = table.keys(self.m_SaveData)
	table.sort(list)
	for i, id in ipairs(list) do
		local oBtn = self.m_BuffButton:Clone(false)
		oBtn.m_ID = id
		oBtn:SetText(tostring(id))
		oBtn:SetActive(true)
		oBtn:SetGroup(self:GetInstanceID())
		oBtn:AddUIEvent("click", callback(self, "SelectBtn"))
		if oBtn.m_ID == self.m_CurBuff.buff_id then
			self:SelectBtn(oBtn)
		end
		self.m_BuffTable:AddChild(oBtn)
	end
end

function CEditorBuffView.SelectBtn(self, oBtn)
	oBtn:SetSelected(true)
	self.m_CurBuff = self.m_SaveData[oBtn.m_ID]
	self.m_CurBuff.buff_id = oBtn.m_ID
	-- self.m_ArgBoxDict["add_cnt"]:SetValue(1,true)
	-- self.m_ArgBoxDict["mat_path"]:SetValue("",true)
	for k,v in pairs(self.m_ArgBoxDict) do
		v:ClearInput()
	end
	for k, v in pairs(self.m_CurBuff) do
		local oBox = self.m_ArgBoxDict[k]
		oBox:SetValue(v, true)
	end
	local oBox = self.m_ArgBoxDict["buff_id"]
	oBox:SetValue(oBtn.m_ID, true)
	self:DelayRefresh()
end

function CEditorBuffView.OnSave(self)
	local d = self.m_CurBuff
	if not d or not d.buff_id then
		return
	end
	self.m_SaveData[d.buff_id] = {
		path = d.path,
		height = d.height,
		pos = d.pos,
		mat_path = d.mat_path,
		add_cnt = d.add_cnt,
		node = d.node,
	}

	self:RefreshBuffTable()
	self:DataToFile()
end

function CEditorBuffView.OnDel(self)
	local d = self.m_CurBuff
	self.m_SaveData[d.buff_id] = nil
	self:RefreshBuffTable()
	self:DataToFile()
end

function CEditorBuffView.DataToFile(self)
	local s = table.dump(self.m_SaveData, "DATA")
	local s = "module(...)\n"..s
	local path = IOTools.GetAssetPath("/Lua/logic/datauser/warbuffdata.lua")
	IOTools.SaveTextFile(path, s)
end

function CEditorBuffView.DelayRefresh(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
	end
	self.m_Timer = Utils.AddTimer(callback(self, "RefeshBuff"), 0, 0)
end

function CEditorBuffView.RefeshBuff(self)
	local d = self.m_CurBuff
	if d.buff_id and d.height and d.pos and d.path then
		d.add_cnt = d.add_cnt or 1
		for i, oWarrior in pairs(g_WarCtrl:GetWarriors()) do
			oWarrior:ClearBuff()
			oWarrior:RefreshBuff(d.buff_id, 1, d.add_cnt)
			break
		end
	end
	self.m_Timer = nil
end


return CEditorBuffView