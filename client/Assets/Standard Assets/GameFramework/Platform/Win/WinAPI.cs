using System;
using System.Collections.Generic;
using UnityEngine;
using System.Runtime.InteropServices;
using System.Diagnostics;

public class WinAPI
{
#if UNITY_STANDALONE_WIN
    public delegate bool WNDENUMPROC(IntPtr hwnd, uint lParam);

    [DllImport("User32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern bool SetWindowText(IntPtr hwnd, string lPstring);

    [DllImport("User32.dll", SetLastError = true)]
    public static extern bool EnumWindows(WNDENUMPROC lpEnumFunc, uint lParam);

    [DllImport("User32.dll", SetLastError = true)]
    public static extern IntPtr GetParent(IntPtr hWnd);

    [DllImport("User32.dll", SetLastError = true)]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, ref uint lpdwProcessId);

    public static bool ContainCmdArg(string arg)
    {
        string[] argArray = null;
        argArray = Environment.GetCommandLineArgs();
        if (argArray != null)
        {
            for (int i = 0; i < argArray.Length; i++)
            {
                if (arg.Equals(argArray[i]))
                {
                    return true;
                }
            }
        }
        return false;
    }


    public static void SetWindowTitle(string title)
    {
        List<IntPtr> list = GetWindowsList();
        if (list == null || list.Count == 0)
        {
            return;
        }
        foreach (IntPtr wnd in list)
        {
            SetWindowText(wnd, title);
        }
    }

    private static List<IntPtr> GetWindowsList(uint pid = 0)
    {
        List<IntPtr> hWndList = new List<IntPtr>();
        if (pid == 0)
        {
            pid = (uint)Process.GetCurrentProcess().Id;
        }
        EnumWindows(delegate(IntPtr hWnd, uint lParam)
        {
            if (GetParent(hWnd) == IntPtr.Zero)
            {
                uint id = 0;
                GetWindowThreadProcessId(hWnd, ref id);
                if (id == pid)
                {
                    hWndList.Add(hWnd);
                }
            }
            return true;
        }, 1);
        return hWndList;
    }
#endif
}
