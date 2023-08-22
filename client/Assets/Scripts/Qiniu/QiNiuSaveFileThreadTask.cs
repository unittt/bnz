using System;
using UnityEngine;

public  class QiNiuSaveFileThreadTask: ThreadTask
{
#pragma warning disable 
    private Action<bool, string> _onPutFinished;
#pragma warning restore
    private bool _isSuccessed;
	private string _key;

    public QiNiuSaveFileThreadTask(ByteArray byteArray, int buffSize, string scope, string key = null,
		bool overwrite = true, string mimeType = null, Action<bool, string> onPutFinished = null, int crc32 = 123)
    {
	    _targetAction = task =>
	    {
		    QiNiuFileExt.PutFileBuf(byteArray.bytes, buffSize, scope, key, overwrite, mimeType, QiNiuPutFinished, crc32);
	    };
        _onPutFinished = onPutFinished;
    }

	private void QiNiuPutFinished(bool successed, string key)
	{
		_isSuccessed = successed;
		_key = key;

        if (_onPutFinished != null)
        {
            _onPutFinished(successed, key);
        }
	}


	public static void SaveFileToQiNiu(ByteArray byteArray, int buffSize, string scope, string key = null,
		bool overwrite = true, string mimeType = null, Action<bool, string> onPutFinished = null, int crc32 = 123)
	{
		var threadTask = new QiNiuSaveFileThreadTask(byteArray, buffSize, scope, key, overwrite, mimeType, onPutFinished, crc32);
		ThreadManager.Instance.AddThread(threadTask);
	}


    //public static void SaveAudio(AudioClip recondClip, int lastPos, string scope, string key = null,
    //    bool overwrite = true, string mimeType = null, Action<bool, string> onPutFinished = null, int crc32 = 123)
    //{
    //    float[] samplesBuf = new float[lastPos + lastPos / 10];
    //    recondClip.GetData(samplesBuf, 0);
    //    byte[] wavBuf = SaveWav.ToWav(samplesBuf, recondClip.frequency, recondClip.channels, recondClip.samples);
    //    byte[] amrBuf = new byte[wavBuf.Length];
    //    int amrSize = (int)HzamrPlugin.WavToAmr(wavBuf, wavBuf.Length, amrBuf);
    //    byte[] amrData = new byte[amrSize];
    //    Array.Copy(amrBuf, amrData, amrSize);

    //    SaveFileToQiNiu(new ByteArray(amrData), amrSize, scope, key, overwrite, mimeType, onPutFinished, crc32);
    //}
}
