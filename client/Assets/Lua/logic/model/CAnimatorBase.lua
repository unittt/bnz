local CAnimatorBase = class("CAnimatorBase")

function CAnimatorBase.ctor(self)
	self.m_Animator = nil
end

function CAnimatorBase.SetAnimatorEabled(self, b)
	self.m_Animator.enabled = b
end

function CAnimatorBase.SetAnimator(self, o)
	self.m_Animator = o
end

function CAnimatorBase.GetAnimator(self)
	return self.m_Animator
end

function CAnimatorBase.CrossFadeInFixedTime(self, sState, transitonDuration, fixedTime)
	self.m_Animator.enabled = true
	local iHash = ModelTools.StateToHash(sState)
	transitonDuration = transitonDuration or 0
	fixedTime = fixedTime or 0
	self.m_Animator:CrossFadeInFixedTime(sState, transitonDuration, 0, fixedTime)
end

function CAnimatorBase.PlayInFixedTime(self, sState, fixedTime)
	--printc("PlayInFixedTime", sState, fixedTime)
	self.m_Animator.enabled = true
	local iHash = ModelTools.StateToHash(sState)
	fixedTime = fixedTime or 0
	self.m_Animator:PlayInFixedTime(iHash, 0, fixedTime)
end


return CAnimatorBase