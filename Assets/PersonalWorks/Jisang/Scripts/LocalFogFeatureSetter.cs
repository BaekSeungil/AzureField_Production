using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

namespace JJS
{
    public class LocalFogFeatureSetter : MonoBehaviour
    {

        [SerializeField]
        private UniversalRendererData renderDataAsset;

        [SerializeField]
        private Material VolumetricFogMat;

        private VolumetricRendering VolumetricCloudsFeature;

        private bool isInitialized;
        private void Awake()
        {
            isInitialized = Initialize();
        }

        private bool Initialize()
        {
            if (renderDataAsset == null)
                return false;

            //Not Contains
            VolumetricCloudsFeature = new VolumetricRendering();
            var setting = new VolumetricRendering.Settings()
            {
                material = VolumetricFogMat,
                materialPassIndex = -1
            };
            VolumetricCloudsFeature.SetSetting(setting);
            VolumetricCloudsFeature.Create();

            renderDataAsset.rendererFeatures.Add(VolumetricCloudsFeature);

            renderDataAsset.SetDirty();
            return true;
        }

        private void OnDestroy()
        {
            renderDataAsset.rendererFeatures.Remove(VolumetricCloudsFeature);
            renderDataAsset.SetDirty();
        }
    }

}