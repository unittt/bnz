using UnityEngine;
using LuaInterface;
using System;
using System.Collections.Generic;

public class UnityEditDialog
{
    public enum State
    {
        WaitShow,
        Show,
        WaitHide,
        Hide
    }

    public delegate void OnInputCoverDelegate();
    public delegate void OnInputTextChangedDelegate(string text);
    public delegate void OnInputReturnDelegate();
    public delegate void OnInputFinishDelegate();
    public delegate string OnInputValidateDelegate(string text);

    public static OnInputCoverDelegate onInputCover;
    public static OnInputTextChangedDelegate onInputTextChanged;
    public static OnInputReturnDelegate onInputReturn;
    public static OnInputFinishDelegate onInputFinish;
    public static OnInputValidateDelegate onInputValidate;

    private static State currentState = State.Hide;
    private static UIInput currentInput;

    private static List<string> cstrList = new List<string>();

    public static void Update()
    {
        if(cstrList.Count == 0)
        {
            return;
        }
    }

    public static void Release()
    {
        Hide();
        currentState = State.Hide;
        onInputCover = null;
        onInputTextChanged = null;
        onInputReturn = null;
        onInputFinish = null;
        onInputValidate = null;

    }

    public static void Show(UIInput inputControl, string text, UnityEditTextStyle style)
    {
        currentInput = inputControl;
#if UNITY_ANDROID
        AndroidAPI.ShowEditDialog(text, style);
        currentState = State.WaitShow;
#endif
    }

    public static void Hide()
    {
#if UNITY_ANDROID
        AndroidAPI.HideEditDialog();
        currentState = State.WaitHide;
#endif
    }

    public static void SetText(string text)
    {
#if UNITY_ANDROID
        AndroidAPI.SetEditText(text);
#endif
    }

    public static bool IsProcessing(UIInput inputControl)
    {
        return currentInput == inputControl &&
            (UnityEditDialog.currentState == UnityEditDialog.State.Show || UnityEditDialog.currentState == UnityEditDialog.State.WaitShow);
    }

    public static void OnDialogShow()
    {
        currentState = State.Show;
        if (onInputCover != null)
        {
            onInputCover();
        }
    }

    public static void OnDialogHide()
    {
        currentState = State.Hide;
        if (onInputFinish != null)
        {
            onInputFinish();
        }
    }

    public static void OnInputTextChanged(string text)
    {
        if (text == null)
            return;

        if (onInputTextChanged != null)
        {
            onInputTextChanged(text);
        }
    }
    
    public static void OnInputReturn()
    {
        if (onInputReturn != null)
        {
            onInputReturn();
        }
    }
    
    public static string InputValidate(string str)
    {
        if(onInputValidate == null)
        {
            return str;
        }
        string validateStr = onInputValidate(str);
        return validateStr;
    }

    public static void OnSoftInputHeight(string height)
    {
        int intHeight = 0;
        int.TryParse(height, out intHeight);
        GameDebug.Log("OnSoftInputHeight  " + intHeight);
    }
}
