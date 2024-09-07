using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class CameraSensitivityControl : MonoBehaviour
{
    public CinemachineFreeLook cinema;

    public Slider sliderY;
    public Slider sliderX;

    float yValue = 1;
    float xValue = 1;

    Vector2 defaultSpeed;

    // Start is called before the first frame update

    void OnEnable()
    {
        cinema = FindObjectOfType<CinemachineFreeLook>();
        if (PlayerPrefs.HasKey("x_sensitivity"))
        {
            sliderX.value = PlayerPrefs.GetFloat("x_sensitivity");
        }
        if (PlayerPrefs.HasKey("y_sensitivity"))
        {
            sliderY.value = PlayerPrefs.GetFloat("y_sensitivity");
        }

        if (cinema != null)
            defaultSpeed = new Vector2(cinema.m_XAxis.m_MaxSpeed, cinema.m_YAxis.m_MaxSpeed);
    }

    
    void Update()
    {
        //// 슬라이더 값을 통해 속도 계산
        //yValue = sliderY.value * 0.01f;
        //xValue = sliderX.value * 0.5f;

        //// Y축 감도 조절 (Input Value Gain)
        //cinema.m_YAxis.m_MaxSpeed = yValue;  // Input Value Gain으로 설정
        //cinema.m_YAxis.m_InputAxisName = "Mouse Y";  // 마우스 Y 입력

        //// X축 감도 조절 (Input Value Gain)
        //cinema.m_XAxis.m_MaxSpeed = xValue;  // Input Value Gain으로 설정
        //cinema.m_XAxis.m_InputAxisName = "Mouse X";  // 마우스 X 입력

        //// Input Value Gain 모드로 설정
        //cinema.m_XAxis.m_SpeedMode = AxisState.SpeedMode.InputValueGain;
        //cinema.m_YAxis.m_SpeedMode = AxisState.SpeedMode.InputValueGain;

        ///*
        //yValue = sliderY.value * 0.01f;
        //cinema.m_YAxis.m_SpeedMode = AxisState.SpeedMode.InputValueGain;
        //cinema.m_YAxis = new AxisState(0, 1, false, true, yValue, 0.2f, 0.1f, "Mouse Y", false);


        //xValue = sliderX.value * 0.5f;
        //cinema.m_XAxis.m_SpeedMode = AxisState.SpeedMode.InputValueGain;
        //cinema.m_XAxis = new AxisState(-180, 180, true, false, xValue, 0.1f, 0.1f, "Mouse X", true);
        //*/
    }

    private void OnDisable()
    {
        if (cinema != null)
        {
            cinema.m_XAxis.m_MaxSpeed = defaultSpeed.x;
            cinema.m_YAxis.m_MaxSpeed = defaultSpeed.y;
        }
    }

    Vector2 x_range = new Vector2(0.1f, 1.4f);
    Vector2 y_range = new Vector2(0.1f, 1.4f);

    public void SetSensitivityX(float value)
    {
        if (cinema != null)
            cinema.m_XAxis.m_MaxSpeed = Mathf.Lerp(x_range.x * defaultSpeed.x, x_range.y * defaultSpeed.x, value);
        PlayerPrefs.SetFloat("x_sensitivity", value);
    }

    public void SetSensitivityY(float value)
    {
        if (cinema != null)
            cinema.m_YAxis.m_MaxSpeed = Mathf.Lerp(y_range.x * defaultSpeed.y, y_range.y * defaultSpeed.y, value);
        PlayerPrefs.SetFloat("y_sensitivity", value);
    }
}



//public AxisState m_YAxis = new AxisState(0, 1, false, true, 2f, 0.2f, 0.1f, "Mouse Y", false); 0.001
//public AxisState m_XAxis = new AxisState(-180, 180, true, false, 300f, 0.1f, 0.1f, "Mouse X", true); 0.05
