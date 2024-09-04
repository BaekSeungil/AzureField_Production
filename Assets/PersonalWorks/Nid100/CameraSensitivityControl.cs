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
        if (cinema == null)
        {
            cinema = FindObjectOfType<CinemachineFreeLook>();
        }
    }

    // Update is called once per frame
    void Update()
    {

        // 슬라이더 값을 통해 속도 계산
        yValue = sliderY.value * 0.01f;
        xValue = sliderX.value * 0.5f;

        // Y축 감도 조절 (Input Value Gain)
        cinema.m_YAxis.m_MaxSpeed = yValue;  // Input Value Gain으로 설정
        cinema.m_YAxis.m_InputAxisName = "Mouse Y";  // 마우스 Y 입력

        // X축 감도 조절 (Input Value Gain)
        cinema.m_XAxis.m_MaxSpeed = xValue;  // Input Value Gain으로 설정
        cinema.m_XAxis.m_InputAxisName = "Mouse X";  // 마우스 X 입력

        // Input Value Gain 모드로 설정
        cinema.m_XAxis.m_SpeedMode = AxisState.SpeedMode.InputValueGain;
        cinema.m_YAxis.m_SpeedMode = AxisState.SpeedMode.InputValueGain;

        /*
        yValue = sliderY.value * 0.01f;
        cinema.m_YAxis.m_SpeedMode = AxisState.SpeedMode.InputValueGain;
        cinema.m_YAxis = new AxisState(0, 1, false, true, yValue, 0.2f, 0.1f, "Mouse Y", false);


        xValue = sliderX.value * 0.5f;
        cinema.m_XAxis.m_SpeedMode = AxisState.SpeedMode.InputValueGain;
        cinema.m_XAxis = new AxisState(-180, 180, true, false, xValue, 0.1f, 0.1f, "Mouse X", true);
        */
    }
}

//public AxisState m_YAxis = new AxisState(0, 1, false, true, 2f, 0.2f, 0.1f, "Mouse Y", false); 0.001
//public AxisState m_XAxis = new AxisState(-180, 180, true, false, 300f, 0.1f, 0.1f, "Mouse X", true); 0.05
