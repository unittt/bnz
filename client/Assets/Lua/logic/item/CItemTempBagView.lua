local CItemTempBagView = class("CItemTempBagView", CViewBase)

function CItemTempBagView.ctor(self,cb)
	CViewBase.ctor(self,"UI/Item/CItemTempBagView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_ItemList = {}
	self.m_DelayTimer = nil
end

function CItemTempBagView.OnCreateView(self)
	self.m_ItemGrid = self:NewUI(1, CGrid)
	self.m_CellClone = self:NewUI(2, CItemBox)
	self.m_PackUpBtn = self:NewUI(3, CButton)
	self.m_TipBtn =  self:NewUI(4, CButton) 
	self.m_CloseBtn = self:NewUI(5, CButton)

	self.m_PackUpBtn:AddUIEvent("click", callback(self, "OnPackUpEvent"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "OnTipBtnEvent"))

	g_ItemTempBagCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "ResetTempBag"))
	
 	self:IninContent()

end

function CItemTempBagView.IninContent(self)
	local gridChildList = self.m_ItemGrid:GetChildList()	
	for i=1,15  do
		local oItemBox = nil
		if i > #gridChildList  then
			oItemBox = self.m_CellClone:Clone()

			self.m_ItemGrid:AddChild(oItemBox)
			oItemBox:SetGroup(self.m_ItemGrid:GetInstanceID())
		else
			oItemBox = gridChildList[i]
		end
		oItemBox:SetActive(true)
		oItemBox:SetBagItem(nil)
	end
	self.m_CellClone:SetActive(false)
	for i,v in ipairs(g_ItemTempBagCtrl.m_TempBagList) do 
		local oItemBox = self.m_ItemGrid:GetChild(v.pos)
		local oItem = CItem.New(v)
		oItem.m_Type ="Temp"
		oItemBox:SetBagItem(oItem)
		oItemBox:AddUIEvent("click",callback(self, "OnClickShowInfo", oItem))
		oItemBox:AddUIEvent("doubleclick",callback(self, "OnClickSendMsg", oItem.m_ID))
	end
	self.m_ItemGrid:Reposition()
end

function CItemTempBagView.ResetTempBag(self, oCtrl)
	-- body	
	-- if oCtrl.m_EventID == define.Item.Event.RefreshTempBag then
	self:IninContent()
	-- end
end

function CItemTempBagView.OnTipBtnEvent(self)
	local Id = define.Instruction.Config.TempBag
	if data.instructiondata.DESC[Id]~=nil then
		local Content = {
			 title = data.instructiondata.DESC[Id].title,
			  desc = data.instructiondata.DESC[Id].desc
			}
		g_WindowTipCtrl:SetWindowInstructionInfo(Content)
	end
end

function CItemTempBagView.OnClickSendMsg(self, sid)
	-- body
	nettempitem.C2GSTranToItemBag(sid)
end


function CItemTempBagView.OnClickShowInfo(self, oItem)
	g_WindowTipCtrl:TempBagShow(oItem)
end

function CItemTempBagView.OnPackUpEvent(self)
	-- body
	nettempitem.C2GSTranToItemBag()
end

return CItemTempBagView