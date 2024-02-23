using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "NewOceanProfile", menuName = "CreateNewOceanProfile", order = 1)]
public class OceanProfile : SerializedScriptableObject
{
    //================================================
    //
    // ���� �ٴ� ǥ���� ������ ��� ��ũ���ͺ� ������Ʈ�Դϴ�.
    //
    //================================================

    [SerializeField,ColorUsage(false,true)] private Color oceanColor;           // �ٴ� ��Ʈ���� Emmision ����
    public Color OceanColor { get { return oceanColor; } }
    [SerializeField, Range(0.0f, 1.5f)] private float oceanIntensity;
    public float OceanIntensity { get { return oceanIntensity; } }              // �ĵ� ���� ��
    
    public struct Waveform
    {
        public Vector3 vector;              // �ĵ� ����
        public float amplitude;             // �ĵ� ����
    }

    [SerializeField] private Waveform waveform1;                                // 1�� ����
    public Waveform Waveform1 { get { return waveform1; } }
    [SerializeField] private Waveform waveform2;                                // 2�� ����
    public Waveform Waveform2 { get { return waveform2; } }
    [SerializeField] private Waveform waveform3;                                // 3�� ����
    public Waveform Waveform3 { get { return waveform3; } }
    [SerializeField] private Waveform waveform4;                                // 4�� ����
    public Waveform Waveform4 { get { return waveform4; } }

    public void InitilzeOceanProfile(Color _color, float _oceanIntensity, Vector3 _wv1, float _wa1, Vector3 _wv2, float _wa2, Vector3 _wv3, float _wa3, Vector3 _wv4, float _wa4) 
    {   
        oceanColor = _color; oceanIntensity = _oceanIntensity; 
        waveform1.vector = _wv1; waveform1.amplitude = _wa1;
        waveform2.vector = _wv2; waveform2.amplitude = _wa2;
        waveform3.vector = _wv3; waveform3.amplitude = _wa3;
        waveform4.vector = _wv4; waveform4.amplitude = _wa4;
    }
}
