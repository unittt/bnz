// **********************************************************************
// Copyright (c) 2013 Baoyugame. All rights reserved.
// File     :  ServerManager.cs
// Author   : SK
// Created  : 2013/9/6
// Purpose  : 
// **********************************************************************

using System.Collections.Generic;

//服务器管理器
//xxj begin
//using AppDto;
//xxj end


public class ServerManager
{
	private static readonly ServerManager instance = new ServerManager();
    public static ServerManager Instance
    {
        get
		{
			return instance;
		}
    }	
	
	public delegate void OnRequestTokenDelegate(string token, string errorMsg);
	public OnRequestTokenDelegate OnRequestToken;		

	public delegate void OnRequestOrderIdDelegate(string orderId, string errorMsg);
	public OnRequestOrderIdDelegate OnRequestOrderId;		
	
	public static string gservice = "";

    //是否处于审核模式
    public bool isReviewMode = false;
    //是否是游客模式
	public bool isGuest = false;
    //用户的会话ID
	public string sid = "";
    //用户的唯一ID
	public string uid = "";
    //支付下订单时需要上传的额外参数(每个渠道不同)
    public string payExt = "";
    //用户的账号ID
    public string aid = "";

    public string account = "";
    public string password = "";
    public bool bSaveAccount = false;

    //xxj begin
    //private GameServerInfo _serverInfo;
    //xxj end

    public LoginAccountDto loginAccountDto;

    //xxj begin
    //   public void SetServerInfo(GameServerInfo info){
    //	_serverInfo = info;
    //}
    //xxj end

    //xxj begin
    //   public GameServerInfo GetServerInfo(){
    //	return _serverInfo;
    //}
    //xxj end


    //xxj begin
 //   public AccountPlayerDto HasPlayerAtServer(int gameServerId)
	//{
	//	long roleId = GameSetting.GetLastRolePlayerId();
 //       int i;
 //       if (loginAccountDto != null)
	//	{
	//		if (roleId == 0)
	//		{
 //               for ( i = 0; i < loginAccountDto.players.Count; i++)
 //               {
 //                   AccountPlayerDto dto = loginAccountDto.players[i];
 //                   if (dto.gameServerId == gameServerId)
 //                   {
 //                       return dto;
 //                   }
 //               }
	//		}
	//		else
	//		{
 //               for ( i = 0; i < loginAccountDto.players.Count; i++)
 //               {
 //                   AccountPlayerDto dto = loginAccountDto.players[i];
 //                   if (dto.gameServerId == gameServerId && dto.id == roleId)
 //                   {
 //                       return dto;
 //                   }
 //               }

 //               //if not find the last role then use the first accountPlayer at this server
 //               for ( i = 0; i < loginAccountDto.players.Count; i++)
 //               {
 //                   AccountPlayerDto dto = loginAccountDto.players[i];
 //                   if (dto.gameServerId == gameServerId)
 //                   {
 //                       return dto;
 //                   }
 //               }
	//		}
	//	}
	//	return null;
	//}
    
 //   public List<AccountPlayerDto> GetPlayersAtServer(int gameServerId)
	//{
	//	List<AccountPlayerDto> list = new List<AccountPlayerDto>();

	//	if (loginAccountDto != null)
	//	{
	//		List<AccountPlayerDto> players = loginAccountDto.players;
	//		for (int i=0; i < players.Count; i++)
	//		{
	//			AccountPlayerDto dto = players[i];
	//			if (dto.gameServerId == gameServerId)
	//			{
	//				list.Add(dto);
	//			}
	//		}
	//	}
 //       /*if (ModelManager.Player.GetPlayer() != null)
 //       {
 //           for (int i = 0; i < list.Count; i++)
 //           {
 //               if (list[i].id == ModelManager.Player.GetPlayer().id)
 //               {
 //                   list[i].icon = ModelManager.Player.GetPlayer().charactor.texture;
 //                   list[i].charactorId = ModelManager.Player.GetPlayer().charactorId;
 //               }
 //           }
 //       }*/
	//	return list;
	//}

 //   //转换角色之后，更新对应角色贴图数据
 //   public void UpdatePlayerCharactorData()
 //   {
 //       if (ModelManager.Player.GetPlayer() != null && loginAccountDto != null)
 //       {
 //           long playerId = ModelManager.Player.GetPlayer().id;
 //           for (int i = 0; i < loginAccountDto.players.Count; i++)
 //           {
 //               AccountPlayerDto dto = loginAccountDto.players[i];
 //               if (dto.gameServerId == _serverInfo.serverId && dto.id == playerId)
 //               {
 //                   dto.icon = ModelManager.Player.GetPlayer().charactor.texture;
 //                   dto.charactorId = ModelManager.Player.GetPlayer().charactorId;
 //               }
 //           }
 //       }
 //       else
 //       {
 //           if (ModelManager.Player.GetPlayer() == null)
 //           {
 //               GameDebuger.Log("玩家数据有问题， PlayerDto is Null");
 //           }
 //           if (loginAccountDto == null)
 //           {
 //               GameDebuger.Log("SSO数据有问题， LoginAccountDto is Null");
 //           }
 //       }
 //   }

