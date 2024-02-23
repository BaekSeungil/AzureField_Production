using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CoroutineTest : MonoBehaviour
{
    Coroutine cor;
    void Start()
    {
        cor = StartCoroutine(Cor_Test());

        Invoke("CheckCoroutine", 5f);
    }

    IEnumerator Cor_Test()
    {
        yield return new WaitForSeconds(3);
        cor = null;
    }

    void CheckCoroutine()
    {
        Debug.Log("IS COROUTINE NULL : " + (cor == null));
    }
}
