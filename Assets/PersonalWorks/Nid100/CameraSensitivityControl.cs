using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.Localization.Plugins.XLIFF.V12;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Processors;
using UnityEngine.UI;

public class CameraSensitivityControl : MonoBehaviour
{
    public Slider sliderY;
    public Slider sliderX;

    float yValue = 1;
    float xValue = 1;

    float gamepadScaleDefault = 50f;

    Vector2 defaultValue = new Vector2(0.2f, 0.002f);

    MainPlayerInputActions input;
    private CinemachineFreeLook cinema;

    // Start is called before the first frame update

    private void Awake()
    {
        input = new MainPlayerInputActions();
    }

    void OnEnable()
    {
        cinema = FindObjectOfType<CinemachineFreeLook>();
        if (PlayerPrefs.HasKey("x_sensitivity"))
        {
            sliderX.value = PlayerPrefs.GetFloat("x_sensitivity");
            SetSensitivityX(sliderX.value);

        }
        if (PlayerPrefs.HasKey("y_sensitivity"))
        {
            sliderY.value = PlayerPrefs.GetFloat("y_sensitivity");
            SetSensitivityY(sliderY.value); 
        }
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


    public void SetSensitivityX(float value)
    {
        Debug.Log("Value x : " + value);
        OverrideProcessor_x(value * defaultValue.x);
        PlayerPrefs.SetFloat("x_sensitivity", value);
    }

    public void SetSensitivityY(float value)
    {
        Debug.Log("Value y : " + value);
        OverrideProcessor_y(value * defaultValue.y);
        PlayerPrefs.SetFloat("y_sensitivity", value);
    }

    public void OverrideProcessor_x(float x)
    {
        cinema = FindAnyObjectByType<CinemachineFreeLook>();
        cinema.m_XAxis.m_MaxSpeed = x;
        //input.Player.Look.ApplyParameterOverride("scaleVector2:x", x,InputBinding.MaskByGroup("Pointer"));
        //input.Player.Look.ApplyParameterOverride("scaleVector2:x", x * gamepadScaleDefault, InputBinding.MaskByGroup("Gamepad"));
    }

    public void OverrideProcessor_y(float y)
    {
        cinema = FindAnyObjectByType<CinemachineFreeLook>();
        cinema.m_YAxis.m_MaxSpeed = y;
        //input.Player.Look.ApplyParameterOverride("scaleVector2:y", y, InputBinding.MaskByGroup("Pointer"));
        //input.Player.Look.ApplyParameterOverride("scaleVector2:y", y * gamepadScaleDefault, InputBinding.MaskByGroup("Gamepad"));
    }
}



//public AxisState m_YAxis = new AxisState(0, 1, false, true, 2f, 0.2f, 0.1f, "Mouse Y", false); 0.001
//public AxisState m_XAxis = new AxisState(-180, 180, true, false, 300f, 0.1f, 0.1f, "Mouse X", true); 0.05
