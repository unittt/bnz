local CRankMeinItemBox = class("CRankMeinItemBox", CBox)

function CRankMeinItemBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)
    self.m_Pid = nil
    self.m_TexTure = self:NewUI(1, CActorTexture)
    self.m_Shcool = self:NewUI(2, CSprite)
    self.m_Name = self:NewUI(3, CLabel)
    self.m_CardBtn = self:NewUI(4, CButton)
    self.m_Upvote = self:NewUI(5, CLabel)
    self.m_Dialog = self:NewUI(6, CLabel)
    self.m_DialogTween = self.m_Dialog:GetComponent(classtype.TweenAlpha)
    self.m_RankValue = self:NewUI(7, CLabel)
    self.m_InfoBox = self:NewUI(8, CBox)
    self.m_EmpryHint = self:NewUI(9, CLabel)
    self.m_RankName = {
        [101] = "等级:",
        [106] = "综合实力:",
        [107] = "人物评分:",
        [108] = "宠物评分:",
        [109] = "魅力",
        [115] = "积分",
        [116] = "帮派威望",
        [117] = "积分", 
        [205] = "蜀山",
        [206] = "金山寺",
        [207] = "太初",
        [208] = "瑶池",
        [209] = "妖神宫",
        [210] = "青山城",
        [221] = "积分",
        [222] = "耗时",
        [223] = "耗时",
    }
    self.m_Upvote:SetActive(false)
    self.m_CardBtn:AddUIEvent("click", callback(self, "ShowCardView"))
    g_RankCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

    self.m_SummonType = 108
    self.m_ExaminationType = {222, 223}
    self.m_TexScale = 1
    self:InitActorTex()
end

function CRankMeinItemBox.InitActorTex(self)
    local oTex = self.m_TexTure
    local h = oTex:GetHeight()
    local newHeight = 300
    local offset = newHeight - h
    oTex.m_UIWidget.autoResizeBoxCollider = false

    local pos = oTex:GetLocalPos()
    pos.y = pos.y + offset/2

    oTex:SetHeight(newHeight)
    oTex:SetLocalPos(pos)
    oTex:SetShader(UnityEngine.Shader.Find("Unlit/Premultiplied Colored"))
    self.m_TexScale = newHeight/h
end

function CRankMeinItemBox.SetInfo(self, info)
    --table.print(info ,"-----设置三甲信息.SetInfo-")
    self:SetSubUIShow(info~=nil)
    if info ~= nil then
        self.m_Pid = info.pid
        if g_RankCtrl.m_CurSubTypeId ~= self.m_SummonType then
            self.m_TexTure:SetActive(true)
            local modelInfo = table.copy(info.model_info)
            modelInfo.rendertexSize = 0.88 * self.m_TexScale
            modelInfo.actorpos = Vector3.New(0, -0.4, 0)
            self.m_TexTure:ChangeShape(modelInfo)
            self.m_Shcool:SpriteSchool(info.school)
            self.m_Name:SetText(info.name)
            if table.index(self.m_ExaminationType, g_RankCtrl.m_CurSubTypeId) then
                local sTime = g_TimeCtrl:GetLeftTimeString(info.value)
                self.m_RankValue:SetText(self.m_RankName[g_RankCtrl.m_CurSubTypeId].." "..sTime)
            else
                self.m_RankValue:SetText(self.m_RankName[g_RankCtrl.m_CurSubTypeId].." "..info.value)
            end
            g_RankCtrl:C2GSGetUpvoteAmount(info.pid) --获取最新点赞
        else
            local summoninfo = data.summondata.INFO[info.type]
            if summoninfo then
               self.m_TexTure:SetActive(true)
               local model_info = {
                    figure = summoninfo.shape,
                    rendertexSize = 0.93 * self.m_TexScale    
               }
               self.m_TexTure:ChangeShape(model_info)
               self.m_Name:SetText(info.name)
            end
            self.m_Shcool:SetSpriteName("")
            self.m_Upvote:SetActive(false)
            self.m_RankValue:SetText(self.m_RankName[g_RankCtrl.m_CurSubTypeId].." "..info.score)
        end
    end
end

function CRankMeinItemBox.ShowCardView(self)
    if self.m_Pid then 
        g_LinkInfoCtrl:GetAttrCardInfo(self.m_Pid)
    end
end

function CRankMeinItemBox.ShowDialog(self)    
    local diglogs = data.rankdata.INFO[g_RankCtrl.m_CurSubTypeId].dialog
    if next(diglogs) == nil then
        return 
    end 
    local index = math.random(1, #diglogs)
    self.m_Dialog:SetActive(true)
    self.m_DialogTween.enabled = true
    self.m_DialogTween:ResetToBeginning()

    self.m_Dialog:SetText(data.rankdata.DIALOG[diglogs[index]].dialog)
end

function CRankMeinItemBox.HideDialog(self)
    -- body
    -- self.m_DialogTween:Play(true)
    self.m_Dialog:SetActive(false)
end

function CRankMeinItemBox.SetSubUIShow(self, bHasInfo)
    local bExist = not bHasInfo
    self.m_InfoBox:SetActive(bHasInfo)
    self.m_TexTure:SetActive(bHasInfo)
    self.m_EmpryHint:SetActive(bExist)
end

function CRankMeinItemBox.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Rank.Event.UpdateMeinUpvote and self.m_Pid == oCtrl.m_EventData.pid then    
        local info = nil
        local count = 0
        if oCtrl.m_EventData.upvote ~= nil then 
            count = oCtrl.m_EventData.upvote 
        else 
            info = g_LinkInfoCtrl:GetAttrCardByPid(self.m_Pid)
            if info ~= nil and next(info) ~= nil then
                if info.upvote_amount == nil then 
                    info.upvote_amount = 0
                end 
                count= info.upvote_amount
            end     
        end
        self.m_Upvote:SetActive(true)      
        self.m_Upvote:SetText("被赞: "..count.."次")
    end 
end

return CRankMeinItemBox
