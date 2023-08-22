using UnityEngine;
using System;

public class UnityEditTextStyle
{
    public static AndroidJavaClass javaClass;

    public AndroidJavaObject obj;

    public UnityEditTextStyle()
    {
#if UNITY_ANDROID
        obj = new AndroidJavaObject("com.cilugame.h1.input.UnityEditTextStyle");
#endif
    }

    private int _left;
    public int left
    {
        get
        {
            return _left;
        }

        set
        {
            _left = value;
#if UNITY_ANDROID
            obj.Set("left", value);
#endif
        }
    }

    private int _top;
    public int top
    {
        get
        {
            return _top;
        }
        set
        {
            _top = value;
#if UNITY_ANDROID
            obj.Set("top", value);
#endif
        }
    }

    private int _width;
    public int width
    {
        get
        {
            return _width;
        }
        set
        {
            _width = value;
#if UNITY_ANDROID
            obj.Set("width", value);
#endif
        }
    }

    private int _height;
    public int height
    {
        get
        {
            return _height;
        }
        set
        {
            _height = value;
#if UNITY_ANDROID
            obj.Set("height", value);
#endif
        }
    }

    private float _textSize;
    public float textSize
    {
        get
        {
            return _textSize;
        }
        set
        {
            _textSize = value;
#if UNITY_ANDROID
            obj.Set("textSize", value);
#endif
        }
    }

    private Color _textColor;
    public Color textColor
    {
        get
        {
            return _textColor;
        }
        set
        {
            _textColor = value;
#if UNITY_ANDROID
            obj.Set("textColorA", (int)(_textColor.a * 255));
            obj.Set("textColorR", (int)(_textColor.r * 255));
            obj.Set("textColorG", (int)(_textColor.r * 255));
            obj.Set("textColorB", (int)(_textColor.b * 255));
#endif
        }
    }

    private NGUIText.Alignment _alignment;
    public NGUIText.Alignment alignment
    {
        get
        {
            return _alignment;
        }
        set
        {
            _alignment = value;
#if UNITY_ANDROID
            int gravity;
            switch(_alignment)
            {
            case NGUIText.Alignment.Left:
                gravity = 19;
                break;
            case NGUIText.Alignment.Right:
                gravity = 21;
                break;
            default:
                gravity = 17;
                break;
            }
            obj.Set("alignment", gravity);
#endif
        }
    }

    private int _maxLength;
    public int maxLength
    {
        get
        {
            return _maxLength;
        }
        set
        {
            _maxLength = value;
#if UNITY_ANDROID
            obj.Set("maxLength", value);
#endif
        }
    }

    private UIInput.KeyboardType _inputMode;
    public UIInput.KeyboardType inputMode
    {
        get
        {
            return _inputMode;
        }
        set
        {
            _inputMode = value;
#if UNITY_ANDROID
            int mode = 0;
            switch (_inputMode)
            {
                case UIInput.KeyboardType.NumbersAndPunctuation:
                    mode = 2;
                    break;
                case UIInput.KeyboardType.NumberPad:
                    mode = 2;
                    break;
                case UIInput.KeyboardType.PhonePad:
                    mode = 3;
                    break;
                case UIInput.KeyboardType.URL:
                    mode = 4;
                    break;
                case UIInput.KeyboardType.EmailAddress:
                    mode = 1;
                    break;
            }
            obj.Set("inputMode", mode);
#endif
        }
    }

    private UIInput.InputType _inputFlag;
    public UIInput.InputType inputFlag
    {
        get
        {
            return _inputFlag;
        }
        set
        {
            _inputFlag = value;
#if UNITY_ANDROID
            int flag = 0;
            if(_inputFlag == UIInput.InputType.Password)
            {
                flag = 1;
            }
            obj.Set("inputFlag", flag);
#endif
        }
    }

    private UIInput.OnReturnKey _inputReturn;
    public UIInput.OnReturnKey inputReturn
    {
        get
        {
            return _inputReturn;
        }
        set
        {
            _inputReturn = value;
#if UNITY_ANDROID
            int returnKey = 0;
            switch (_inputReturn)
            {
                case UIInput.OnReturnKey.Default:
                    returnKey = 0;
                    break;
                case UIInput.OnReturnKey.Submit:
                    returnKey = 1;
                    break;
            }
            obj.Set("inputReturn", returnKey);
#endif
        }
    }

}
