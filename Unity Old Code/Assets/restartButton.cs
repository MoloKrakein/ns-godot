using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class RestartGame : MonoBehaviour
{
    // Attach button to this variable in the Inspector
    public Button restartButton;

    // Start is called before the first frame update
    void Start()
    {
        // Add a listener to the button click event
        restartButton.onClick.AddListener(Restart);
    }

    // Function to restart the scene
    private void Restart()
    {
        // Get the current scene index
        int currentSceneIndex = SceneManager.GetActiveScene().buildIndex;

        // Reload the current scene
        SceneManager.LoadScene(currentSceneIndex);
    }
}
