using AssetPipeline;

namespace PathologicalGames
{
    public static class PoolManagerConfig
    {

        public static PrefabPoolOption World2DMaPoolOption = new PrefabPoolOption()
        {
            preloadAmount = 15,
            preloadTime = true,
            preloadFrames = 10,

            cullAbove = 30,
            cullDelay = 10,
            cullDespawned = false,
            cullMaxPerPass = 5,

            limitFIFO = false,

        };

    }
}

