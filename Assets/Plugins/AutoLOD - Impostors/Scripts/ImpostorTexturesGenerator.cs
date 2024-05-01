// Copyright (c) 2021-2022 Léo Chaumartin

#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System.Collections;
using AutoLOD.Impostors;

public class ImpostorTexturesGenerator : AbstractImpostorTexturesGenerator
{

    public UniversalRenderPipelineAsset normalsPipelineAsset;
    UniversalRenderPipelineAsset lastPipelineAsset;
#if UNITY_2021_3_OR_NEWER
    public UniversalRendererData rendererData;
#else
    public ForwardRendererData rendererData;
#endif
    protected Material[] mats;
    protected Mesh targetMesh;

    protected bool mergeStep = false;

    protected RenderTexture rt;
    protected Texture2D[] colors;
    protected Texture2D[] depths;
    protected Texture2D[] normals;
    protected Texture2D output;
    protected Texture2D normalsOutput;


    protected Shader _mergeShader;
    protected Shader mergeShader
    {
        get { return _mergeShader != null ? _mergeShader : (_mergeShader = Shader.Find("AutoLOD/MergeChannels")); }
    }

    protected Material _mergeMaterial;
    protected Material mergeMaterial
    {
        get
        {
            if (_mergeMaterial == null)
            {
                _mergeMaterial = new Material(mergeShader);
                _mergeMaterial.hideFlags = HideFlags.HideAndDontSave;
            }
            return _mergeMaterial;
        }
    }


    protected override void Init()
    {
        if (target == null)
            target = GameObject.Find("Target");
        if (target == null)
            Debug.LogWarning("[AutoLOD - Impostors] : Invalid baking scene : No GameObject named \"Target\" found.");

        lastPipelineAsset = (UniversalRenderPipelineAsset)QualitySettings.renderPipeline;
        QualitySettings.renderPipeline = normalsPipelineAsset;

        targetMesh = AssetDatabase.LoadAssetAtPath<Mesh>(meshPath);

        targetMesh.RecalculateNormals();
        targetMesh.RecalculateBounds();

        if (target == null)
        {
            target = GameObject.Find("Target");

        }
        if (target.GetComponent<MeshFilter>() == null)
            target.AddComponent<MeshFilter>();
        if (target.GetComponent<MeshRenderer>() == null)
            target.AddComponent<MeshRenderer>();

        target.GetComponent<MeshFilter>().sharedMesh = targetMesh;

        mats = new Material[materialPaths.Length];
        for (int i = 0; i < materialPaths.Length; ++i)
        {
            mats[i] = AssetDatabase.LoadAssetAtPath<Material>(materialPaths[i]);
            if (mats[i] == null)
            {
                mats[i] = Resources.Load(materialPaths[i]) as Material;
                if (mats[i] == null) // we apply the default material
                    mats[i] = AssetDatabase.GetBuiltinExtraResource<Material>("Default-Diffuse.mat");
            }
        }
        target.GetComponent<MeshRenderer>().sharedMaterials = mats;

        target.transform.rotation = transformRot; 
        Vector3 pos = new Vector3(-pivotExentricity.x, -target.GetComponent<MeshRenderer>().bounds.center.y * target.transform.localScale.y, -pivotExentricity.z);
        target.transform.position = pos;
        rt = new RenderTexture(texSize, texSize, 24, RenderTextureFormat.ARGB32);
        rt.Create();
        Camera.main.aspect = 1.0f;
        Camera.main.orthographicSize = orthoCamSize;
        Camera.main.targetTexture = rt;
        Camera.main.forceIntoRenderTexture = true;

        Camera.main.transform.position = GetCamPos();
        Camera.main.transform.LookAt(Vector3.zero);

        if (mergeShader == null || !mergeShader.isSupported)
        {
            Debug.LogError("The AutoLOD merge shader. Please reinstall the package.");
        }

        Camera.main.depthTextureMode = DepthTextureMode.Depth;

        colors = new Texture2D[subdivisions * subdivisions];
        depths = new Texture2D[subdivisions * subdivisions];
        normals = new Texture2D[subdivisions * subdivisions];
        for (int i = 0; i < subdivisions * subdivisions; ++i)
        {
            colors[i] = new Texture2D(texSize, texSize, TextureFormat.ARGB32, false);
            depths[i] = new Texture2D(texSize, texSize, TextureFormat.ARGB32, false);
            normals[i] = new Texture2D(texSize, texSize, TextureFormat.ARGB32, false);
        }
        UpdatePipelineSettings();
    }