 //   //获取该服务器上角色的最后登陆时间
 //   public long GetPlayerRecentLoginTime(int gameServerId)
	//{
	//	long recentLoginTime = 0;
	//	List<AccountPlayerDto> list = GetPlayersAtServer(gameServerId);
	//	for(int i=0; i<list.Count; i++)
	//	{
	//		AccountPlayerDto dto = list[i];
	//		if (dto.recentLoginTime > recentLoginTime)
	//		{
	//			recentLoginTime = dto.recentLoginTime;
	//		}
	//	}

	//	return recentLoginTime;
	//}

 //   public void DelectPlayer(AccountPlayerDto playerDtp)
 //   {
 //       if (loginAccountDto != null)
 //       {
 //           for (int i = 0; i < loginAccountDto.players.Count; i++)
 //           {
 //               AccountPlayerDto dto = loginAccountDto.players[i];
 //               if (dto.id == playerDtp.id)
 //               {
 //                   loginAccountDto.players.Remove(dto);
 //                   break;
 //               }
 //           }
 //       }
 //   }

	//public AccountPlayerDto AddAccountPlayer(CreatePlayerDto dto)
	//{
	//	TalkingDataHelper.SetupAccount(dto.gameServerId, dto.id, dto.nickname, dto.grade, dto.factionId, 1);
 //       Crasheye.SetUserIdentifier(dto.gameServerId + "_" + dto.id + "_" + dto.nickname);

	//	AccountPlayerDto accountPlayerDto = GetAccountPlayer(dto.id);
	//	if (accountPlayerDto == null)
	//	{
	//		accountPlayerDto = new AccountPlayerDto();
	//		accountPlayerDto.id = dto.id;
	//		accountPlayerDto.nickname = dto.nickname;
	//		accountPlayerDto.grade = dto.grade;
	//		accountPlayerDto.gameServerId = _serverInfo.serverId;
	//		accountPlayerDto.charactorId = dto.charactorId;
	//		accountPlayerDto.factionId = dto.factionId;
	//		accountPlayerDto.recentLoginTime = SystemTimeManager.Instance.GetUTCTimeStamp();

	//		loginAccountDto.players.Add(accountPlayerDto);
	//	}

	//	return accountPlayerDto;
	//}

	//public AccountPlayerDto AddAccountPlayer(PlayerDto dto)
	//{
 //       TalkingDataHelper.SetupAccount(dto.serviceId, dto.id, dto.nickname, dto.grade, dto.factionId, dto.gender);
 //       Crasheye.SetUserIdentifier(dto.serviceId + "_" + dto.id + "_" + dto.nickname);

	//	AccountPlayerDto accountPlayerDto = GetAccountPlayer(dto.id);
	//	if (accountPlayerDto == null)
	//	{
	//		accountPlayerDto = new AccountPlayerDto();
	//		accountPlayerDto.id = dto.id;
	//		accountPlayerDto.nickname = dto.nickname;
	//		accountPlayerDto.grade = dto.grade;
	//		accountPlayerDto.gameServerId = _serverInfo.serverId;
	//		accountPlayerDto.charactorId = dto.charactorId;
	//		accountPlayerDto.factionId = dto.factionId;

	//		loginAccountDto.players.Add(accountPlayerDto);
	//	}

	//	return accountPlayerDto;
	//}

	//public void UpdateAccountPlayer(PlayerDto dto)
	//{
	//	AccountPlayerDto accountPlayerDto = GetAccountPlayer(dto.id);
	//	if (accountPlayerDto != null)
	//	{
	//		accountPlayerDto.nickname = dto.nickname;
	//		accountPlayerDto.grade = dto.grade;
	//		accountPlayerDto.factionId = dto.factionId;
	//		accountPlayerDto.charactorId = dto.charactorId;
	//	}
	//}

	//public AccountPlayerDto GetAccountPlayer(long id)
	//{
 //       for (int i = 0; i < loginAccountDto.players.Count; i++)
 //       {
 //           AccountPlayerDto dto = loginAccountDto.players[i];
 //           if (dto.id == id)
 //           {
 //               return dto;
 //           }
 //       }
	//	return null;
	//}
	
	//public int GetPlayerCount(int gameServerId)
	//{
	//	int count = 0;
	//	if (loginAccountDto != null)
	//	{
 //           for (int i = 0; i < loginAccountDto.players.Count; i++)
 //           {
 //               AccountPlayerDto dto = loginAccountDto.players[i];
 //               if (dto.gameServerId == gameServerId)
 //               {
 //                   count++;
 //               }
 //           }
	//	}
	//	return count;
	//}
    //xxj end

    public string GetOpenId()
    {
        string openid = "";
        if (sid != null)
        {
            string[] sidParam = sid.Split('|');
            if (sidParam.Length > 0)
            {
                openid = sidParam[0];
            }
        }

        return openid;
    }
}

