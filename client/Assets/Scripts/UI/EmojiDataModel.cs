using System.Text.RegularExpressions;
using System.Collections.Generic;

public static class EmojiDataModel
{
    #region 聊天表情信息

    public const int MAX_EMOJICOUNT = 10;
    public const string EMOTION_PREFIX = "#";

    //prefix,frameCount
    private static Dictionary<string, int> _emotionInfoDic;

    public static Dictionary<string, int> GetEmojiInfo()
    {
        return _emotionInfoDic;
    }

    //用于匹配表情图集中的聊天表情Sprite,来初始化动态表情帧数Dic
 
    public static string StripEmojiPrefix(string input)
    {
        var m = Regex.Match(input, EMOTION_PREFIX + "\\d{1,3}");
        if (m.Success)
        {
            return m.Value;
        }
        return null;
    }

    public static string ReplaceEmojiPrefix(string input, Dictionary<string, int> prefixDic)
    {
        
        return Regex.Replace(input, EMOTION_PREFIX + "\\d{1,3}", match =>
        {
            string prefix1 = match.Value;
            string sub = "";
            for (int i = prefix1.Length; i > 1; i--)
            {
                sub = prefix1.Substring(0, i);
                if (GetEmotionMaxFrameCount(sub) >= 1)
                {
                    prefixDic[sub] = 0;
                    return sub + "_00" + prefix1.Substring(i);
                }
            }
            return prefix1;
        });
    }

    public static void InitEmojiInfo(UIAtlas emojiAtlas)
    {
        if (emojiAtlas == null)
            return;

        if (_emotionInfoDic == null)
        {
            //--TestCode--
            //			System.Diagnostics.Stopwatch watch = new System.Diagnostics.Stopwatch();
            //			watch.Start();
            //--TestCode--
            List<UISpriteData> spriteList = emojiAtlas.spriteList;
            _emotionInfoDic = new Dictionary<string, int>(1000);
            for (int i = 0, imax = spriteList.Count; i < imax; ++i)
            {
                string prefix = StripEmojiPrefix(spriteList[i].name);
                if (!string.IsNullOrEmpty(prefix))
                {
                    if (_emotionInfoDic.ContainsKey(prefix))
                        _emotionInfoDic[prefix] += 1;
                    else
                    {
                        _emotionInfoDic.Add(prefix, 1);
                    }
                }
            }
            //--TestCode--
            //			watch.Stop();
            //			Debug.LogError(watch.Elapsed.TotalSeconds);
            //			foreach(var item in _emotionFrameInfoDic){
            //				Debug.LogError(string.Format("{0}:{1}",item.Key,item.Value));
            //			}
            //--TestCode--
        }
    }

    public static int GetEmotionMaxFrameCount(string prefix)
    {
        if (_emotionInfoDic != null && _emotionInfoDic.ContainsKey(prefix))
        {
            return _emotionInfoDic[prefix];
        }
        return 0;
    }

#endregion
}
