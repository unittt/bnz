enum = require "logic.enum"
define = require "logic.define"
classtype =  require "logic.classtype"
gameconfig = require "logic.gameconfig"

require "logic.base.base"
require "logic.hud.hud"
require "logic.ui.ui"
require "logic.effect.effect"
require "logic.attr.attr"
require "logic.map.map"
require "logic.test.test"
require "logic.mainmenu.mainmenu"
require "logic.notify.notify"
require "logic.model.model"
require "logic.war.war"
require "logic.magic.magic"
require "logic.item.item"
require "logic.misc.misc"
require "logic.chat.chat"
require "logic.gm.gm"
require "logic.summon.summon"
require "logic.npcshop.npcshop"
require "logic.task.task"
require "logic.dialogue.dialogue"
require "logic.currency.currency"
require "logic.team.team"
require "logic.schedule.schedule"
require "logic.skill.skill"
require "logic.systemsettings.systemsettings"
require "logic.friend.friend"
require "logic.forge.forge"
require "logic.audio.audio"

require "logic.org.org"
require "logic.guide.guide"
require "logic.partner.partner"
require "logic.action.action"
require "logic.title.title"
require "logic.autopatrol.autopatrol"
require "logic.treasure.treasure"
require "logic.rank.rank"
require "logic.formation.formation"
require "logic.jjc.jjc"
require "logic.econonmy.econonmy"
require "logic.arena.arena"
require "logic.yibao.yibao"
require "logic.redpacket.redpacket"
require "logic.craps.craps"
require "logic.bonfire.bonfire"
require "logic.dancingactivity.dancingactivity"
require "logic.plot.plot"
require "logic.promote.promote"
require "logic.barrage.barrage"
require "logic.sign.sign"
require "logic.horse.horse"
require "logic.worldboss.worldboss"
require "logic.welfare.welfare"
require "logic.lottery.lottery"
require "logic.upgradepacks.upgradepacks"
require "logic.loginphone.loginphone"
require "logic.fightOutsideBuff.fightOutsideBuff"
require "logic.pkactivity.pkactivity"
require "logic.dungeon.dungeon"
require "logic.qr.qr"
require "logic.lingxi.lingxi"
require "logic.baike.Baike"
require "logic.wishbottle.wishbottle"
require "logic.schoolmatch.schoolmatch"
require "logic.ranse.ranse"
require "logic.waiguan.waiguan"
require "logic.orgmatch.orgmatch"
require "logic.herotrail.herotrail"
require "logic.guessriddle.guessriddle"
require "logic.quickget.quickget"
require "logic.celebration.celebration"
require "logic.compose.compose"
require "logic.timelimit.timelimit"
require "logic.offerreward.offerreward"
require "logic.superrebate.superrebate"
require "logic.fuyuanTreasure.fuyuanTreasure"
require "logic.threebiwu.threebiwu"
require "logic.assembletreasure.assembletreasure"
require "logic.marry.marry"
require "logic.nianshou.nianshou"
require "logic.artifact.artifact"
require "logic.continuousactivity.continuousactivity"
require "logic.horsetongyu.horsetongyu"
require "logic.yuanbaojoy.yuanbaojoy"
require "logic.mysticalbox.mysticalbox"
require "logic.wing.wing"
require "logic.horsewenshi.horsewenshi"
require "logic.hottopic.hottopic"
require "logic.rebatejoy.rebatejoy"
require "logic.zhenmo.zhenmo"
require "logic.mibaoconvoy.mibaoconvoy"

require "logic.master.master"
require "logic.fabao.fabao"
require "logic.jiebai.jiebai"
require "logic.singlebiwu.singlebiwu"
require "logic.examination.examination"
require "logic.spirit.spirit"
require "logic.feedback.feedback"
require "logic.zerobuy.zerobuy"
require "logic.duanwu.duanwu"

data = require "logic.data.data"
datauser = require "logic.datauser.datauser"
DataTools = require "logic.misc.DataTools"
DataTools.Init()

-- Resource数据
g_GameDataCtrl = CGameDataCtrl.New()
-- 通信
g_UrlRootCtrl = CUrlRootCtrl.New()
g_HttpCtrl = CHttpCtrl.New()
g_PayCtrl = CPayCtrl.New()

--demi
g_DemiCtrl = CDemiCtrl.New()

