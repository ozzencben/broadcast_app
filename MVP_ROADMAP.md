# Stream App: Mevcut Durum Raporu ve MVP Yol Haritası

Bu rapor, projenin mevcut teknik altyapısını analiz eder ve "Minimum Viable Product" (MVP) seviyesinde tam fonksiyonel bir uygulama haline gelmesi için atılması gereken adımları özetler.

## 1. Mevcut Durum Analizi

### 🚀 Backend (FastAPI + LiveKit + Redis)
*   **Kimlik Doğrulama:** JWT tabanlı login/register ve cihaz token senkronizasyonu tamamlanmış durumda.
*   **Yayın Altyapısı:** LiveKit entegrasyonu başarılı. Oda oluşturma, token üretimi ve webhook (yayın bitişi) takibi çalışıyor.
*   **Anlık Güncellemeler:** WebSocketManager üzerinden hem genel (yeni yayın) hem de kişisel (yeni takip/bildirim) mesaj gönderimi aktif.
*   **Arka Plan İşleri:** Redis/arq worker yapısı FCM bildirimleri için hazır.
*   **Yapılandırma:** Docker Compose ile PostgreSQL, Redis ve LiveKit servisleri bir arada çalışabiliyor.

### 📱 Flutter App (Provider + LiveKit SDK)
*   **Yayın Deneyimi:** Kamera/Mikrofon izinleri, yayıncı ve izleyici ekranları mevcut. Düşük donanımlı cihazlar için video optimizasyonu (320x240, 15fps) uygulandı.
*   **Bildirim Sistemi:** Hem FCM (push notification) hem de WebSocket (in-app live update) entegre edildi. Bildirim geçmişi sayfalama (pagination) ile çekiliyor.
*   **Keşfet Ekranı:** Aktif yayınlar listeleniyor ve WebSocket üzerinden anlık olarak güncelleniyor.

---

## 2. MVP İçin Eksikler ve Riskler

### ⚠️ Teknik Riskler
1.  **IP Adresi Bağımlılığı:** Şu an `192.168.1.107` gibi yerel IP'ler kod içerisinde (özellikle Flutter tarafında) dağınık durumda. Bu, ağ değiştiğinde sistemin çökmesine neden olur.
2.  **Bağlantı Kopmaları:** İnternet dalgalanmalarında LiveKit veya WebSocket bağlantısı koptuğunda "Reconnecting" durumları UI tarafında yeterince yönetilmiyor.
3.  **Hata Yönetimi:** API'den dönen hatalar kullanıcıya genellikle teknik mesajlar olarak (veya hiç) yansıtılmıyor.

### ❌ Eksik Fonksiyonlar
1.  **Canlı Sohbet (Stream Chat):** Bir yayın uygulamasının kalbi olan anlık mesajlaşma henüz yok.
2.  **İzleyici Sayısı:** Yayın sırasında kaç kişinin izlediği bilgisi LiveKit webhook'ları üzerinden backend'e geliyor ancak Flutter UI'da anlık güncellenmiyor.
3.  **Profil Düzenleme:** Kullanıcıların fotoğraf veya biyografi değiştirme kısımları kodda var ancak tam test edilmedi/bağlanmadı.

---

## 3. MVP Yol Haritası (Yapılacaklar Listesi)

MVP seviyesinde "çalışır durumda" bir uygulama için aşağıdaki adımları sırasıyla tamamlamalısınız:

### Aşama 1: Stabilizasyon ve Konfigürasyon (Kritik)
- [ ] **IP Yönetimi:** Flutter tarafında `BaseUrl` ve `LiveKitUrl` bilgilerini tek bir `Constants` dosyasında topla.
- [ ] **SSL/WSS Hazırlığı:** Yerel testlerden çıkarken `http` -> `https` ve `ws` -> `wss` dönüşümü için gerekli sertifika ayarlarını planla.
- [ ] **LiveKit Webhook Geliştirme:** Yayıncının interneti aniden koptuğunda odanın backend tarafında "zombi" kalmaması için `participant_left` olayını daha agresif işle.

### Aşama 2: Sosyal Etkileşim (Önemli)
- [ ] **Temel Sohbet:** Yayın içinde WebSocket üzerinden çalışan çok basit bir text chat ekle.
- [ ] **Anlık İzleyici Sayısı:** LiveKit'ten gelen katılımcı sayısını WebSocket üzerinden yayındaki herkese "VIEWER_COUNT_UPDATE" mesajı olarak gönder ve UI'da göster.
- [ ] **Bildirim UI Cilası:** Kullanıcı uygulama içindeyken (Notification ekranında değilken) yeni bir bildirim gelirse, ekranın üstünde süzülen küçük bir banner/snack-bar göster.

### Aşama 3: Kullanıcı Deneyimi ve Hata Yönetimi
- [ ] **Yükleme ve Boş Durumlar:** Stream listesi boş olduğunda veya internet yokken gösterilen ekranları "Neo-Brutalism" temasına uygun illüstrasyonlarla süsle.
- [ ] **Video Önizleme (Mock):** Yayın listesindeki kartlara, yayıncıdan gelen anlık kareleri (snapshot) koymaya çalış veya şık placeholder'lar kullan.
- [ ] **Global Error Handler:** Flutter tarafında `Dio` interceptor kullanarak 401 (Unauthorized) veya 500 hatalarında kullanıcıyı otomatik logout yap veya uyarı ver.

---

## 4. Mevcut Sistemde Kontrol Etmen Gerekenler

1.  **Docker Logs:** `docker compose logs -f api` komutuyla Webhook'ların LiveKit'ten gelip gelmediğini kontrol et.
2.  **Token Geçerliliği:** LiveKit token'larının süresini (expiry) kontrol et; yayıncı uzun süre yayında kalırsa token süresi dolmamalı.
3.  **Permission Handler:** Android 13+ için `POST_NOTIFICATIONS` izninin Flutter tarafında istendiğinden emin ol.

> [!TIP]
> **Öncelik Tavsiyesi:** Önce "Aşama 1"deki IP yönetimini düzeltmelisin. Ardından "Aşama 2"deki Chat özelliğine odaklanmak uygulamanın "yaşadığını" hissettirecektir.

