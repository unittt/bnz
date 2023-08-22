using System;
using UnityEngine;
using System.Collections.Generic;

public class AnimEffect : MonoBehaviour, ISerializationCallbackReceiver
{
    public string animName = "";
    [SerializeField]
    private int effectLen = 0;
    public AnimEffectInfo[] effectArray;

    //序列化用数据
    [SerializeField]
    List<GameObject> effectSerial1;
    [SerializeField]
    List<string> effectSerial2;

    [SerializeField]
    private int soundLen = 0;
    public AnimEffectInfo[] soundArray;

    //序列化用数据
    [SerializeField]
    List<string> soundSerial1;
    [SerializeField]
    List<int> soundSerial2;

    public int EffectLength
    {
        get
        {
            return effectLen;
        }
        set
        {
            effectLen = Mathf.Max(0, value);
            var newArray = new AnimEffectInfo[effectLen];
            int start = 0;
            if (effectArray != null && effectArray.Length > 0)
            {
                int len = Mathf.Min(effectLen, effectArray.Length);
                Array.Copy(effectArray, newArray, len);
                start = len;
            }
            for (int i = start; i < effectLen; i++)
            {
                newArray[i] = new AnimEffectInfo(null, "");
            }
            effectArray = newArray;
        }
    }

    public int SoundLength
    {
        get
        {
            return soundLen;
        }
        set
        {
            soundLen = Mathf.Max(0, value);
            var newArray = new AnimEffectInfo[soundLen];
            int start = 0;
            if (soundArray != null && soundArray.Length > 0)
            {
                int len = Mathf.Min(soundLen, soundArray.Length);
                Array.Copy(soundArray, newArray, len);
                start = len;
            }
            for (int i = start; i < soundLen; i++)
            {
                newArray[i] = new AnimEffectInfo(null, "");
            }
            soundArray = newArray;
        }
    }

    public void OnBeforeSerialize()
    {
        if (effectArray != null)
        {
            effectSerial1 = new List<GameObject>();
            effectSerial2 = new List<string>();
            for (int i = 0; i < EffectLength; i++)
            {
                var info = effectArray[i];
                if (info != null)
                {
                    effectSerial1.Add(info.gameObject);
                    effectSerial2.Add(info.path);
                }
            }
        }
        if (soundArray != null)
        {
            soundSerial1 = new List<string>();
            soundSerial2 = new List<int>();
            for (int i = 0; i < SoundLength; i++)
            {
                var info = soundArray[i];
                soundSerial1.Add(info.path);
                soundSerial2.Add(info.offset);
            }
        }
    }

    public void OnAfterDeserialize()
    {
        if (effectSerial1 != null && effectSerial2 != null)
        {
            if (effectSerial1.Count < EffectLength)
            {
                GameDebug.LogError("动作绑定配置错误啦（特效绑定点挂点问题）" + gameObject.name);
                return;
            }
            if (effectSerial2.Count < EffectLength)
            {
                GameDebug.LogError("动作绑定配置错误啦（特效绑定路径问题）" + gameObject.name);
                return;
            }
            effectArray = new AnimEffectInfo[EffectLength];
            for (int i = 0; i < EffectLength; i++)
            {
                var info = new AnimEffectInfo(effectSerial1[i], effectSerial2[i]);
                effectArray[i] = info;
            }
        }

        if (soundSerial1 != null && soundSerial2 != null)
        {
            if (soundSerial1.Count < SoundLength)
            {
                GameDebug.LogError("动作绑定配置错误啦（音效绑定路径问题）" + gameObject.name);
                return;
            }
            if (soundSerial2.Count < SoundLength)
            {
                GameDebug.LogError("动作绑定配置错误啦（音效绑定偏移问题）" + gameObject.name);
                return;
            }
            soundArray = new AnimEffectInfo[SoundLength];
            for (int i = 0; i < SoundLength; i++)
            {
                var info = new AnimEffectInfo(null, soundSerial1[i], soundSerial2[i]);
                soundArray[i] = info;
            }
        }
    }

    void OnDestroy()
    {
        effectSerial1 = null;
        effectSerial2 = null;
        soundSerial1 = null;
        soundSerial2 = null;
    }
}
