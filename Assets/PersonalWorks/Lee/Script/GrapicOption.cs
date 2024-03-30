using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;
using UnityEngine.Rendering;
using Unity.Entities;

public class GrapicOption : MonoBehaviour
{   
   [SerializeField] List<RenderPipelineAsset> RenderPipeLine;
   [SerializeField] TMP_Dropdown Dropdown;

   public void SetPipeLine(int value)
   {
        QualitySettings.SetQualityLevel(value);
        QualitySettings.renderPipeline = RenderPipeLine[value];
   }

}
