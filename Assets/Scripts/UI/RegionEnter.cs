using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class RegionEnter : StaticSerializedMonoBehaviour<RegionEnter>
{
    [SerializeField] private GameObject visualGroup;
    [SerializeField] private TextMeshProUGUI regionText;
    [SerializeField] new private Animation animation;

    public void OnRegionEnter(string regionName)
    {
        visualGroup.SetActive(true);
        regionText.text = regionName;
        animation.Play();
    }

    public void OnAnimationEnd()
    {
        visualGroup.SetActive(false);
    }
}
