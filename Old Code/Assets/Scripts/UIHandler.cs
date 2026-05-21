using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class UIHandler : MonoBehaviour
{
    public TextMeshProUGUI encounterText;
    public GameObject AttackText;
    public GameObject dmgPopup;
    public GameObject ExtraMovePopup;
    public HUD playerHUD;
    public HUD enemyHUD;

    public Button skillButton1;
    public Button skillButton2;
    public Button skillButton3;
    public Button skillButton4;
    public Button skillButton5;
    public Button ItemButton;
    public Button DefendButton;
    public Button AttackButton;

    public void UpdateSkillButtons(string[] skillNames)
    {
        skillButton1.GetComponentInChildren<TextMeshProUGUI>().text = skillNames[0];
        skillButton2.GetComponentInChildren<TextMeshProUGUI>().text = skillNames[1];
        skillButton3.GetComponentInChildren<TextMeshProUGUI>().text = skillNames[2];
        skillButton4.GetComponentInChildren<TextMeshProUGUI>().text = skillNames[3];
        skillButton5.GetComponentInChildren<TextMeshProUGUI>().text = skillNames[4];
    }

    public void HideSkillButtons()
    {
        skillButton1.gameObject.SetActive(false);
        skillButton2.gameObject.SetActive(false);
        skillButton3.gameObject.SetActive(false);
        skillButton4.gameObject.SetActive(false);
        skillButton5.gameObject.SetActive(false);
    }

    public void ShowSkillButtons()
    {
        skillButton1.gameObject.SetActive(true);
        skillButton2.gameObject.SetActive(true);
        skillButton3.gameObject.SetActive(true);
        skillButton4.gameObject.SetActive(true);
        skillButton5.gameObject.SetActive(true);
    }
    
    // Metode lain yang terkait dengan UI bisa ditambahkan di sini
}