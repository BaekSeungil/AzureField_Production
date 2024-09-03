using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CameraSensitivityControl : MonoBehaviour
{
    public CinemachineFreeLook cinema;

    public Slider sliderY;
    public Slider sliderX;

    float yValue = 1;
    float xValue = 1;

    // Start is called before the first frame update
    void Start()
    {
       
    }

    // Update is called once per frame
    void Update()
    {
        yValue = sliderY.value * 0.01f;
        cinema.m_YAxis = new AxisState(0, 1, false, true, yValue, 0.2f, 0.1f, "Mouse Y", false);
        xValue = sliderY.value * 0.5f;
        cinema.m_XAxis = new AxisState(-180, 180, true, false, xValue, 0.1f, 0.1f, "Mouse X", true);
    }
}

//public AxisState m_YAxis = new AxisState(0, 1, false, true, 2f, 0.2f, 0.1f, "Mouse Y", false); 0.001
//public AxisState m_XAxis = new AxisState(-180, 180, true, false, 300f, 0.1f, 0.1f, "Mouse X", true); 0.05