-- 基础
g_DelegateCtrl = CDelegateCtrl.New()
g_TimerCtrl = CTimerCtrl.New()
g_CountdownTimerCtrl = CCountdownTimerCtrl.New()
g_ViewCtrl = CViewCtrl.New()
g_TimeCtrl = CTimeCtrl.New()
g_ResCtrl = CResCtrl.New()
g_ActionCtrl = CActionCtrl.New()
g_EffectCtrl = CEffectCtrl.New()
g_CameraCtrl = CCameraCtrl.New()
g_MapTouchCtrl = CMapTouchCtrl.New()
g_WarTouchCtrl = CWarTouchCtrl.New()
g_MapCtrl = CMapCtrl.New()
g_EasyTouchCtrl = CEasyTouchCtrl.New()
g_UITouchCtrl = CUITouchCtrl.New()
g_HotKeyCtrl = CHotKeyCtrl.New()
g_MaskWordCtrl = CMaskWordCtrl.New()
g_JinYanCtrl = CJinYanCtrl.New()
g_InitialCtrl = CInitialCtrl.New()
g_ScreenResizeCtrl = CScreenResizeCtrl.New()
g_ResourceReplaceCtrl = CResourceReplaceCtrl.New()

--玩家操作日志
g_LogCtrl = CLogCtrl.New()
g_UploadDataCtrl = CUploadDataCtrl.New()

-- GM
g_GmCtrl = CGmCtrl.New()
g_CTesterCtrl = CTesterCtrl.New()

-- 战斗
g_WarCtrl = CWarCtrl.New()
g_WarOrderCtrl = CWarOrderCtrl.New()
g_MagicCtrl = CMagicCtrl.New()

-- 模块
g_NotifyCtrl = CNotifyCtrl.New()
g_WindowTipCtrl = CWindowTipCtrl.New()

g_MainMenuCtrl = CMainMenuCtrl.New()
g_AttrCtrl = CAttrCtrl.New()
g_HudCtrl = CHudCtrl.New()
g_ItemCtrl = CItemCtrl.New()
g_ItemViewCtrl = CItemViewCtrl.New()
g_TaskCtrl = CTaskCtrl.New()
g_SummonCtrl = CSummonCtrl.New()
g_DialogueCtrl = CDialogueCtrl.New()
g_TalkCtrl = CTalkCtrl.New()
g_ChatCtrl = CChatCtrl.New()
g_ChatViewCtrl = CChatViewCtrl.New()
g_TeamCtrl = CTeamCtrl.New()
g_FriendCtrl = CFriendCtrl.New()
g_ScheduleCtrl = CScheduleCtrl.New()
g_SkillCtrl = CSkillCtrl.New()
g_SkillViewCtrl = CSkillViewCtrl.New()
g_ForgeCtrl = CForgeCtrl.New()
g_SystemSettingsCtrl = CSystemSettingsCtrl.New()
g_MailCtrl = CMailCtrl.New()
g_LinkInfoCtrl = CLinkInfoCtrl.New()
g_SpeechCtrl = CSpeechCtrl.New()
g_AudioCtrl = CAudioCtrl.New()
g_QiniuCtrl = CQiniuCtrl.New()
g_PartnerCtrl = CPartnerCtrl.New()
g_OrgCtrl = COrgCtrl.New()
g_GuideCtrl = CGuideCtrl.New()
g_TreasureCtrl = CTreasureCtrl.New()
g_TreasureShowCtrl = CTreasureShowCtrl.New()
g_TitleCtrl = CTitleCtrl.New()
g_RankCtrl = CRankCtrl.New()
g_ShopCtrl = CShopCtrl.New()
g_FormationCtrl = CFormationCtrl.New()
g_JjcCtrl = CJjcCtrl.New()
g_EcononmyCtrl = CEcononmyCtrl.New()
g_YibaoCtrl = CYibaoCtrl.New()
g_RedPacketCtrl = CRedPacketCtrl.New()
g_CrapsCtrl = CcrapsCtrl.New()
g_ImageCtrl = CImageCtrl.New()
g_InteractionCtrl = CInteractionCtrl.New()
g_DancingCtrl = CDancingCtrl.New()
g_PlotCtrl = CPlotCtrl.New()
g_PromoteCtrl = CPromoteCtrl.New()
g_BonfireCtrl = CBonfireCtrl.New()
g_BarrageCtrl = CBarrageCtrl.New()
g_HorseCtrl = CHorseCtrl.New()
g_WorldBossCtrl = CWorldBossCtrl.New()
g_SignCtrl = CSignCtrl.New()
g_LotteryCtrl = CLotteryCtrl.New()
g_UpgradePacksCtrl = CUpgradePacksCtrl.New()
g_LoginPhoneCtrl = CLoginPhoneCtrl.New()
g_ServerPhoneCtrl = CServerPhoneCtrl.New()
g_KuafuCtrl = CKuafuCtrl.New()
g_WelfareCtrl = CWelfareCtrl.New()
g_FightOutsideBuffCtrl = CFightOutsideBuffCtrl.New()
g_SdkCtrl = CSdkCtrl.New()
g_RoleCreateTouchCtrl = CRoleCreateTouchCtrl.New()
g_PKCtrl = CPKCtrl.New()
g_MapPlayerNumberCtrl = CMapPlayerNumberCtrl.New()
g_DungeonCtrl = CDungeonCtrl.New()
g_GuideHelpCtrl = CGuideHelpCtrl.New()
g_OpenSysCtrl = COpenSysCtrl.New()
g_LimitCtrl = CLimitCtrl.New()
g_QRCtrl = CQRCtrl.New()
g_ApplicationCtrl = CApplicationCtrl.New()
g_ItemTempBagCtrl = CItemTempBagCtrl.New()
g_RecoveryCtrl = CRecoveryCtrl.New()
g_BaikeCtrl = CBaikeCtrl.New()

