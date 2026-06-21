# Risk Skoru ve Editör Onay Süreci

Her içerik, kategorisine ve içeriğine göre bir risk puanı (0-100) alır.

### Risk Kategorileri
- **Düşük Risk (0-30):** Teknoloji, Magazin, Kültür-Sanat.
- **Orta Risk (30-70):** Ekonomi, Yerel Haberler.
- **Yüksek Risk (70-100):** Sağlık, Siyaset, Finansal Tavsiye.

### İş Akışı
1.  **Otomatik Puanlama:** LLM, içeriği analiz eder ve risk skorunu belirler.
2.  **CMS Entegrasyonu (Directus):**
    *   `risk < 30`: Statü `published` olarak ayarlanır (Otomatik Yayın).
    *   `30 <= risk < 70`: Statü `review` olarak ayarlanır. Editör panelinde "İnceleme Bekliyor" olarak görünür.
    *   `risk >= 70`: Statü `draft` olarak ayarlanır. Zorunlu editör revizyonu ve ikinci bir onay gerektirir.
3.  **Bildirim:** Orta ve yüksek riskli içerikler için n8n üzerinden Telegram/Slack bildirimi gönderilir.
