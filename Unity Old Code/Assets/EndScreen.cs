using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UnityEngine.SceneManagement;

public class EndScreen : MonoBehaviour
{
    public string targetSceneName;
     [TextArea(10,10)]
    public string storyWin;
    [TextArea(10,10)]
    public string storyLose;
    public TextMeshProUGUI textStory;
    private float delayDuration;
    public GameObject winSong;
    public GameObject loseSong;

    private void Start() {
        bool isWin = StaticValue.isWin;
        Debug.Log("Win Status: " + isWin);
        if(isWin)
        {
            winSong.SetActive(true);
            PlayStory(storyWin,textStory);
        }
        else
        {
            loseSong.SetActive(true);
            PlayStory(storyLose,textStory);
        }
        
    }


    public void PlayStory(string story,TextMeshProUGUI textStory)
    {
        delayDuration = story.Length * 0.05f;
        // calculate how many enters in story
        int enterCount = 0;
        // move camera to y = 1000
        // stop camera animation
        foreach(char letter in story.ToCharArray())
        {
            if(letter == '\n')
            {
                enterCount++;
            }
        }
        delayDuration = delayDuration+enterCount * 1.5f;
        StartCoroutine(PlayText(story,textStory));
        StartCoroutine(delay());
        // StartCoroutine(LoadScene());
    }
    IEnumerator delay()
    {
        yield return new WaitForSeconds(delayDuration);
        // play fadeout animation

        StartCoroutine(LoadScene());
    }

    // split text char into 2 parts and play it, give delay between each story part
    IEnumerator PlayText(string story,TextMeshProUGUI textStory)
    {
        yield return new WaitForSeconds(3f);
        string[] storyParts = story.Split('\n');
        foreach(string storyPart in storyParts)
        {
            textStory.text = "";
            foreach(char letter in storyPart.ToCharArray())
            {
                textStory.text += letter;
                yield return new WaitForSeconds(0.05f);
            }
            yield return new WaitForSeconds(1f);
        }
    }
        IEnumerator LoadScene()
    {
        // fade out the music in Story Canvas
        yield return new WaitForSeconds(3f);
        
        SceneManager.LoadScene(targetSceneName);
    }

}
