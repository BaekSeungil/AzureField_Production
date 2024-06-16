using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEngine.Rendering.Universal;

namespace JS
{
    public class PlayerWaterFilter : MonoBehaviour
    {
        [SerializeField]
        private UniversalRendererData renderDataAsset;

        [SerializeField]
        private Material KuwaharaMat;

        private KuwaharaRenderFeature kuwaharaFeature;

        private bool isInitialized;
        private void Awake()
        {
            isInitialized = Initialize();
        }

        private bool Initialize()
        {
            if (renderDataAsset == null)
                return false;

            foreach (var feature in renderDataAsset.rendererFeatures)
            {
                if (feature is KuwaharaRenderFeature customFeature)
                {
                    kuwaharaFeature = customFeature;
                    return true;
                }
            }
            //return false;

            //Not Contains
            kuwaharaFeature = new KuwaharaRenderFeature();
            var setting = new KuwaharaRenderFeature.KuwaharaSettings()
            {
                passMaterial = KuwaharaMat,
                property = new KuwaharaRenderFeature.KuwaharaProperty() { kernelSize = 5, passes = 2 },
                renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing
            };
            kuwaharaFeature.settings = setting;
            kuwaharaFeature.Create();

            renderDataAsset.rendererFeatures.Add(kuwaharaFeature);

            renderDataAsset.SetDirty();
            return true;
        }

        private void OnEnable()=>
            StartCoroutine(SubscribeState());

        IEnumerator SubscribeState()
        {
            yield return new WaitUntil(() => isInitialized);
            yield return new WaitUntil(() => PlayerCore.Instance != null);

            while(enabled)
            {
                var activeState = PlayerCore.Instance.CurrentPlayerState switch
                {
                    PlayerMovementState.Swimming => true,
                    _ => false
                };

                var reverseState = ((Camera.main.transform.rotation.eulerAngles.x + 360) % 360) < 355 && Camera.main.transform.position.y < 0;

                kuwaharaFeature.SetActive(activeState && reverseState);
                yield return null;
            }

        }

        private void OnDestroy()
        {
            renderDataAsset.rendererFeatures.Remove(kuwaharaFeature);
            renderDataAsset.SetDirty();
        }
    }
}