    private void UpdatePipelineSettings()
    {
        if (currentSubdivision == 0)
        {
            rendererData.rendererFeatures[0].SetActive(true);
            rendererData.rendererFeatures[1].SetActive(false);
        }
        if (currentSubdivision == subdivisions * subdivisions - 1)
        {
            rendererData.rendererFeatures[0].SetActive(false);
            rendererData.rendererFeatures[1].SetActive(false);
        }

        if (currentSubdivision == 2 * subdivisions * subdivisions - 1)
        {
            rendererData.rendererFeatures[0].SetActive(false);
            rendererData.rendererFeatures[1].SetActive(true);
        }
    }

    IEnumerator PostRender()
    {
        yield return new WaitForEndOfFrame();
        EditorUtility.DisplayProgressBar("AutoLOD - Impostors", "Baking in progress...", currentSubdivision / (float)(3 * subdivisions * subdivisions));
        currentSubdivision++;
        Camera.main.transform.position = GetCamPos();
        Camera.main.transform.LookAt(Vector3.zero);

        UpdatePipelineSettings();

        if (currentSubdivision < 3 * subdivisions * subdivisions)
        {
            if (currentSubdivision >= 0)
            {
                RenderTexture.active = rt;
                Texture2D res = new Texture2D(texSize, texSize, TextureFormat.ARGB32, true);
                res.ReadPixels(new Rect(0, 0, texSize, texSize), 0, 0);

                RenderTexture.active = null;
                if (currentSubdivision >= 2 * subdivisions * subdivisions)
                {
                    normals[currentSubdivision - 2 * subdivisions * subdivisions].SetPixels(0, 0, texSize, texSize, res.GetPixels(0, 0, texSize, texSize));
                }
                else if (currentSubdivision >= subdivisions * subdivisions)
                    colors[currentSubdivision - subdivisions * subdivisions].SetPixels(0, 0, texSize, texSize, res.GetPixels(0, 0, texSize, texSize));
                else
                {
                    if (depths != null)
                        depths[currentSubdivision].SetPixels(0, 0, texSize, texSize, res.GetPixels(0, 0, texSize, texSize));
                }
            }

        }
        else if (!mergeStep)
        {
            QualitySettings.renderPipeline = lastPipelineAsset;
            AssetDatabase.Refresh();
            AssetDatabase.SaveAssets();
            Merge();
            mergeStep = true;
        }
        else
        {
            AssetDatabase.Refresh();
            AssetDatabase.SaveAssets();
            AssetDatabase.DeleteAsset(meshPath);
            EditorApplication.isPlaying = false;
            EditorUtility.ClearProgressBar();
        }

    }

    protected override void Loop()
    {
        StartCoroutine(PostRender());
    }

    void Merge()
    {
        int atlasSizePx = texSize * subdivisions;
        output = new Texture2D(atlasSizePx, atlasSizePx, TextureFormat.ARGB32, false);
        normalsOutput = new Texture2D(atlasSizePx, atlasSizePx, TextureFormat.ARGB32, false);
        Texture2D color;
        Texture2D depth;
        Texture2D normal;
        for (int i = 0; i < subdivisions * subdivisions; ++i)
        {
            if (i < nbPics)
            {
                color = colors[i];
                depth = depths[i];
                normal = normals[i];
                mergeMaterial.SetTexture("_DepthTex", depth);
                Graphics.Blit(color, mergeMaterial);
                int col = i % subdivisions;
                int row = Mathf.FloorToInt(i / (float)subdivisions);
                output.SetPixels(col * texSize, row * texSize, texSize, texSize, color.GetPixels(0, 0, texSize, texSize));
                normalsOutput.SetPixels(col * texSize, row * texSize, texSize, texSize, normal.GetPixels(0, 0, texSize, texSize));

            }
        }
        output.Apply();

        output = Resize(output, Mathf.ClosestPowerOfTwo(atlasSizePx));
        SetTextureReadable(output, false);
        AssetDatabase.CreateAsset(output, outputPath);

        normalsOutput.Apply();

        normalsOutput = Resize(normalsOutput, Mathf.ClosestPowerOfTwo(atlasSizePx));
        AssetDatabase.CreateAsset(normalsOutput, outputPathNormals);
        SetTextureReadable(normalsOutput, false, true);

        AssetDatabase.Refresh();
        AssetDatabase.SaveAssets();
    }

    Texture2D Resize(Texture2D texture2D, int targetSide)
    {
        RenderTexture tmp = new RenderTexture(targetSide, targetSide, 24);
        RenderTexture.active = tmp;
        Graphics.Blit(texture2D, tmp);
        Texture2D result = new Texture2D(targetSide, targetSide);
        result.ReadPixels(new Rect(0, 0, targetSide, targetSide), 0, 0);
        result.Apply();
        return result;
    }
}
#endif