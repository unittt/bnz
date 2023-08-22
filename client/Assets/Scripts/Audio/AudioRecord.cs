using System;
using System.IO;
using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using AssetPipeline;

public enum AudioRecordError
{
    None,
    FileNotExist,
    AudioNoData,
    NoMicrophone,
    IsRecording,
    IsNotRecording,
    RecordTooShort,
    IsSilence,
    IsToShort,
}


public class AudioRecord
{
    private static GameObject recordRootGo;
    private static readonly string AMR_HEAD = "#!AMR\n";
    
    private AudioClip recordClip;
    private float[] recordSample = null;
    private int recordLength = 0;
    private float startRecordTime;
    private int sampleRate = 8000;
    private int minRecordTime;
    private int maxRecordTime;

    public static AudioRecord Instance
    {
        get;
        private set;
    }

    public static void CreateInsatnce()
    {
        if (Instance != null)
        {
            Debug.LogError("AudioRecord.Instance already exist");
            return;
        }
        Instance = new AudioRecord();
    }

    public static void Release()
    {
        if (Instance != null)
        {
            Instance.EndRecord();
        }
    }

    public AudioRecordError StartRecord(int minSeconds, int maxSeconds)
    {
        if (Microphone.devices.Length == 0)
        {
            return AudioRecordError.NoMicrophone;
        }

        if (Microphone.IsRecording(null))
        {
            return AudioRecordError.IsRecording;
        }
        startRecordTime = Time.realtimeSinceStartup;
        recordClip = Microphone.Start(null, false, maxSeconds, sampleRate);
        minRecordTime = minSeconds;
        return AudioRecordError.None;
    }

    public AudioRecordError EndRecord()
    {
        if (!Microphone.IsRecording(null))
        {
            return AudioRecordError.IsNotRecording;
        }

        Microphone.End(null);
        if (recordSample == null || recordSample.Length != recordClip.samples)
        {
            recordSample = new float[recordClip.samples];
        }
        recordClip.GetData(recordSample, 0);

        float recordTime = Time.realtimeSinceStartup - startRecordTime;
        recordLength = Mathf.Min(recordClip.samples, (int)(recordTime * sampleRate));

        if (recordTime < minRecordTime)
        {
            return AudioRecordError.IsToShort;
        }
        if (IsSilence(recordSample, recordLength))
        {
            return AudioRecordError.IsSilence;
        }
        return AudioRecordError.None;
    }

    private bool IsSilence(float[] sampleData, int sampleLength)
    {
        for (int i = 0; i < sampleLength; i += 100)
        {
            if (sampleData[i] > 0.001)
            {
                return false;
            }
        }
        return true;
    }

    public bool SaveToAmr(string path)
    {
        if (recordSample == null)
            return false;

        byte[] data = AmrDLL.Encode(recordSample, recordLength);
        if (data == null)
            return false;

        IOHelper.CreateDirectory(Path.GetDirectoryName(path));
        using (FileStream fileStream = new FileStream(path, FileMode.Create))
        {
            byte[] b = System.Text.Encoding.UTF8.GetBytes(AMR_HEAD);
            fileStream.Write(b, 0, b.Length);
            fileStream.Write(data, 0, data.Length);
            fileStream.Close();
        }
        return true;
    }
    

    public bool SaveToWav(string file)
    {
        if (recordSample == null)
            return false;

        MemoryStream stream = SampleToWav(recordSample, recordLength, recordClip.frequency, recordClip.channels);
        string path = Path.Combine(GameResPath.persistentDataPath, file);
        IOHelper.CreateDirectory(Path.GetDirectoryName(path));
        using (FileStream fileStream = new FileStream(path, FileMode.Create))
        {
            fileStream.Write(stream.GetBuffer(), 0, (int)stream.Length);
            fileStream.Close();
        }
        return true;
    }


