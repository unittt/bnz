using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class ChannelConfig
{
    private static string ChannelConfigPath = "Assets/Editor/BuildTools/Configs/ChannelConfig.json";

    public Dictionary<string, SPChannel> _spChannelDic;
    public Dictionary<string, GameInfo> _gameInfoDic;

    private string loadSuffixName;

    //游戏类型
    public int[] _gameTypeKeys;
    public string[] _gameTypeValues;

    //运行域
    public int[] _domainKeys;
    public string[] _domainValues;

    //渠道平台
    public int[] _channelKeys = new int[0];
    public string[] _channelValues = new string[0];

    public static ChannelConfig LoadChannelConfig(string configSuffix)
    {
        ChannelConfig config = new ChannelConfig();
        config._gameInfoDic = FileHelper.ReadJsonFile<Dictionary<string, GameInfo>>(ChannelConfigPath);
        config.InitGameTypeConfig();
        config.LoadSPChannelConfig(configSuffix);
        return config;
    }

    public void InitGameTypeConfig()
    {
        _gameTypeKeys = new int[_gameInfoDic.Count];
        _gameTypeValues = new string[_gameInfoDic.Count];
        int index = 0;
        foreach (string key in _gameInfoDic.Keys)
        {
            _gameTypeKeys[index] = index;
            _gameTypeValues[index] = key;
            index++;
        }
    }

    public void LoadSPChannelConfig(string configSuffix)
    {
        _spChannelDic = new Dictionary<string, SPChannel>();
        List<SPChannel> spChannels = _gameInfoDic[configSuffix].channels;
        for (int i = 0; i < spChannels.Count; i++)
        {
            SPChannel channel = spChannels[i];
            _spChannelDic[channel.name] = channel;
        }
    }

    public int UpdateSpSdkList(string domainType, string selectChannel)
    {
        int selectid = 0;
        List<SPChannel> spList = new List<SPChannel>();
        foreach (SPChannel sp in _spChannelDic.Values)
        {
            //if (//!string.IsNullOrEmpty(sp.platforms) && sp.platforms.Contains(((int)platformType).ToString())&& 
            //    !string.IsNullOrEmpty(sp.domains) && sp.domains.Contains(domainType))
            //{
            spList.Add(sp);
            //}
        }

        _channelKeys = new int[spList.Count];
        _channelValues = new string[spList.Count];
        for (int i = 0; i < spList.Count; i++)
        {
            _channelKeys[i] = i;
            _channelValues[i] = spList[i].name;
            if (selectChannel == spList[i].name)
            {
                selectid = i ;
            }
        }
        return selectid;
    }

    public DomainInfo GetDomainInfo(string gameType, string domainType)
    {
        if (_gameInfoDic.ContainsKey(gameType))
        {
            GameInfo info = _gameInfoDic[gameType];
            if (info.domains != null)
            {
                for (int i = 0; i < info.domains.Count; i++)
                {
                    DomainInfo domainInfo = info.domains[i];
                    if (domainInfo.type == domainType)
                    {
                        return domainInfo;
                    }
                }
                return null;
            }
            else
            {
                return null;
            }
        }
        else
        {
            return null;
        }
    }

    public int UpdateDomainList(string gameType, string domainType)
    {
        int index = 0;
        if (_gameInfoDic.ContainsKey(gameType))
        {
            GameInfo gameInfo = _gameInfoDic[gameType];
            _domainKeys = new int[gameInfo.domains.Count];
            _domainValues = new string[gameInfo.domains.Count];

            for (int i = 0; i < gameInfo.domains.Count; i++)
            {
                DomainInfo domainInfo = gameInfo.domains[i];
                _domainKeys[i] = i;
                _domainValues[i] = domainInfo.type;

                if (domainInfo.type == domainType)
                {
                    index = i;
                }
            }
        }
        return index;
    }

    public string GetDomianType(string gameType, int domainIndex)
    {
        GameInfo gameInfo = _gameInfoDic[gameType];
        if (gameInfo.domains.Count > domainIndex)
        {
            return gameInfo.domains[domainIndex].type;
        }
        return "";
    }

    //public string GetChannelAlias(string id)
    //{
    //    SPChannel info = null;
    //    if (_spChannelDic.TryGetValue(id, out info))
    //    {
    //        return info.alias;
    //    }
    //    else
    //    {
    //        return "无";
    //    }
    //}

    public string GetChannelBundleId(string id)
    {
        SPChannel info = null;
        if (_spChannelDic.TryGetValue(id, out info))
        {
            return info.bundleId;
        }
        else
        {
            return "null";
        }
    }

    //public string GetChannelSymbol(string id)
    //{
    //    SPChannel info = null;
    //    if (_spChannelDic.TryGetValue(id, out info))
    //    {
    //        return info.symbol;
    //    }
    //    else
    //    {
    //        return "";
    //    }
    //}

    public string GetChannelProjmods(string channel)
    {
        SPChannel info = null;
        if (_spChannelDic.TryGetValue(channel, out info))
        {
            return info.projmods;
        }
        else
        {
            return "";
        }
    }

}


