using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioManager : MonoBehaviour
{
//    list audio clip
    public AudioClip[] audioClips;
    public AudioSource audioSource;
    public static AudioManager instance;
    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
    }

    public void PlaySound(int index)
    {
        // change volume
        audioSource.volume = 0.5f;
        audioSource.PlayOneShot(audioClips[index]);

    }
}
