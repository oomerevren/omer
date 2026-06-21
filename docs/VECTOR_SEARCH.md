# Vektör Hafıza ve Benzerlik Araması

Sistem, `pgvector` eklentisini kullanarak içerikleri vektör uzayında saklar.

### Teknik Detaylar
- **Model:** `text-embedding-3-small` (1536 boyut).
- **Tablo:** `raw_news` ve `corporate_memory`.

### Similarity Search Örneği
```sql
SELECT title, summary, 1 - (embedding <=> '[vector_data]') as similarity
FROM raw_news
WHERE 1 - (embedding <=> '[vector_data]') > 0.8
ORDER BY similarity DESC
LIMIT 5;
```

### Kullanım Amaçları
1.  **Mükerrer Haber Kontrolü:** Aynı haberin farklı kelimelerle yazılmasını tespit etme.
2.  **İç Linkleme:** Yeni yazılan habere ilgili eski haberleri otomatik bağlama.
3.  **Hata Tekrarı Önleme:** Geçmişte reddedilen içeriklere benzer yeni içerikleri işaretleme.
