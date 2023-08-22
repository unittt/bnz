using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;


public class AudioTools : AssetPostprocessor
{
    public void OnPreprocessAudio()
    {
        AudioImporter importer = (AudioImporter)AudioImporter.GetAtPath(assetPath);
        AudioImporterSampleSettings importerSetting = importer.defaultSampleSettings;
        importerSetting.compressionFormat = AudioCompressionFormat.Vorbis;
        importerSetting.loadType = AudioClipLoadType.CompressedInMemory;
        importer.defaultSampleSettings = importerSetting;

    }
}