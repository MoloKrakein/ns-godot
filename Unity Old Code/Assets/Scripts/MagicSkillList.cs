using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class MagicSkillList : MonoBehaviour
{
    // list of a button
    public Button[] magicSkillList;
    public GameObject btnPrefab;
    public Button backButton;

    public GameObject magicSkillPanel;

    public int  ButtonAction(int index)
    {
        return index;
    }

    public void HideButton(){
        magicSkillPanel.SetActive(false);
    }

    public void ShowButton(){
        magicSkillPanel.SetActive(true);
    }

    public void SetButton(int index, string name, int mana, bool useHP, Sprite icon){
        magicSkillList[index].transform.Find("Image").GetComponent<Image>().sprite = icon;
        magicSkillList[index].transform.Find("skillName").GetComponent<TextMeshProUGUI>().text = name;
        magicSkillList[index].transform.Find("mp_bar").GetComponent<TextMeshProUGUI>().text = mana.ToString();
        if(useHP){
            magicSkillList[index].transform.Find("SkillAttribute").GetComponent<TextMeshProUGUI>().text = "HP";
            magicSkillList[index].transform.Find("SkillBg").GetComponent<Image>().color = new Color32(255, 0, 0, 255);
        }
        else{
            magicSkillList[index].transform.Find("SkillAttribute").GetComponent<TextMeshProUGUI>().text = "MP";
            magicSkillList[index].transform.Find("SkillBg").GetComponent<Image>().color = new Color32(255, 255, 255, 255);
        }


        
    }




}
