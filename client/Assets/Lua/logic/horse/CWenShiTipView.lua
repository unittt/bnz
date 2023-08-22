local CWenShiTipView = class("CWenShiTipView", CViewBase)

function CWenShiTipView.ctor(self, cb)

	CViewBase.ctor(self, "UI/Horse/WenShiTipView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "expand"

end

function CWenShiTipView.OnCreateView(self)

    self.m_Icon = self:NewUI(1, CSprite)
    self.m_Name = self:NewUI(2, CLabel)
    self.m_Lv = self:NewUI(3, CLabel)
    self.m_Score = self:NewUI(4, CLabel)
    self.m_Last = self:NewUI(5, CLabel)
    self.m_Attr = self:NewUI(6, CBox)
    self.m_RightBtnBox = self:NewUI(7, CBox)
    --self.m_LeftBtnBox = self:NewUI(8, CBox)
   -- self.m_FeatureTable = self:NewUI(9, CTable)
   -- self.m_FeatureBtnBox = self:NewUI(10, CBox)
    self.m_PreViewBtn = self:NewUI(11, CSprite)
    self.m_PreViewBox = self:NewUI(12, CBox)
    self.m_LeftBtnBox = self:NewUI(13, CBox)
    self.m_AttrGrid = self:NewUI(14, CGrid)
    self.m_PreAttrItem = self:NewUI(15, CBox)
    self.m_PreGrid = self:NewUI(16, CGrid)
    self.m_Broken = self:NewUI(17, CSprite)
    self.m_QualityBorder = self:NewUI(18, CSprite)
    self.m_Node = self:NewUI(19, CObject)
    self.m_Bandding = self:NewUI(20, CSprite)
    self.m_Des = self:NewUI(21, CLabel)

    self.m_ShowPreViewBox = false

    self.m_PreViewBtn:AddUIEvent("click", callback(self, "OnClickPreViewBtn"))
    g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose")) 

end

function CWenShiTipView.SetInfo(self, info, pos)

    self.m_Info = info
    self:RefreshTop()
    self:RefreshAttr()
    self:RefreshBtns()
    self.m_CurPos = pos
 
end

function CWenShiTipView.HideBtn(self)
    
    self.m_LeftBtnBox:SetActive(false)
    self.m_RightBtnBox:SetActive(false)

end

function CWenShiTipView.RefreshTop(self)
    
    local icon = self.m_Info.icon
    local name = self.m_Info.name
    local score = self.m_Info.score
    local last = self.m_Info.last
    local lv = self.m_Info.lv
    local quality = self.m_Info.quality
    local bandding = self.m_Info.bandding
    local des = self.m_Info.des
    self.m_Icon:SpriteItemShape(icon)
    local sName = string.format(data.colorinfodata.ITEM[quality].color, name)
    self.m_Name:SetRichText(sName, nil, nil, true)
    self.m_Score:SetText(score)
    self.m_Last:SetText(last)
    self.m_Lv:SetText(lv)
    self.m_Broken:SetActive(last == 0)
    self.m_Icon:SetGrey(last == 0)
    self.m_QualityBorder:SetItemQuality(quality)
    self.m_Bandding:SetActive(bandding == 1)
    self.m_Des:SetText(des)

end

function CWenShiTipView.RefreshAttr(self)
    
    self.m_AttrGrid:HideAllChilds()
    local attrNameConfig = data.attrnamedata.DATA
    local attrList = self.m_Info.attr
    for k, v in ipairs(attrList) do 
        local attrItem = self.m_AttrGrid:GetChild(k)
        if not attrItem then 
            attrItem = self.m_Attr:Clone()
            attrItem:SetActive(true)
            self.m_AttrGrid:AddChild(attrItem)
        end 
        local data = attrNameConfig[v.key]
        local name = data.name
        local value = v.value / 100
        attrItem:SetActive(true)
        attrItem.name = attrItem:NewUI(1, CLabel)
        attrItem.value = attrItem:NewUI(2, CLabel)

        if g_AttrCtrl:IsRatioAttr(v.key) then 
            value = value .. "%"
        end 
        attrItem.name:AlignmentWidth(name)
        attrItem.name:SetText(name)
        attrItem.value:SetText("+" .. value)
    end 
  
end

function CWenShiTipView.RefreshBtns(self)

    self:RefreshRightBtn()
    self:RefreshLeftBtn()

end

function CWenShiTipView.RefreshRightBtn(self)
    
    self.m_RightBtnBox.btnText = self.m_RightBtnBox:NewUI(1, CLabel)
    self.m_RightBtnBox.collider = self.m_RightBtnBox:NewUI(2, CWidget)
    self.m_RightBtnBox.btnText:SetText("更换")
    self.m_RightBtnBox.collider:AddUIEvent("click", callback(self, "OnClickRightBtn"))

end

function CWenShiTipView.RefreshLeftBtn(self)
    
    self.m_LeftBtnBox.btnText = self.m_LeftBtnBox:NewUI(1, CLabel)
    self.m_LeftBtnBox.collider = self.m_LeftBtnBox:NewUI(2, CWidget)
    self.m_LeftBtnBox.btnText:SetText("卸下")
    self.m_LeftBtnBox.collider:AddUIEvent("click", callback(self, "OnClickLeftBtn"))

end

function CWenShiTipView.OnClickRightBtn(self)
    
    CHorseTongYuMainView:ShowView(function ( oView )
        
        oView:OpenWenShiWearPart(self.m_Info.bindRide, self.m_CurPos)

    end)

end

function CWenShiTipView.OnClickLeftBtn(self)

    local id = self.m_Info.bindRide
    local pos = self.m_Info.pos
    local tipText = g_HorseCtrl:GetTextTip(1038)
    local windowTipInfo = {
                        msg             = tipText,
                        okCallback      = function () 
                                            g_WenShiCtrl:C2GSUnWieldWenShi(id, pos)
                                            self:OnClose()
                                         end,
                        okStr           =  "确定",
                        cancelStr       =  "取消",
                    }   
    g_WindowTipCtrl:SetWindowConfirm(windowTipInfo)

end

function CWenShiTipView.OnClickPreViewBtn(self)
    
    self.m_ShowPreViewBox = not self.m_ShowPreViewBox
    if self.m_ShowPreViewBox then 
        self.m_PreViewBox:SetActive(true)
        self:RefreshPreView()
    else
        self.m_PreViewBox:SetActive(false)
    end 

end

function CWenShiTipView.RefreshPreView(self)
    
    self.m_PreGrid:HideAllChilds()
    local sid = self.m_Info.sid
    local totalAttr = g_WenShiCtrl:GetWenShiTotalAttr(sid)
    for k, v in ipairs(totalAttr) do 
        local attrItem = self.m_PreGrid:GetChild(k)
        if not attrItem then 
            attrItem = self.m_PreAttrItem:Clone()
            attrItem:SetActive(true)
            self.m_PreGrid:AddChild(attrItem)
        end 
        attrItem:SetActive(true)
        attrItem.name = attrItem:NewUI(1, CLabel)
        attrItem.value = attrItem:NewUI(2, CLabel)

        attrItem.name:AlignmentWidth(v.name)
        attrItem.name:SetText(v.name)
        attrItem.value:SetText("+" .. v.value)
    end 

end

function CWenShiTipView.SetNodePos(self, pos)
    
    self.m_Node:SetLocalPos(pos)

end

return CWenShiTipView