local CTitleLinkView = class("CTitleLinkView", CViewBase)

function CTitleLinkView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Title/TitleLinkView.prefab", cb)
    self.m_DepthType = "Dialog"
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
end

function CTitleLinkView.OnCreateView(self)
    self.m_CloseBtn      = self:NewUI(1, CButton)
    self.m_DescTable     = self:NewUI(2, CTable)
    self.m_DescItem      = self:NewUI(3, CTitleDescItem)
    self.m_TitleName     = self:NewUI(4, CLabel)
    self.m_DescScrollView = self:NewUI(5, CScrollView)
    self:InitContent()
end

function CTitleLinkView.InitContent(self)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CTitleLinkView.ResbuildDescList(self, name, tid)
    self.m_TitleName:SetText(name)
    self.m_DescTable:Clear()
    for i = 1, #data.titledata.DESC_FIELD do
        local field = data.titledata.DESC_FIELD[i]
        printc(field)
        self:AddSingleFieldDescItem(tid, field)
    end
    Utils.AddTimer(function ()   --如果不延迟调用不能适应锚点对齐
         self.m_DescTable:RepositionLater()
         self.m_DescScrollView:ResetPosition()
         return false
     end, 0, 0.1)
end

function CTitleLinkView.AddSingleFieldDescItem(self, tid, field)
    local oDescItem = self.m_DescItem:Clone()
    oDescItem:SetActive(true)
    oDescItem:SetBoxInfo(tid, field)
    self.m_DescTable:AddChild(oDescItem)
    oDescItem:SetGroup(self.m_DescTable:GetInstanceID())
end

return CTitleLinkView