using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class BattleLog : MonoBehaviour
{
    public TextMeshProUGUI logText;

    public void UpdateLog(string text)
    {
        typingAnimation(text);
    }

    private void typingAnimation(string text)
    {
        StartCoroutine(TypeSentence(text));
    }

    IEnumerator TypeSentence(string sentence)
    {
        logText.text = "";
        foreach (char letter in sentence.ToCharArray())
        {
            logText.text += letter;
            // Duration of each letter 0.05f
            yield return new WaitForSeconds(0.05f);
        }

    }

}



