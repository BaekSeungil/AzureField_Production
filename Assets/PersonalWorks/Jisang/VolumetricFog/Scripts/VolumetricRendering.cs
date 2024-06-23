using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class VolumetricRendering : ScriptableRendererFeature
{
    class VolumetricRenderPass : ScriptableRenderPass
    {
        private Material material;
        private int materialPassIndex;
        RenderTargetIdentifier cameraColorTexture;

        RenderTexture tempTexture;

        public VolumetricRenderPass(Material material, int materialPassIndex) : base()
        {
            this.materialPassIndex = materialPassIndex;
            this.material = material;
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            RenderTextureDescriptor cameraTextureDesc = renderingData.cameraData.cameraTargetDescriptor;
            tempTexture = RenderTexture.GetTemporary(cameraTextureDesc);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get("VolumetricRenderCommands");

            cameraColorTexture = renderingData.cameraData.renderer.cameraColorTargetHandle;
            RenderTextureDescriptor cameraTextureDesc = renderingData.cameraData.cameraTargetDescriptor;
            cameraTextureDesc.depthBufferBits = 0;

            cmd.Blit(cameraColorTexture, tempTexture, material, this.materialPassIndex);
            cmd.Blit(tempTexture, cameraColorTexture);

            //Execute and release commands
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            RenderTexture.ReleaseTemporary(tempTexture);
        }
    }

    [System.Serializable]
    public class Settings
    {
        public Material material;
        public int materialPassIndex = -1;
    }

    [SerializeField]
    private Settings settings = new Settings();

    VolumetricRenderPass volumetricRenderPass;

    public void SetSetting(in Settings settings) => this.settings = settings;

    /// <inheritdoc/>
    public override void Create()
    {
        volumetricRenderPass = new VolumetricRenderPass(settings.material, settings.materialPassIndex);

        // Configures where the render pass should be injected.
        volumetricRenderPass.renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(volumetricRenderPass);
    }
}


