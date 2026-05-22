using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SliderScript : MonoBehaviour
{
    // Start is called before the first frame update
    public GameObject bar;
    public int maxHP;
    public int currentHP;
    void Start()
    {
        currentHP = maxHP;
    }

    // Update is called once per frame
    void Update()
    {
        bar.transform.localScale = new Vector3(currentHP / maxHP, bar.transform.localScale.y, bar.transform.localScale.z);
    }
}
