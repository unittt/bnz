using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEngine;


public class EmojiAnimationController : MonoBehaviour
{
    private UILabel mLabel;

    #region 表情动画相关

    private const string EMOTION_FORMAT = "{0}_{1:00}";
    private System.Text.StringBuilder _strBuilder;
    //用于保存当前动态表情的数据,prefix,curFrameCount
    private Dictionary<string, int> _dynamicEmojiDic;

    private const float FRAME_INTERVAL = 0.25f;
    private float _timer = 0f;
    private UILabel cachedLabel {
        get{
            if (mLabel == null)
            {
                mLabel = this.GetComponent<UILabel>();
            }
            return mLabel;
        }
    }
    public bool SetEmojiText(string content)
    {
        if (cachedLabel == null)
            return false;

        //如果文本内容中没有“#”，直接设置文本内容
        if (!content.Contains(EmojiDataModel.EMOTION_PREFIX))
        {
            _strBuilder = null;
            _dynamicEmojiDic = null;
            cachedLabel.text = content;
            return false;
        }
        else
        {
            //初始化所有聊天表情动画帧数数据
            EmojiDataModel.InitEmojiInfo(cachedLabel.bitmapFont.emojiFont.atlas);

            //默认消息中只带表情symbol名的前缀，只替换动态表情的前缀名
            //原消息：#14#1abc#28
            //替换后：#14_00#1_00abc#28
            _dynamicEmojiDic = new Dictionary<string, int>(EmojiDataModel.MAX_EMOJICOUNT);
            _strBuilder = new System.Text.StringBuilder(EmojiDataModel.ReplaceEmojiPrefix(content, _dynamicEmojiDic));
            _timer = 0f;
            cachedLabel.text = _strBuilder.ToString();
            return true;
        }
    }

    private void PlayerEmotionAnimation()
    {
        var keyList = new List<string>(_dynamicEmojiDic.Keys);
        for (int i = 0; i < keyList.Count; ++i)
        {
            string prefix = keyList[i];
            int curFrame = _dynamicEmojiDic[prefix];
            int nextFrame = (curFrame + 1) < EmojiDataModel.GetEmotionMaxFrameCount(prefix) ? curFrame + 1 : 0;
            _strBuilder.Replace(string.Format(EMOTION_FORMAT, prefix, curFrame), string.Format(EMOTION_FORMAT, prefix, nextFrame));
            _dynamicEmojiDic[prefix] = nextFrame;
        }
        cachedLabel.text = _strBuilder.ToString();
    }

    void Update()
    {
        if (cachedLabel == null)
            return;

        if (_dynamicEmojiDic != null && _dynamicEmojiDic.Count > 0)
        {
            _timer += Time.deltaTime;
            if (_timer > FRAME_INTERVAL)
            {
                PlayerEmotionAnimation();
                _timer = 0;
            }
        }
    }

    #endregion
}
