using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class slider_EnemyHP : MonoBehaviour
{

    public GameObject Bar;
    public float maxHP;
    public float currentHP;
    // Start is called before the first frame update
    void Start()
    {
        currentHP = maxHP;
    }

    // Update is called once per frame
    void Update()
    {  
       Bar.transform.localScale = new Vector3(currentHP/maxHP, Bar.transform.localScale.y, Bar.transform.localScale.z); 
    }
}
