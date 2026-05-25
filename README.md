# KBB Kliniği Yönetim Sistemi - Veritabanı Tasarımı

Bandırma Onyedi Eylül Üniversitesi Bilgisayar Mühendisliği bölümü Veritabanı Yönetim Sistemleri dersi kapsamında, bir Kulak Burun Boğaz (KBB) kliniğinin tüm operasyonel süreçlerini yönetebilecek **17 tablolu ilişkisel veritabanı sistemi** olarak grup projesi şeklinde geliştirilmiştir.

## 📋 Proje Hakkında

Sistem; hasta kayıtları, doktor ve personel yönetimi, randevu ve muayene süreçleri, tanı ve tedavi planları, reçete-ilaç takibi, tıbbi cihaz envanteri, tahlil sonuçları, faturalandırma ve kullanıcı yetkilendirme gibi bir kliniğin ihtiyaç duyacağı tüm modülleri kapsayacak şekilde tasarlanmıştır.

## 🗄️ Veritabanı Mimarisi

**Toplam 17 tablo** ve aralarındaki ilişkilerle kurgulanmıştır:

| # | Tablo | Açıklama |
|---|-------|----------|
| 1 | Hasta | Hasta demografik ve sağlık bilgileri |
| 2 | Doktor | Doktor bilgileri ve uzmanlık alanları |
| 3 | Personel | Klinik personeli yönetimi |
| 4 | Randevu | Randevu planlama ve durum takibi |
| 5 | Muayene | Muayene kayıtları, bulgular ve epikriz |
| 6 | Tanı | ICD-10 kodlu tanı kayıtları |
| 7 | TedaviPlani | Tedavi planlamaları |
| 8 | Ilac | İlaç bilgileri |
| 9 | Recete | Reçete oluşturma |
| 10 | Recete_Ilac | Reçete-ilaç ilişki tablosu (N:M) |
| 11 | Envanter | Stok ve sarf malzeme takibi |
| 12 | Cihaz | Tıbbi cihaz envanteri |
| 13 | Tahlil | Laboratuvar tahlil sonuçları |
| 14 | Fatura | Hizmet faturalandırma |
| 15 | Kullanici | Sistem kullanıcı ve yetki yönetimi |
| 16 | CalismaTakvimi | Personel/doktor mesai takvimi |
| 17 | Oda | Klinik odaları ve kullanım amaçları |

## 🛠️ Kullanılan Teknolojiler

- **Veritabanı:** Oracle SQL
- **Modelleme:** ER Diyagramı (Entity-Relationship)
- **Dokümantasyon:** Microsoft Word, PDF Rapor

## ✨ Tasarım Özellikleri

- **Referansiyel Bütünlük:** Tüm tablolar arası `FOREIGN KEY` kısıtları ile ilişkilendirildi
- **Veri Doğrulama:** Cinsiyet, kan grubu, ödeme durumu, randevu durumu gibi alanlarda `CHECK` kısıtları ile kontrollü veri girişi
- **Tekillik Garantisi:** TCKN, diploma numarası gibi kritik alanlarda `UNIQUE` kısıtı
- **NULL Kontrolü:** Zorunlu alanlarda `NOT NULL` kısıtı ile veri tutarlılığı
- **Yetki Yönetimi:** Doktor, Sekreter, Admin rolleri ile rol bazlı erişim mimarisi
- **Örnek Veri:** Her tablo için anlamlı test verisi (mock data) eklendi

## 📁 Repo İçeriği

```
├── klinik.sql                  # Ana SQL script (CREATE TABLE + INSERT)
├── KBB_veritabanı/
│   ├── ER Diyagramı full.png   # Varlık-İlişki Diyagramı
│   ├── Klinik_Rapor_1.0.pdf    # Proje raporu
│   └── Klinik_Script_3.0.docx  # Detaylı script dokümantasyonu
└── README.md
```

## 🚀 Kurulum

```sql
-- Oracle SQL Developer veya benzeri bir araç ile:
@klinik.sql
```

## 👥 Grup Çalışması

Bu proje grup ödevi olarak geliştirilmiştir. Bireysel katkılarım:
- ER diyagramı tasarımına katkı
- SQL tablo şemalarının ve kısıtların yazımına katkı
- Dokümantasyon ve raporlama sürecine katkı

## 📚 Ders

**BLM XXXX - Veritabanı Yönetim Sistemleri**
Bandırma Onyedi Eylül Üniversitesi - Bilgisayar Mühendisliği

---

*Bu proje akademik amaçlıdır.*
