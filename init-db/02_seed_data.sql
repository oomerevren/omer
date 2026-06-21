-- ═══════════════════════════════════════════════════════════
-- OTONOM MEDYA HOLDİNGİ — BAŞLANGIÇ VERİLERİ (v2.0)
-- ═══════════════════════════════════════════════════════════

-- Haber Kaynakları (Trust Score ile)
INSERT INTO sources (name, url, type, category, accuracy_score, freshness_score, consistency_score) VALUES
('TechCrunch', 'https://techcrunch.com/feed/', 'rss', 'teknoloji', 0.9, 0.9, 0.9),
('The Verge', 'https://www.theverge.com/rss/index.xml', 'rss', 'teknoloji', 0.85, 0.95, 0.9),
('Ars Technica', 'https://feeds.arstechnica.com/arstechnica/technology-lab', 'rss', 'teknoloji', 0.95, 0.8, 0.95),
('Bloomberg', 'https://feeds.bloomberg.com/markets/news.rss', 'rss', 'ekonomi', 0.98, 0.95, 0.98),
('Reuters Business', 'https://feeds.reuters.com/reuters/businessNews', 'rss', 'ekonomi', 0.98, 0.98, 0.98),
('Financial Times', 'https://www.ft.com/technology?format=rss', 'rss', 'ekonomi', 0.97, 0.9, 0.97),
('BBC Culture', 'https://feeds.bbci.co.uk/news/entertainment_and_arts/rss.xml', 'rss', 'kultur', 0.9, 0.8, 0.9),
('Nature News', 'https://www.nature.com/nature.rss', 'rss', 'bilim', 1.0, 0.7, 1.0),
('NASA Breaking News', 'https://www.nasa.gov/rss/dyn/breaking_news.rss', 'rss', 'bilim', 1.0, 0.8, 1.0),
('Anadolu Ajansı', 'https://www.aa.com.tr/tr/rss/default?cat=guncel', 'rss', 'kultur', 0.9, 0.95, 0.9);

-- Çok Dilli İçerik İşleme (P2-15)
INSERT INTO prompt_templates (template_name, template_type, category, template_text, variables) VALUES
('cok_dilli_cevirmen', 'translation', 'genel',
 'Sen uzman bir haber çevirmenisin. Aşağıdaki haberi doğrudan çevirmek yerine, Türk gazetecilik standartlarına ve kültürel bağlama uygun şekilde Türkçe olarak yeniden yaz.

Haber (Orijinal): {{content}}

Kurallar:
1. Ham çeviri yapma.
2. Türk okuyucusu için anlamlı olmayan detayları ele.
3. Varsa yerel saatleri ve birimleri (mil, fahrenheit vb.) dönüştür.
4. Başlığı ve girişi Türk medya diline uygun şekilde (vurgulu, öz) oluştur.',
 '{"content": "string"}');
