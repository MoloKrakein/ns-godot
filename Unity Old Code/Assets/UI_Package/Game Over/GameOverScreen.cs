using UnityEngine;
using UnityEngine.UI;

public class GameOverScreen : MonoBehaviour
{
    public GameObject gameOverPanel; // Referensi ke panel Game Over

    public void ShowGameOver()
    {
        // Menampilkan panel Game Over
        gameOverPanel.SetActive(true);
    }

    public void HideGameOver()
    {
        // Menyembunyikan panel Game Over
        gameOverPanel.SetActive(false);
    }

    public void RestartGame()
    {
        // Tambahkan logika untuk mengulangi permainan
        // Misalnya, menggunakan SceneManager.LoadScene() untuk memuat ulang level permainan
    }

    public void QuitGame()
    {
        // Tambahkan logika untuk keluar dari permainan
        // Misalnya, menggunakan Application.Quit()
    }
}