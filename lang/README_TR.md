**`README_TR.md` (Turkish)**

```markdown
# Davi YouTube İndirici

Davi, YouTube ve diğer birçok video barındırma sitesinden video ve ses indirmek için `yt-dlp`'yi kullanan basit ama güçlü bir kabuk betiğidir. Yaygın seçeneklerle kullanımı kolay olacak şekilde tasarlanmıştır ve Android'deki Termux ile çeşitli Linux dağıtımları için destek içerir.

## Özellikler

* **Video/Ses İndirme:** Videoları, yalnızca sesleri veya tüm oynatma listelerini kolayca indirin.
* **Format ve Kalite Kontrolü:** İstenen formatları (mp4, mkv, mp3 vb.) ve kaliteleri (en iyi, 1080p vb.) belirtin.
* **İndirmeleri Devam Ettirme:** Yarım kalan indirmeleri otomatik olarak devam ettirir.
* **Altyazı Desteği:** Altyazıları videoya gömün veya otomatik oluşturulanları indirin.
* **Yapılandırılabilir:** Basit bir yapılandırma dosyası aracılığıyla varsayılan ayarları özelleştirin.
* **Çapraz Platform:** Termux (Android) ve çeşitli Linux dağıtımlarında (Debian, Ubuntu, Fedora, Arch, Alpine) çalışır.
* **Kolay Takma Ad:** Hızlı erişim için kısa `dv` komutunu kullanın.

## Kurulum

1.  **Projeyi indirin:**
    Sıkıştırılmış dosyayı GitHub deposundan indirin veya klonlayın:
    `git clone https://github.com/your_username/davi-youtube-downloader.git`
    `cd davi-youtube-downloader`

2.  **Kurulum betiğini çalıştırın:**
    ```bash
    chmod +x install.sh
    ./install.sh
    ```

    Yükleyici şunları yapacaktır:
    * `davi.sh` dosyasını `PATH`'inizde uygun bir konuma kopyalayacaktır.
    * Kolay erişim için `~/.bashrc` ve `~/.zshrc` dosyalarınıza `dv` takma adını oluşturacaktır.
    * Mevcut değilse varsayılan bir yapılandırma dosyası (`~/.dlconfig`) oluşturacaktır.
    * Belirli sisteminiz (Termux/Linux) için `yt-dlp` ve `ffmpeg`'i nasıl kuracağınıza dair talimatlar sağlayacaktır.

3.  **Bağımlılıkları Kurun:**
    `yt-dlp` ve `ffmpeg`'i yüklemek için `install.sh` betiği tarafından sağlanan talimatları izleyin.
    * **Termux için:** `pkg install python python-yt-dlp ffmpeg` (ve `termux-setup-storage`).
    * **Linux için:** Dağıtımınızın paket yöneticisini (örn. `sudo apt install yt-dlp ffmpeg`) veya `pip`'i kullanın.

4.  **Kabuğunuzu yeniden yükleyin:**
    Kurulumdan sonra, `dv` takma adını etkinleştirmek için `source ~/.bashrc` veya `source ~/.zshrc` komutunu çalıştırın ya da terminalinizi yeniden başlatın.

## Kullanım

`dv` komutunu seçenekler ve video/oynatma listesi URL'si ile birlikte kullanın.

```bash
dv [Seçenekler] <video_veya_oynatma_listesi_urlsi>
Seçenekler:
audio: Yalnızca sesi indir.
video: Videoyu indir (varsayılan).
playlist: Tüm oynatma listesini indir.
--format FORMAT: Dosya formatını belirtin (örn. video için mp4, mkv; ses için mp3, wav).
--quality QUALITY: İndirme kalitesi (örn. best, worst, 720p, 480p).
--resume: Yarım kalan indirmeleri devam ettir.
--config: Varsayılan yapılandırma dosyasını (~/.dlconfig) oluştur veya yeniden oluştur.
--help: Yardım mesajını göster.
Örnekler:
Bash

* dv [https://www.youtube.com/watch?v=dQw4w9WgXcQ](https://www.youtube.com/watch?v=dQw4w9WgXcQ)
* dv [https://www.youtube.com/watch?v=dQw4w9WgXcQ](https://www.youtube.com/watch?v=dQw4w9WgXcQ) audio
* dv [https://www.youtube.com/playlist?list=PLqc_aT2_aC_jKkS_jXlZ_xZ_xZ_xZ_xZ](https://www.youtube.com/playlist?list=PLqc_aT2_aC_jKkS_jXlZ_xZ_xZ_xZ_xZ) playlist
* dv [https://www.youtube.com/watch?v=dQw4w9WgXcQ](https://www.youtube.com/watch?v=dQw4w9WgXcQ) --format mkv --quality 720p
* dv --resume
Yapılandırma
Varsayılan indirme ayarlarını ~/.dlconfig dosyasını düzenleyerek özelleştirebilirsiniz.

Bash

# ~/.dlconfig dosyasının örnek içeriği
OUTPUT_DIR="${HOME}/Downloads/media"
VIDEO_FORMAT="mp4"
AUDIO_FORMAT="mp3"
VIDEO_QUALITY="best"
AUDIO_QUALITY="0"
EMBED_SUBS="yes"
AUTO_SUBS="no"
Kaldırma
Davi'yi ve ilişkili dosyalarını kaldırmak için:

Bash

chmod +x uninstall.sh
./uninstall.sh
Bu, betiği, takma adı kaldıracak ve yapılandırma dosyasını kaldırmayı teklif edecektir.

## Sorun Giderme
* yt-dlp veya ffmpeg bulunamadı: Kurulum talimatlarına göre bağımlılıkları yüklediğinizden emin olun.
* pip ile "externally-managed-environment" hatası: Daha yeni Python sürümlerinde pip, genel kurulumları kısıtlayabilir. Dikkatli bir şekilde sudo pip install yt-dlp --break-system-packages komutunu deneyin veya sisteminizin paket yöneticisini kullanın.
* Termux Depolama: Termux'ta depolama sorunları yaşıyorsanız, termux-setup-storage komutunu çalıştırın.
* Katkıda Bulunma
* İyileştirmeler veya hata düzeltmeleri için önerileriniz varsa, GitHub deposunda sorunlar veya çekme istekleri açmaktan çekinmeyin.

