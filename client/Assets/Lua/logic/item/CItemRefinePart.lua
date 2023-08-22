local CItemRefinePart = class("CItemRefinePart", CPageBase)

function CItemRefinePart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.ItemIcon = {"h7_wuqi","h7_maozi","h7_yifu","h7_shoushi","h7_toushi","h7_xiezi"}
end

function CItemRefinePart.OnInitPage(self)
	self.m_RefineBoxGrid = self:NewUI(1, CGrid)
	self.m_RefineDetailBoxClone = self:NewUI(2, CItemRefineDetailBox)
	self.m_OneKeyRefineBtn = self:NewUI(3, CButton)
	self.m_OneKeyGainBtn = self:NewUI(4, CButton)
	self.m_RefineValueCntL = self:NewUI(6, CLabel)
	self.m_AddRefineValueBtn = self:NewUI(7, CButton)
	self.m_TipBtn  = self:NewUI(8, CButton)
	self:InitContent()
end

function CItemRefinePart.InitContent(self)
	self.m_RefineDetailBoxClone:SetActive(false)
	self.m_TipBtn:AddUIEvent("click", callback(self, "OnTipBtn"))
	self.m_OneKeyRefineBtn:AddUIEvent("click", callback(self, "OnClickOneKeyRefine"))
	self.m_OneKeyGainBtn:AddUIEvent("click", callback(self, "OnClickOneKeyGain"))
	self.m_AddRefineValueBtn:AddUIEvent("click", callback(self, "OnClickAddRefineValue"))

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))

	self:RefreshRefineValue()
end

function CItemRefinePart.OnShowPage(self)
	g_ItemCtrl:RefreshRefineRedPoint(false)
	netvigor.C2GSOpenVigorChange()
end

function CItemRefinePart.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshAllRefineInfo then
		self:RefreshRefineGrid()
	end
end

function CItemRefinePart.OnCtrlAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		if oCtrl.m_EventData.dAttr.vigor then
			self:RefreshRefineValue()
		end
	end
end

--------------------UI create or refresh------------------------------
function CItemRefinePart.RefreshRefineGrid(self)
	-- self.m_RefineBoxGrid:Clear()
	local list = {}
	self.m_MinCost = 99999999
	for i,dRefine in ipairs(data.vigodata.DATA) do
		local oBox = self.m_RefineBoxGrid:GetChild(i)
		if not oBox then
			oBox = self.m_RefineDetailBoxClone:Clone()
			self.m_RefineBoxGrid:AddChild(oBox)
			oBox:SetActive(true)
		end
		oBox:SetRefineType(dRefine.id)
		self.m_MinCost = math.min(dRefine.cost, self.m_MinCost)
	end
	self.m_RefineBoxGrid:Reposition()
end

function CItemRefinePart.RefreshRefineValue(self)
	self.m_RefineValueCntL:SetText(g_AttrCtrl.vigor)
end

--------------------UI click event------------------------------------
function CItemRefinePart.OnClickOneKeyRefine(self)
	if not self:CheckOneKeyRefine() then
		g_NotifyCtrl:FloatMsg("请先选中需要炼制的资源")
		return
	end
	if g_AttrCtrl.vigor < self.m_MinCost then
		g_NotifyCtrl:FloatMsg("精气不足150点, 请先补充")
		return
	end
	if not g_ItemCtrl:HasEmptyRefineBox() then
		g_NotifyCtrl:FloatMsg("暂无可炼制格子，请耐心等待")
		return
	end
	netvigor.C2GSVigorChangeList()
end

function CItemRefinePart.OnClickOneKeyGain(self)
	netvigor.C2GSVigorChangeALLProducts()
end

function CItemRefinePart.OnClickAddRefineValue(self)
	CItemBatchRefineView:ShowView()
end

function CItemRefinePart.OnTipBtn(self)
	local Id = define.Instruction.Config.ItemRefine
	if data.instructiondata.DESC[Id]~=nil then

	local Content = {
		 title = data.instructiondata.DESC[Id].title,
		  desc = data.instructiondata.DESC[Id].desc
		}
		g_WindowTipCtrl:SetWindowInstructionInfo(Content)
	end

end

function CItemRefinePart.CheckOneKeyRefine(self)
	local list = self.m_RefineBoxGrid:GetChildList()
	for i,oBox in ipairs(list) do
		if oBox.m_RefineCheckBox:GetSelected() then
			return true
		end
	end
	return false
end
return CItemRefinePart