    public MemoryStream SampleToWav(float[] sampleData, int samples, int hz, int channels)
    {
        MemoryStream stream = new MemoryStream();

        Int16[] intData = new Int16[samples];
        //converting in 2 float[] steps to Int16[], //then Int16[] to Byte[]  

        Byte[] bytesData = new Byte[samples * 2];
        //bytesData array is twice the size of  
        //dataSource array because a float converted in Int16 is 2 bytes.  

        int rescaleFactor = 32767; //to convert float to Int16  

        for (int i = 0; i < samples; i++)
        {
            intData[i] = (short)(sampleData[i] * rescaleFactor);
            Byte[] byteArr = new Byte[2];
            byteArr = BitConverter.GetBytes(intData[i]);
            byteArr.CopyTo(bytesData, i * 2);
        }

        stream.Write(bytesData, 0, bytesData.Length);

        stream.Seek(0, SeekOrigin.Begin);

        Byte[] riff = System.Text.Encoding.UTF8.GetBytes("RIFF");
        stream.Write(riff, 0, 4);

        Byte[] chunkSize = BitConverter.GetBytes(stream.Length - 8);
        stream.Write(chunkSize, 0, 4);

        Byte[] wave = System.Text.Encoding.UTF8.GetBytes("WAVE");
        stream.Write(wave, 0, 4);

        Byte[] fmt = System.Text.Encoding.UTF8.GetBytes("fmt ");
        stream.Write(fmt, 0, 4);

        Byte[] subChunk1 = BitConverter.GetBytes(16);
        stream.Write(subChunk1, 0, 4);

        UInt16 two = 2;
        UInt16 one = 1;

        Byte[] audioFormat = BitConverter.GetBytes(one);
        stream.Write(audioFormat, 0, 2);

        Byte[] numChannels = BitConverter.GetBytes(channels);
        stream.Write(numChannels, 0, 2);

        Byte[] sampleRate = BitConverter.GetBytes(hz);
        stream.Write(sampleRate, 0, 4);

        Byte[] byteRate = BitConverter.GetBytes(hz * channels * 2); // sampleRate * bytesPerSample*number of channels, here 44100*2*2  
        stream.Write(byteRate, 0, 4);

        UInt16 blockAlign = (ushort)(channels * 2);
        stream.Write(BitConverter.GetBytes(blockAlign), 0, 2);

        UInt16 bps = 16;
        Byte[] bitsPerSample = BitConverter.GetBytes(bps);
        stream.Write(bitsPerSample, 0, 2);

        Byte[] datastring = System.Text.Encoding.UTF8.GetBytes("data");
        stream.Write(datastring, 0, 4);

        Byte[] subChunk2 = BitConverter.GetBytes(samples * channels * 2);
        stream.Write(subChunk2, 0, 4);

        return stream;
    }

    public float GetRecordVolume(int size)
    {
        if (!Microphone.IsRecording(null))
            return 0;

        int pos = Microphone.GetPosition(null);
        if (pos == 0)
        {
            return 0f;
        }
        if (pos < size)
        {
            size = pos;
        }

        float[] samples = new float[size];
        recordClip.GetData(samples, pos - size);

        float maxValue = 0f;
        for (int i = 0; i < size; i++)
        {
            if (samples[i] > maxValue)
            {
                maxValue = samples[i];
            }
        }
        return maxValue;
    }

    public AudioRecordError GetClipAmr(string path, out AudioClip clip)
    {
        clip = null;
        if (string.IsNullOrEmpty(path))
        {
            return AudioRecordError.FileNotExist;
        }

        if (!File.Exists(path))
        {
            return AudioRecordError.FileNotExist;
        }

        float[] samples = null;
        try
        {
            byte[] data = File.ReadAllBytes(path);
            samples = AmrDLL.Decode(data, AMR_HEAD.Length);
        }
        catch (Exception e)
        {
            GameDebug.LogError(e.Message);
            return AudioRecordError.AudioNoData;
        }

        clip = AudioClip.Create("audio", samples.Length, 1, sampleRate, false);
        clip.SetData(samples, 0);
        return AudioRecordError.None;
    }

    public AudioRecordError PlayAmr(string path)
    {
        if (string.IsNullOrEmpty(path))
        {
            return AudioRecordError.FileNotExist;
        }

        if (!File.Exists(path))
        {
            return AudioRecordError.FileNotExist;
        }

        float[] samples = null;
        try
        {
            byte[] data = File.ReadAllBytes(path);
            samples = AmrDLL.Decode(data, AMR_HEAD.Length);
        }
        catch (Exception e)
        {
            GameDebug.LogError(e.Message);
            return AudioRecordError.AudioNoData;
        }
        
        AudioClip clip = AudioClip.Create("audio", samples.Length, 1, sampleRate, false);
        clip.SetData(samples, 0);
        Play(clip);
        return AudioRecordError.None;
    }

    public void Play(AudioClip audioClip)
    {
        GameObject go = new GameObject("amr " + audioClip.name);
        AudioSource audioSource = go.AddComponent<AudioSource>();
        audioSource.clip = audioClip;
        audioSource.loop = false;
        audioSource.Play();
        //StartCoroutine(OnStopPlay(audioSource, audioClip.length));
    }

    //public IEnumerator OnStopPlay(AudioSource audioSource, float time)
    //{
    //    yield return new WaitForSeconds(time);
    //    GameObject.Destroy(audioSource);
    //}
}