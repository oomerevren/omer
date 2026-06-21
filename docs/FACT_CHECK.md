# Fact-Check Akışı

Sistem, üretilen her haber için çok katmanlı bir doğrulama süreci uygular:

1.  **İddia Çıkarımı:** Haberdeki temel iddialar LLM (Mistral Large) tarafından maddeler halinde çıkarılır.
2.  **Çapraz LLM Kontrolü:** 
    *   Agent A: Haberin iç tutarlılığını kontrol eder.
    *   Agent B: Haberi mevcut kurumsal hafızadaki (pgvector) benzer haberlerle karşılaştırır.
3.  **Kaynak Doğrulaması:** Haberin geldiği kaynağın `trust_score` değeri kontrol edilir.
4.  **Güven Skoru Üretimi:**
    ```json
    {
      "claim": "X şirketi Y'yi satın aldı",
      "evidence": ["Kaynak A haberi doğruluyor", "Kurumsal hafızada benzer duyumlar var"],
      "confidence": 0.85
    }
    ```
5.  **Karar:** Güven skoru < 0.70 ise haber doğrudan "Red" edilir veya "Editör Onayı"na düşer.
