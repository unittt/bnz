using System;
using UnityEngine;
using AssetPipeline;
using System.Text.RegularExpressions;
using LuaInterface;

public class PhotoReaderManager : MonoBehaviour
{
    public static int MaxSize = 2048;

    public enum PickImageResult
    {
        Cancel,
        ILLEGAL,
        CROP_SUCC,
        COMPRESS_SUCC,
        NotSupported,
    }

    private static PhotoReaderManager _instance;

    public static PhotoReaderManager Instance
    {
        get
        {
            if (_instance == null)
            {
                var go = new GameObject(typeof(PhotoReaderManager).Name);
                _instance = go.AddComponent<PhotoReaderManager>();
            }
            return _instance;
        }
    }

    private string _curFileKey;
    private bool _compress;
    private Vector2 _resizeSize;

    private void Awake()
    {
        DontDestroyOnLoad(gameObject);

        ImagePickerManager.Instance.OnImagePicked += OnImagePicked;
    }


    private void OnDestroy()
    {
        if (_instance == this)
        {
            _instance = null;
        }
    }

    public void DoApplicationQuit()
    {
        ImagePickerManager.Instance.OnImagePicked -= OnImagePicked;
    }


    #region 辅助
    #endregion


    #region 调用接口
	public void ReadAndCropPhoto(string fileName, int cropWidth, int cropHeight, LuaFunction callback)
    {
		PickImage(fileName, true, new Vector2(cropWidth, cropHeight), false, Vector2.zero, callback);
    }

	public void ReadAndCompressPhoto(string fileName, int resizeWidth, int resizeHeight, LuaFunction callback)
    {
		PickImage(fileName, false, Vector2.zero, true, new Vector2(resizeWidth, resizeHeight), callback);
    }


	public void PickImage(string fileName, bool allowsEditing, Vector2 cropSize, bool compress, Vector2 resizeVector, LuaFunction callback)
    {
        _curFileKey = Regex.Replace(fileName, @"^file:/{2,3}", "");
        _compress = compress;
        _resizeSize = resizeVector;
		SetCallback(callback);
        switch (Application.platform)
        {
            case RuntimePlatform.OSXEditor:
            case RuntimePlatform.WindowsEditor:
                {
                    OnPhotoCallBack(!_compress ? PickImageResult.CROP_SUCC : PickImageResult.COMPRESS_SUCC);
                    break;
                }
            case RuntimePlatform.WindowsPlayer:
                {
                    OnPhotoCallBack(PickImageResult.NotSupported);
                    break;
                }
            case RuntimePlatform.Android:
                {
                    string error = null;
                    if (allowsEditing)
                    {
                        error = MobilePhotoReader.ReadAndCropPhoto(name, "OnMobilePhotoCallback", _curFileKey);
                    }
                    else
                    {
                        error = MobilePhotoReader.ReadAndCompressPhoto(name, "OnMobilePhotoCallback", _curFileKey);
                    }
                    // 有错误，直接模拟错误
                    if (!string.IsNullOrEmpty(error))
                    {
                        GameDebug.LogError(error);
                        OnPhotoCallBack(PickImageResult.NotSupported);
                    }
                    break;
                }
            case RuntimePlatform.IPhonePlayer:
                {
                    ImagePickerManager.Instance.PickImage(ImagePickerManager.ImageSource.Album, cropSize.x, cropSize.y, allowsEditing);
                    break;
                }
        }
    }
    #endregion


    #region 非Android处理
    private void OnImagePicked(bool state, string data)
    {
        if (state)
        {
            var tex = ImagePickerManager.GetTexture2DFromString(data);

            if (_compress)
            {
                tex = TextureHelper.LimitingTextureSize(tex, (int)_resizeSize.x, (int)_resizeSize.y);
            }

            tex = TextureHelper.LimitingTextureSize(tex, MaxSize, MaxSize);

            // 将图片存为jpg
            FileHelper.WriteAllBytes(_curFileKey, tex.EncodeToJPG(80));
            Destroy(tex);

            // 模拟Android
            OnPhotoCallBack(!_compress ? PickImageResult.CROP_SUCC : PickImageResult.COMPRESS_SUCC);
        }
        else
        {
            // 模拟Android
            OnPhotoCallBack(PickImageResult.Cancel);
        }
    }
    #endregion


    #region Android处理
    private void OnMobilePhotoCallback(string result)
    {
        GameDebug.Log("OnMobilePhotoCallback result=" + result);

        var state = PickImageResult.Cancel;
        try
        {
            state = (PickImageResult)Enum.Parse(typeof(PickImageResult), result, true);
        }
        catch (Exception e)
        {
            // ignored
        }

        OnPhotoCallBack(state);
    }

    #endregion

	private  LuaFunction _onPhotoCallback;
	public void SetCallback(LuaFunction func)
	{
		if (_onPhotoCallback != null)
		{
			_onPhotoCallback.Dispose();
			_onPhotoCallback = null;
		}
		_onPhotoCallback = func;
	}
    private void OnPhotoCallBack(PickImageResult result)
    {
		if (_onPhotoCallback != null)
		{
			_onPhotoCallback.Call(result);
			_onPhotoCallback.Dispose();
			_onPhotoCallback = null;
		}
    }
}
