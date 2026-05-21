using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class EncounterPopUps : MonoBehaviour
{
    public TextMeshProUGUI textDisplay;
    public DmgType dmgType;

    public float lifeTime = 2f;


    public void SetText(string text)
    {
        textDisplay.text = text;
        // StartCoroutine(Hide());

    }



    IEnumerator Hide()
    {
        yield return new WaitForSeconds(lifeTime);
        // Destroy(gameObject);
        textDisplay.text = "";
        // EncounterPopUps.SetActive(false);
    }

    public void ClearText()
    {
        textDisplay.text = "";
    }

    public void DestroyText()
    {
        Destroy(gameObject);
    }



}
