using System.Collections;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class ChangeTurnPopUps : MonoBehaviour
{
    public float liveTime = 2f;
    public Image image;
    public TextMeshProUGUI text;

    public string PlayerColor = "#00a1d7";
    public string EnemyColor = "#d70a00";

    public void spawnPopups(bool isPlayer)
    {
        if (isPlayer)
        {
            // Ganti warna dan teks untuk player
            image.color = HexToColor(PlayerColor);
            text.text = "Your Turn";
        }
        else
        {
            // Ganti warna dan teks untuk enemy
            image.color = HexToColor(EnemyColor);
            text.text = "Enemy Turn";
        }

        StartCoroutine(DestroyPopups());
    }

    IEnumerator DestroyPopups()
    {
        yield return new WaitForSeconds(liveTime);
        Destroy(gameObject);
    }

    // Fungsi untuk mengonversi format hexadecimal ke Color
    Color HexToColor(string hex)
    {
        Color color = Color.black;
        ColorUtility.TryParseHtmlString(hex, out color);
        return color;
    }

    public void WinLosePopups(bool isWin){
    {
        if (isWin)
        {
            // Ganti warna dan teks untuk player
            image.color = HexToColor(PlayerColor);
            text.text = "You Win";
        }
        else
        {
            // Ganti warna dan teks untuk enemy
            image.color = HexToColor(EnemyColor);
            text.text = "You Lose";
        }

        StartCoroutine(DestroyPopups());
    }

    }
}
