local CMarrySkillCtrl = class("CMarrySkillCtrl")

function CMarrySkillCtrl.ctor(self)
    self.m_FriendDegreeDict = {
        [8501] = 999,
        [8503] = 2000,
    }
end

function CMarrySkillCtrl.IsMarryMagic(self, iMagic)
    return iMagic >= 8501 and iMagic <= 8599
end

function CMarrySkillCtrl.IsMagicCanUse(self, iMagic, bShowMsg)
    -- 不需满足一般条件的技能可在上面判断
    if not (self:IsMateAlly() and self:IsFriendDegreeEnough(iMagic)) then
        return false
    end
    if iMagic == 8501 or iMagic == 8502 then
        return self:IsMateAlive()
    elseif iMagic == 8503 then
        return not self:IsMateAlive()
    end
    return true
end

function CMarrySkillCtrl.IsMateAlly(self)
    local oMate = self:GetMateWarrior()
    if not oMate or not oMate:IsAlly() then
        return false
    end
    return true
end

function CMarrySkillCtrl.IsFriendDegreeEnough(self, iMagic)
    local iPid = g_MarryCtrl:GetPartnerPid()
    if not iPid then
        return false
    end
    local iNeed = self.m_FriendDegreeDict[iMagic]
    if not iNeed then
        return true
    end
    local dFriend = g_FriendCtrl:GetFriend(iPid)
    return dFriend and (dFriend.friend_degree or 0) >= iNeed or false
end

function CMarrySkillCtrl.IsMateAlive(self)
    local oMate = self:GetMateWarrior()
    return oMate and oMate:IsAlive() or false
end

function CMarrySkillCtrl.GetMateWarrior(self)
    local iPid = g_MarryCtrl:GetPartnerPid()
    if not iPid then
        return
    end
    return g_WarCtrl:GetWarriorByID(iPid)
end

function CMarrySkillCtrl.IsMateWarrior(self, oWarrior)
    local iPid = g_MarryCtrl:GetPartnerPid()
    return oWarrior and oWarrior.m_Pid == iPid
end

function CMarrySkillCtrl.MagicSelCondition(self, iMagic, oWarrior)
    if self:IsMarryMagic(iMagic) then
        if not self:IsMateWarrior(oWarrior) then
            return false
        end
        if iMagic == 8501 or iMagic == 8502 then
            return oWarrior:IsAlive()
        elseif iMagic == 8503 then
            return not oWarrior:IsAlive()
        end
    end
    return true
end

return CMarrySkillCtrl