g_WishBottleCtrl = CWishBottleCtrl.New()
g_LingxiCtrl = CLingxiCtrl.New()
g_SchoolMatchCtrl = CSchoolMatchCtrl.New()

g_RanseCtrl = CRanseCtrl.New()
g_SummonRanseCtrl = CSummonRanseCtrl.New()
g_WaiGuanCtrl = CWaiGuanCtrl.New()
g_FlyRideAniCtrl = CFlyRideAniCtrl.New()
g_OrgMatchCtrl = COrgMatchCtrl.New()
g_HeroTrialCtrl = CHeroTrialCtrl.New()
g_GuessRiddleCtrl = CGuessRiddleCtrl.New()
g_QuickGetCtrl = CQuickGetCtrl.New()
g_CelebrationCtrl = CCelebrationCtrl.New()
g_MapWalkerCacheCtrl = CMapWalkerCacheCtrl.New()
g_TimelimitCtrl = CTimelimitCtrl.New()
g_EveryDayChargeCtrl = CEveryDayChargeCtrl.New()
g_ActiveGiftBagCtrl = CActiveGiftBagCtrl.New()
g_OnlineGiftCtrl = COnlineGiftCtrl.New()
g_OfferRewardCtrl = COfferRewardCtrl.New()
g_SuperRebateCtrl = CSuperRebateCtrl.New()
g_AccumChargeCtrl = CAccumChargeCtrl.New()
g_ItemGainWayCtrl = CItemGainWayCtrl.New()
g_ThreeBiwuCtrl = CThreeBiwuCtrl.New()
g_AssembleTreasureCtrl = CAssembleTreasureCtrl.New()
g_FuyuanTreasureCtrl = CFuyuanTreasureCtrl.New()
g_HeShenQiFuCtrl = CHeShenQiFuCtrl.New()
g_EngageCtrl = CEngageCtrl.New()
g_SysUIEffCtrl = CSysUIEffectCtrl.New()
g_NianShouCtrl = CNianShouCtrl.New()
g_ArtifactCtrl = CArtifactCtrl.New()
g_ContActivityCtrl = CContActivityCtrl.New()
g_YuanBaoJoyCtrl = CYuanBaoJoyCtrl.New()
g_MysticalBoxCtrl = CMysticalBoxCtrl.New()
g_WingCtrl = CWingCtrl.New()
g_MasterCtrl = CMasterCtrl.New()
g_FaBaoCtrl = CFaBaoCtrl.New()
g_WenShiCtrl = CWenShiCtrl.New()
g_DungeonTaskCtrl = CDungeonTaskCtrl.New()
g_HotTopicCtrl = CHotTopicCtrl.New()
g_RebateJoyCtrl = CRebateJoyCtrl.New()
g_ZhenmoCtrl = CZhenmoCtrl.New()
g_SingleBiwuCtrl = CSingleBiwuCtrl.New()
g_JieBaiCtrl = CJieBaiCtrl.New()
g_RoleCreateScene = CRoleCreateScene.New()
g_MarryCtrl = CMarryCtrl.New()
g_MarryPlotCtrl = CMarryPlotCtrl.New()
g_ItemInvestCtrl = CItemInvestCtrl.New()
g_ExaminationCtrl = CExaminationCtrl.New()
g_SpiritCtrl = CSpiritCtrl.New()
g_BigProfitCtrl = CBigProfitCtrl.New()
g_MiBaoConvoyCtrl = CMiBaoConvoyCtrl.New()
g_FeedbackCtrl = CFeedbackCtrl.New()
g_MarrySkillCtrl = CMarrySkillCtrl.New()
g_MapWalkerLoadCtrl = CMapWalkerLoadCtrl.New()
g_FirstPayCtrl = CFirstPayCtrl.New()
g_ZeroBuyCtrl = CZeroBuyCtrl.New()
g_RecommendCtrl = CRecommendCtrl.New()
g_ExpRecycleCtrl = CExpRecycleCtrl.New()
g_SoccerWorldCupGuessCtrl = CSoccerWorldCupGuessCtrl.New()
g_SoccerTeamSupportCtrl = CSoccerTeamSupportCtrl.New()
g_SoccerWorldCupGuessHistoryTipCtrl = CSoccerWorldCupGuessHistoryTipCtrl.New()
g_DuanWuHuodongCtrl = CDuanWuHuodongCtrl.New()
g_SoccerWorldCupCtrl = CSoccerWorldCupCtrl.New()