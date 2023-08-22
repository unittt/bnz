using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;

public static class GameWatch
{
    private static Dictionary<string, long> timeWatchDict = new Dictionary<string, long>();

    public static void StartWatch(string key)
    {
        timeWatchDict[key] = System.DateTime.Now.Ticks;
    }

    public static void EndWatch(string key)
    {
        if (timeWatchDict.ContainsKey(key))
        {
            long interval = System.DateTime.Now.Ticks - timeWatchDict[key];
            GameDebug.Log(string.Format("Tag:{0}  Interval:{1}ms", key, interval / 10000));
            timeWatchDict.Remove(key);
        }
    }
}