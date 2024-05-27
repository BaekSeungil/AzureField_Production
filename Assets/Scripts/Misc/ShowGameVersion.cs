using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class ShowGameVersion : MonoBehaviour
{
    [SerializeField] private TextMeshProUGUI tmp;

    private void Start()
    {
        tmp.text = Application.version;
    }
}
