--import module
local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"

function CloseGS(mRecord, mData)
    global.oChatMgr:CloseGS()
end
