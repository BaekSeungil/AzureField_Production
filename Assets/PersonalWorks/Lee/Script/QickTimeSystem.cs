using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.InputSystem;
using Mono.Cecil.Cil;

public class QickTimeSystem : MonoBehaviour
{

    public float fillAmount = 0;
    public float timeThreshold = 0;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        CountButton();
    }

    public void CountButton()
    {
        if(Keyboard.current[Key.A].wasPressedThisFrame)
        {
            fillAmount += 0.2f;
        }
        timeThreshold += Time.deltaTime;

        if(timeThreshold> 0.1f)
        {

        }
        timeThreshold = 0;
        fillAmount -= 0.02f;
        
        if(fillAmount < 0)
        {
            fillAmount = 0;
        }
        GetComponent<Image>().fillAmount = fillAmount;
    }
}
