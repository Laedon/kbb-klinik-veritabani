-- 1. Hasta
CREATE TABLE Hasta (
    HastaID           NUMBER(10),
    Ad                VARCHAR2(50) NOT NULL,
    Soyad             VARCHAR2(50) NOT NULL,
    TCKN              VARCHAR2(11) UNIQUE,
    DogumTarihi       DATE,
    Cinsiyet          VARCHAR2(10) CHECK (Cinsiyet IN ('Erkek', 'Kadın', 'Diğer')),
    Telefon           VARCHAR2(15),
    Eposta            VARCHAR2(50),
    Adres             VARCHAR2(255),
    BoyCM             NUMBER(3),
    KiloKG            NUMBER(3),
    SigortaTuru       VARCHAR2(20) CHECK (SigortaTuru IN ('SGK', 'Özel', 'Yok')),
    Alerjiler         VARCHAR2(255),
    KronikHastaliklar VARCHAR2(255),
    KanGrubu          VARCHAR2(5) CHECK (KanGrubu IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    CONSTRAINT pk_hasta PRIMARY KEY (HastaID)
);

-- 2. Doktor
CREATE TABLE Doktor (
    DoktorID      NUMBER(10),
    Ad            VARCHAR2(50) NOT NULL,
    Soyad         VARCHAR2(50) NOT NULL,
    Brans         VARCHAR2(50),
    DiplomaNo     VARCHAR2(20),
    Unvan         VARCHAR2(20) CHECK (Unvan IN ('Uzman', 'Doç.', 'Prof.')),
    OdaID   VARCHAR2(10),
    Telefon       VARCHAR2(15),
    Eposta        VARCHAR2(50),
    Maas          NUMBER(10,2),
    CONSTRAINT pk_doktor PRIMARY KEY (DoktorID)
);

-- 3. Personel
CREATE TABLE Personel (
    PersonelID   NUMBER(10),
    Ad           VARCHAR2(50) NOT NULL,
    Soyad        VARCHAR2(50) NOT NULL,
    Gorev        VARCHAR2(50),
    Departman    VARCHAR2(50),
    Telefon      VARCHAR2(15),
    Eposta       VARCHAR2(50),
    Maas         NUMBER(10,2),
    CONSTRAINT pk_personel PRIMARY KEY (PersonelID)
);

-- 4. Randevular
CREATE TABLE Randevu (
    RandevuID   NUMBER(10),
    HastaID     NUMBER(10) NOT NULL,
    DoktorID    NUMBER(10) NOT NULL,
    TarihSaat   DATE NOT NULL,
    Durum       VARCHAR2(20) CHECK (Durum IN ('Bekliyor', 'Tamamlandı', 'İptal')),
    CONSTRAINT pk_randevu PRIMARY KEY (RandevuID),
    CONSTRAINT fk_randevu_hasta FOREIGN KEY (HastaID) REFERENCES Hasta(HastaID),
    CONSTRAINT fk_randevu_doktor FOREIGN KEY (DoktorID) REFERENCES Doktor(DoktorID)
);

-- 5. Muayene
CREATE TABLE Muayene (
    MuayeneID     NUMBER(10),
    RandevuID     NUMBER(10),
    DoktorID      NUMBER(10) NOT NULL,
    Bulgular      VARCHAR2(500),
    Notlar        VARCHAR2(500),
    Epikriz       VARCHAR2(500),
    MuayeneTarihi DATE,
    CONSTRAINT pk_muayene PRIMARY KEY (MuayeneID),
    CONSTRAINT fk_muayene_randevu FOREIGN KEY (RandevuID) REFERENCES Randevu(RandevuID),
    CONSTRAINT fk_muayene_doktor FOREIGN KEY (DoktorID) REFERENCES Doktor(DoktorID)
);

-- 6. Tanılar
CREATE TABLE Tani (
    TaniID      NUMBER(10),
    MuayeneID   NUMBER(10),
    ICD10Kodu   VARCHAR2(10),
    Aciklama    VARCHAR2(255),
    TaniTarihi  DATE,
    CONSTRAINT pk_tani PRIMARY KEY (TaniID),
    CONSTRAINT fk_tani_muayene FOREIGN KEY (MuayeneID) REFERENCES Muayene(MuayeneID)
);

-- 7. Tedavi Planı
CREATE TABLE TedaviPlani (
    TedaviID        NUMBER(10),
    TaniID          NUMBER(10),
    Aciklama        VARCHAR2(500),
    BaslangicTarihi DATE,
    BitisTarihi     DATE,
    RaporGunSayisi  NUMBER(3),
    DoktorID        NUMBER(10),
    CONSTRAINT pk_tedavi PRIMARY KEY (TedaviID),
    CONSTRAINT fk_tedavi_tani FOREIGN KEY (TaniID) REFERENCES Tani(TaniID),
    CONSTRAINT fk_tedavi_doktor FOREIGN KEY (DoktorID) REFERENCES Doktor(DoktorID)
);

-- 8. İlaçlar
CREATE TABLE Ilac (
    IlacID        NUMBER(10),
    IlacAdi       VARCHAR2(100) NOT NULL,
    EtkenMadde    VARCHAR2(100),
    Dozaj         VARCHAR2(50),
    Form          VARCHAR2(50) CHECK (Form IN ('Tablet', 'Ampul', 'Krem')),
    YanEtkiler    VARCHAR2(255),
    CONSTRAINT pk_ilac PRIMARY KEY (IlacID)
);

-- 9. Reçeteler
CREATE TABLE Recete (
    ReceteID    NUMBER(10),
    HastaID     NUMBER(10),
    DoktorID    NUMBER(10),
    MuayeneID   NUMBER(10),
    Tarih       DATE,
    Son_tarih Date,
    Notlar      VARCHAR2(255),
    CONSTRAINT pk_recete PRIMARY KEY (ReceteID),
    CONSTRAINT fk_recete_hasta FOREIGN KEY (HastaID) REFERENCES Hasta(HastaID),
    CONSTRAINT fk_recete_doktor FOREIGN KEY (DoktorID) REFERENCES Doktor(DoktorID),
    CONSTRAINT fk_recete_muayene FOREIGN KEY (MuayeneID) REFERENCES Muayene(MuayeneID)
);
CREATE OR REPLACE TRIGGER recete_tarih_atama
BEFORE INSERT ON Recete
FOR EACH ROW
BEGIN
    -- Yeni eklenen satırın Tarih sütununa sistem tarihi atanır
    :NEW.Tarih := SYSDATE;
    -- Son_tarih sütununa bu tarihe 4 gün eklenerek atanır
    :NEW.Son_tarih := SYSDATE + 4;
END;


-- 10. Reçete-İlaç
CREATE TABLE Recete_Ilac (
    ReceteID     NUMBER(10),
    IlacID       NUMBER(10),
    Dozaj        VARCHAR2(50),
    Siklik       VARCHAR2(50),
    GunSayisi    NUMBER(3),
    Miktar       NUMBER(5),
    CONSTRAINT pk_recete_ilac PRIMARY KEY (ReceteID, IlacID),
    CONSTRAINT fk_recete_ilac_recete FOREIGN KEY (ReceteID) REFERENCES Recete(ReceteID),
    CONSTRAINT fk_recete_ilac_ilac FOREIGN KEY (IlacID) REFERENCES Ilac(IlacID)
);

-- 11. Envanter
CREATE TABLE Envanter (
    EnvanterID        NUMBER(10),
    IlacID            NUMBER(10),
    UrunAdi           VARCHAR2(100),
    Miktar            NUMBER(10),
    KullanimAlani     VARCHAR2(50),
    SonKullanmaTarihi DATE,
    CONSTRAINT pk_envanter PRIMARY KEY (EnvanterID),
    CONSTRAINT fk_envanter_ilac FOREIGN KEY (IlacID) REFERENCES Ilac(IlacID)
);

-- 12. Cihazlar
CREATE TABLE Cihaz (
    CihazID     NUMBER(10),
    CihazAd     VARCHAR2(50),
    OdaID       VARCHAR2(10),
    Marka       VARCHAR2(50),
    Model       VARCHAR2(50),
    Durum       VARCHAR2(30) CHECK (Durum IN ('Aktif', 'Arızalı', 'Kalibrasyonda')),
    CONSTRAINT pk_cihaz PRIMARY KEY (CihazID)
);

-- 13. Tahliller
CREATE TABLE Tahlil (
    TestID     NUMBER(10),
    HastaID    NUMBER(10),
    DoktorID   NUMBER(10),
    MuayeneID  NUMBER(10),
    TestTuru   VARCHAR2(50),
    Sonuc      VARCHAR2(255),
    Durum      VARCHAR2(20) CHECK (Durum IN ('Bekliyor', 'Sonuçlandı')),
    TestTarihi DATE,
    CONSTRAINT pk_tahlil PRIMARY KEY (TestID),
    CONSTRAINT fk_tahlil_hasta FOREIGN KEY (HastaID) REFERENCES Hasta(HastaID),
    CONSTRAINT fk_tahlil_doktor FOREIGN KEY (DoktorID) REFERENCES Doktor(DoktorID),
    CONSTRAINT fk_tahlil_muayene FOREIGN KEY (MuayeneID) REFERENCES Muayene(MuayeneID)
);

-- 14. Fatura
CREATE TABLE Fatura (
    FaturaID         NUMBER(10),
    HastaID          NUMBER(10),
    RandevuID        NUMBER(10),
    HizmetAciklamasi VARCHAR2(255),
    Tutar            NUMBER(10,2),
    SigortaKapsami   VARCHAR2(5) CHECK (SigortaKapsami IN ('Evet', 'Hayır')),
    OdemeDurumu      VARCHAR2(20) CHECK (OdemeDurumu IN ('Ödendi', 'Bekliyor', 'İptal')),
    CONSTRAINT pk_fatura PRIMARY KEY (FaturaID),
    CONSTRAINT fk_fatura_hasta FOREIGN KEY (HastaID) REFERENCES Hasta(HastaID),
    CONSTRAINT fk_fatura_randevu FOREIGN KEY (RandevuID) REFERENCES Randevu(RandevuID)
);

-- 15. Kullanıcılar
CREATE TABLE Kullanici (
    KullaniciID     NUMBER(10),
    DoktorID        NUMBER(10),
    PersonelID      NUMBER(10),
    KullaniciAdi    VARCHAR2(50) UNIQUE NOT NULL,
    Sifre           VARCHAR2(255) NOT NULL,
    YetkiSeviyesi   VARCHAR2(20) CHECK (YetkiSeviyesi IN ('Admin', 'Doktor', 'Sekreter')),
    CONSTRAINT pk_kullanici PRIMARY KEY (KullaniciID),
    CONSTRAINT fk_kullanici_personel FOREIGN KEY (PersonelID) REFERENCES Personel(PersonelID),
    CONSTRAINT fk_kullanici_doktor FOREIGN KEY (DoktorID) REFERENCES Doktor(DoktorID)
);

-- 16. Çalışma Takvimi
CREATE TABLE CalismaTakvimi (
    TakvimID      NUMBER(10),
    DoktorID      NUMBER(10),
    PersonelID    NUMBER(10),
    Gun           VARCHAR2(20),
    BaslangicSaat VARCHAR2(5),
    BitisSaat     VARCHAR2(5),
    CONSTRAINT pk_takvim PRIMARY KEY (TakvimID),
    CONSTRAINT fk_takvim_doktor FOREIGN KEY (DoktorID) REFERENCES Doktor(DoktorID),
    CONSTRAINT fk_takvim_personel FOREIGN KEY (PersonelID) REFERENCES Personel(PersonelID)
);
--17. Oda
CREATE TABLE Oda (
    OdaID VARCHAR2(10) PRIMARY KEY,
    KullanimAmaci VARCHAR2(50)
);


-- Veri Girişi
-- 1. Hastalar

INSERT INTO Hasta (HastaID, Ad, Soyad, TCKN, DogumTarihi, Cinsiyet, Telefon, Eposta, Adres, BoyCM, KiloKG, SigortaTuru, Alerjiler, KronikHastaliklar, KanGrubu)
VALUES (1, 'Ahmet', 'Yılmaz', '12345678901', TO_DATE('1985-04-12', 'YYYY-MM-DD'), 'Erkek', '05321234567', 'ahmet.yilmaz@example.com', 'İstanbul, Kadıköy', 175, 78, 'SGK', 'Penisilin', 'Hipertansiyon', 'A+');

INSERT INTO Hasta (HastaID, Ad, Soyad, TCKN, DogumTarihi, Cinsiyet, Telefon, Eposta, Adres, BoyCM, KiloKG, SigortaTuru, Alerjiler, KronikHastaliklar, KanGrubu)
VALUES (2, 'Zeynep', 'Kara', '23456789012', TO_DATE('1990-09-23', 'YYYY-MM-DD'), 'Kadın', '05339876543', 'zeynep.kara@example.com', 'Ankara, Çankaya', 165, 60, 'Özel', NULL, 'Diyabet', 'O-');

INSERT INTO Hasta (HastaID, Ad, Soyad, TCKN, DogumTarihi, Cinsiyet, Telefon, Eposta, Adres, BoyCM, KiloKG, SigortaTuru, Alerjiler, KronikHastaliklar, KanGrubu)
VALUES (3, 'Mehmet', 'Demir', '34567890123', TO_DATE('1978-01-05', 'YYYY-MM-DD'), 'Erkek', '05347654321', 'mehmet.demir@example.com', 'İzmir, Karşıyaka', 180, 85, 'SGK', 'Yok', 'Astım', 'B+');

INSERT INTO Hasta (HastaID, Ad, Soyad, TCKN, DogumTarihi, Cinsiyet, Telefon, Eposta, Adres, BoyCM, KiloKG, SigortaTuru, Alerjiler, KronikHastaliklar, KanGrubu)
VALUES (4, 'Elif', 'Şahin', '45678901234', TO_DATE('2000-07-14', 'YYYY-MM-DD'), 'Kadın', '05445556677', 'elif.sahin@example.com', 'Bursa, Nilüfer', 170, 68, 'Yok', 'Toz', NULL, 'AB+');

INSERT INTO Hasta (HastaID, Ad, Soyad, TCKN, DogumTarihi, Cinsiyet, Telefon, Eposta, Adres, BoyCM, KiloKG, SigortaTuru, Alerjiler, KronikHastaliklar, KanGrubu)
VALUES (5, 'Deniz', 'Aydın', '56789012345', TO_DATE('1995-11-30', 'YYYY-MM-DD'), 'Diğer', '05071234567', 'deniz.aydin@example.com', 'Antalya, Muratpaşa', 172, 70, 'Özel', NULL, NULL, 'O+');

INSERT INTO Hasta (HastaID, Ad, Soyad, TCKN, DogumTarihi, Cinsiyet, Telefon, Eposta, Adres, BoyCM, KiloKG, SigortaTuru, Alerjiler, KronikHastaliklar, KanGrubu)
VALUES (6, 'Burcu', 'Öztürk', '67890123456', TO_DATE('1988-02-17', 'YYYY-MM-DD'), 'Kadın', '05333444555', 'burcu.ozturk@example.com', 'Adana, Seyhan', 168, 62, 'SGK', 'Kuruyemiş', 'Migren', 'B-');

INSERT INTO Hasta (HastaID, Ad, Soyad, TCKN, DogumTarihi, Cinsiyet, Telefon, Eposta, Adres, BoyCM, KiloKG, SigortaTuru, Alerjiler, KronikHastaliklar, KanGrubu)
VALUES (7, 'Emre', 'Koç', '78901234567', TO_DATE('1975-12-05', 'YYYY-MM-DD'), 'Erkek', '05335556677', 'emre.koc@example.com', 'Konya, Meram', 182, 90, 'Özel', NULL, 'Reflü', 'O-');

INSERT INTO Hasta (HastaID, Ad, Soyad, TCKN, DogumTarihi, Cinsiyet, Telefon, Eposta, Adres, BoyCM, KiloKG, SigortaTuru, Alerjiler, KronikHastaliklar, KanGrubu)
VALUES (8, 'Selin', 'Yıldırım', '89012345678', TO_DATE('2002-06-21', 'YYYY-MM-DD'), 'Kadın', '05336667788', 'selin.yildirim@example.com', 'Kayseri, Kocasinan', 160, 55, 'Yok', 'Deniz ürünleri', NULL, 'AB-');

INSERT INTO Hasta (HastaID, Ad, Soyad, TCKN, DogumTarihi, Cinsiyet, Telefon, Eposta, Adres, BoyCM, KiloKG, SigortaTuru, Alerjiler, KronikHastaliklar, KanGrubu)
VALUES (9, 'Tolga', 'Arslan', '90123456789', TO_DATE('1992-11-11', 'YYYY-MM-DD'), 'Erkek', '05337778899', 'tolga.arslan@example.com', 'Mersin, Yenişehir', 177, 74, 'SGK', 'Yok', 'Hipotiroidi', 'A-');

INSERT INTO Hasta (HastaID, Ad, Soyad, TCKN, DogumTarihi, Cinsiyet, Telefon, Eposta, Adres, BoyCM, KiloKG, SigortaTuru, Alerjiler, KronikHastaliklar, KanGrubu)
VALUES (10, 'Seda', 'Güneş', '01234567890', TO_DATE('1980-03-30', 'YYYY-MM-DD'), 'Kadın', '05338889900', 'seda.gunes@example.com', 'Samsun, Atakum', 164, 58, 'Özel', 'Latex', 'Obezite', 'O+');

INSERT INTO Hasta (HastaID, Ad, Soyad, TCKN, DogumTarihi, Cinsiyet, Telefon, Eposta, Adres, BoyCM, KiloKG, SigortaTuru, Alerjiler, KronikHastaliklar, KanGrubu)
VALUES (11, 'Volkan', 'Yavuz', '11223344556', TO_DATE('1969-08-09', 'YYYY-MM-DD'), 'Erkek', '05339990011', 'volkan.yavuz@example.com', 'Eskişehir, Tepebaşı', 185, 88, 'SGK', NULL, 'KOAH', 'B+');

INSERT INTO Hasta (HastaID, Ad, Soyad, TCKN, DogumTarihi, Cinsiyet, Telefon, Eposta, Adres, BoyCM, KiloKG, SigortaTuru, Alerjiler, KronikHastaliklar, KanGrubu)
VALUES (12, 'Ayşe', 'Polat', '22334455667', TO_DATE('2005-05-14', 'YYYY-MM-DD'), 'Kadın', '05440001122', 'ayse.polat@example.com', 'Balıkesir, Altıeylül', 158, 50, 'Yok', NULL, NULL, 'AB+');

INSERT INTO Hasta (HastaID, Ad, Soyad, TCKN, DogumTarihi, Cinsiyet, Telefon, Eposta, Adres, BoyCM, KiloKG, SigortaTuru, Alerjiler, KronikHastaliklar, KanGrubu)
VALUES (13, 'Kerem', 'Çelik', '33445566778', TO_DATE('1997-10-01', 'YYYY-MM-DD'), 'Erkek', '05441112233', 'kerem.celik@example.com', 'Trabzon, Ortahisar', 178, 76, 'SGK', 'Süt ürünleri', 'Çölyak', 'A+');

INSERT INTO Hasta (HastaID, Ad, Soyad, TCKN, DogumTarihi, Cinsiyet, Telefon, Eposta, Adres, BoyCM, KiloKG, SigortaTuru, Alerjiler, KronikHastaliklar, KanGrubu)
VALUES (14, 'Nazlı', 'Yılmaz', '44556677889', TO_DATE('1983-04-27', 'YYYY-MM-DD'), 'Kadın', '05442223344', 'nazli.yilmaz@example.com', 'Antalya, Kepez', 167, 59, 'Özel', 'Soya', 'Anemi', 'B+');

INSERT INTO Hasta (HastaID, Ad, Soyad, TCKN, DogumTarihi, Cinsiyet, Telefon, Eposta, Adres, BoyCM, KiloKG, SigortaTuru, Alerjiler, KronikHastaliklar, KanGrubu)
VALUES (15, 'Cihan', 'Karaoğlu', '55667788990', TO_DATE('1972-01-19', 'YYYY-MM-DD'), 'Erkek', '05443334455', NULL, 'Elazığ, Merkez', 180, 82, 'SGK', NULL, 'Gut', 'O-');

INSERT INTO Hasta (HastaID, Ad, Soyad, TCKN, DogumTarihi, Cinsiyet, Telefon, Eposta, Adres, BoyCM, KiloKG, SigortaTuru, Alerjiler, KronikHastaliklar, KanGrubu)
VALUES (16, 'Derya', 'Acar', '66778899001', TO_DATE('1999-09-09', 'YYYY-MM-DD'), 'Kadın', '05444445566', 'derya.acar@example.com', 'Van, İpekyolu', 162, 54, 'Yok', 'Gluten', NULL, 'A-');

INSERT INTO Hasta (HastaID, Ad, Soyad, TCKN, DogumTarihi, Cinsiyet, Telefon, Eposta, Adres, BoyCM, KiloKG, SigortaTuru, Alerjiler, KronikHastaliklar, KanGrubu)
VALUES (17, 'Ümit', 'Taş', '77889900112', TO_DATE('1965-06-03', 'YYYY-MM-DD'), 'Erkek', '05445556677', 'umit.task@example.com', 'Gaziantep, Şahinbey', 176, 79, 'Özel', 'Arı ürünleri', 'Parkinson', 'AB-');

INSERT INTO Hasta (HastaID, Ad, Soyad, TCKN, DogumTarihi, Cinsiyet, Telefon, Eposta, Adres, BoyCM, KiloKG, SigortaTuru, Alerjiler, KronikHastaliklar, KanGrubu)
VALUES (18, 'Funda', 'Erdoğan', '88990011223', TO_DATE('1977-12-24', 'YYYY-MM-DD'), 'Kadın', '05446667788', 'funda.erdogan@example.com', 'Kocaeli, İzmit', 169, 65, 'SGK', NULL, 'Romatoid Artrit', 'B-');

INSERT INTO Hasta (HastaID, Ad, Soyad, TCKN, DogumTarihi, Cinsiyet, Telefon, Eposta, Adres, BoyCM, KiloKG, SigortaTuru, Alerjiler, KronikHastaliklar, KanGrubu)
VALUES (19, 'Gökhan', 'Yılmazer', '99001122334', TO_DATE('1986-07-07', 'YYYY-MM-DD'), 'Erkek', '05447778899', 'gokhan.yilmazer@example.com', 'Manisa, Yunusemre', 183, 92, 'Özel', 'Latex', NULL, 'O+');

INSERT INTO Hasta (HastaID, Ad, Soyad, TCKN, DogumTarihi, Cinsiyet, Telefon, Eposta, Adres, BoyCM, KiloKG, SigortaTuru, Alerjiler, KronikHastaliklar, KanGrubu)
VALUES (20, 'Melis', 'Uslu', '10111213141', TO_DATE('2003-03-15', 'YYYY-MM-DD'), 'Kadın', '05448889900', 'melis.uslu@example.com', 'Sivas, Merkez', 161, 53, 'Yok', 'Polen', NULL, 'AB+');

--2. Doktor

INSERT INTO Doktor (DoktorID, Ad, Soyad, Brans, DiplomaNo, Unvan, OdaNumarasi, Telefon, Eposta, Maas)
VALUES (1, 'Ahmet', 'Kaya', 'Kulak Burun Boğaz', 'KBB123456', 'Uzman', 'KBB101', '05321234501', 'ahmet.kaya@hastane.com', 45000.00);

INSERT INTO Doktor (DoktorID, Ad, Soyad, Brans, DiplomaNo, Unvan, OdaNumarasi, Telefon, Eposta, Maas)
VALUES (2, 'Zeynep', 'Demirtaş', 'Kulak Burun Boğaz', 'KBB234567', 'Doç.', 'KBB102', '05321234502', 'zeynep.demirtas@hastane.com', 52000.00);

INSERT INTO Doktor (DoktorID, Ad, Soyad, Brans, DiplomaNo, Unvan, OdaNumarasi, Telefon, Eposta, Maas)
VALUES (3, 'Murat', 'Aydın', 'Kulak Burun Boğaz', 'KBB345678', 'Prof.', 'KBB103', '05321234503', 'murat.aydin@hastane.com', 60000.00);

INSERT INTO Doktor (DoktorID, Ad, Soyad, Brans, DiplomaNo, Unvan, OdaNumarasi, Telefon, Eposta, Maas)
VALUES (4, 'Elif', 'Çetin', 'Kulak Burun Boğaz', 'KBB456789', 'Uzman', 'KBB104', '05321234504', 'elif.cetin@hastane.com', 46000.00);

INSERT INTO Doktor (DoktorID, Ad, Soyad, Brans, DiplomaNo, Unvan, OdaNumarasi, Telefon, Eposta, Maas)
VALUES (5, 'Baran', 'Yılmaz', 'Kulak Burun Boğaz', 'KBB567890', 'Doç.', 'KBB105', '05321234505', 'baran.yilmaz@hastane.com', 50000.00);

-- 3. Personel

INSERT INTO Personel (PersonelID, Ad, Soyad, Gorev, Departman, Telefon, Eposta, Maas)
VALUES (1, 'Sevgi', 'Karakaya', 'Sekreter', 'KBB Polikliniği', '05321234501', 'sevgi.karakaya@hastane.com', 17500.00);

INSERT INTO Personel (PersonelID, Ad, Soyad, Gorev, Departman, Telefon, Eposta, Maas)
VALUES (2, 'Mert', 'Aslan', 'Sekreter', 'KBB Polikliniği', '05321234502', 'mert.aslan@hastane.com', 17500.00);

INSERT INTO Personel (PersonelID, Ad, Soyad, Gorev, Departman, Telefon, Eposta, Maas)
VALUES (3, 'Duygu', 'Aydın', 'Hemşire', 'KBB Polikliniği', '05321234503', 'duygu.aydin@hastane.com', 21000.00);

INSERT INTO Personel (PersonelID, Ad, Soyad, Gorev, Departman, Telefon, Eposta, Maas)
VALUES (4, 'Hakan', 'Çelik', 'Hemşire', 'KBB Polikliniği', '05321234504', 'hakan.celik@hastane.com', 21000.00);

INSERT INTO Personel (PersonelID, Ad, Soyad, Gorev, Departman, Telefon, Eposta, Maas)
VALUES (5, 'Fatma', 'Güler', 'Temizlik Görevlisi', 'Temizlik', '05321234505', 'fatma.guler@hastane.com', 15000.00);

INSERT INTO Personel (PersonelID, Ad, Soyad, Gorev, Departman, Telefon, Eposta, Maas)
VALUES (6, 'Tolga', 'Kurt', 'Tıbbi Tekniker', 'KBB Polikliniği', '05321234506', 'tolga.kurt@hastane.com', 19500.00);

INSERT INTO Personel (PersonelID, Ad, Soyad, Gorev, Departman, Telefon, Eposta, Maas)
VALUES (7, 'Yasemin', 'Özdemir', 'İdari Sorumlu', 'Poliklinik Yönetimi', '05321234507', 'yasemin.ozdemir@hastane.com', 25000.00);

INSERT INTO Personel (PersonelID, Ad, Soyad, Gorev, Departman, Telefon, Eposta, Maas)
VALUES (8, 'Kemal', 'Şimşek', 'Güvenlik Görevlisi', 'Güvenlik', '05321234508', 'kemal.simsek@hastane.com', 16500.00);

-- 4. Randevular

INSERT INTO Randevu (RandevuID, HastaID, DoktorID, TarihSaat, Durum)
VALUES (1, 1, 2, TO_DATE('2025-05-01 10:00', 'YYYY-MM-DD HH24:MI'), 'Tamamlandı');

INSERT INTO Randevu (RandevuID, HastaID, DoktorID, TarihSaat, Durum)
VALUES (2, 2, 3, TO_DATE('2025-05-02 11:00', 'YYYY-MM-DD HH24:MI'), 'Tamamlandı');

INSERT INTO Randevu (RandevuID, HastaID, DoktorID, TarihSaat, Durum)
VALUES (3, 3, 1, TO_DATE('2025-05-03 09:30', 'YYYY-MM-DD HH24:MI'), 'İptal');

INSERT INTO Randevu (RandevuID, HastaID, DoktorID, TarihSaat, Durum)
VALUES (4, 4, 4, TO_DATE('2025-05-04 14:00', 'YYYY-MM-DD HH24:MI'), 'Tamamlandı');

INSERT INTO Randevu (RandevuID, HastaID, DoktorID, TarihSaat, Durum)
VALUES (5, 5, 5, TO_DATE('2025-05-05 13:00', 'YYYY-MM-DD HH24:MI'), 'Bekliyor');

INSERT INTO Randevu (RandevuID, HastaID, DoktorID, TarihSaat, Durum)
VALUES (6, 1, 3, TO_DATE('2025-05-06 15:30', 'YYYY-MM-DD HH24:MI'), 'Bekliyor');

INSERT INTO Randevu (RandevuID, HastaID, DoktorID, TarihSaat, Durum)
VALUES (7, 2, 1, TO_DATE('2025-05-07 10:30', 'YYYY-MM-DD HH24:MI'), 'Bekliyor');

INSERT INTO Randevu (RandevuID, HastaID, DoktorID, TarihSaat, Durum)
VALUES (8, 3, 2, TO_DATE('2025-05-08 12:00', 'YYYY-MM-DD HH24:MI'), 'Tamamlandı');

-- 5. Muayene

INSERT INTO Muayene (MuayeneID, RandevuID, DoktorID, Bulgular, Notlar, Epikriz, MuayeneTarihi)
VALUES (1, 1, 2, 'Burun tıkanıklığı ve geniz akıntısı', 'Alerjik rinit şüphesi', 'Hastaya antihistaminik başlandı', TO_DATE('2025-05-01', 'YYYY-MM-DD'));

INSERT INTO Muayene (MuayeneID, RandevuID, DoktorID, Bulgular, Notlar, Epikriz, MuayeneTarihi)
VALUES (2, 2, 3, 'Tek taraflı kulak ağrısı', 'Timpanik membranda kızarıklık', 'Akut otit teşhisi kondu', TO_DATE('2025-05-02', 'YYYY-MM-DD'));

INSERT INTO Muayene (MuayeneID, RandevuID, DoktorID, Bulgular, Notlar, Epikriz, MuayeneTarihi)
VALUES (3, 4, 4, 'Boğazda ağrı ve yutma güçlüğü', 'Tonsiller büyümüş ve kızarık', 'Bakteriyel tonsillit düşünülüyor', TO_DATE('2025-05-04', 'YYYY-MM-DD'));

INSERT INTO Muayene (MuayeneID, RandevuID, DoktorID, Bulgular, Notlar, Epikriz, MuayeneTarihi)
VALUES (4, 8, 2, 'Baş dönmesi ve denge kaybı', 'Odyolojik test önerildi', 'Vertigo değerlendirmesi yapılacak', TO_DATE('2025-05-08', 'YYYY-MM-DD'));

-- 6. Tanılar

INSERT INTO Tani (TaniID, MuayeneID, ICD10Kodu, Aciklama, TaniTarihi)
VALUES (1, 1, 'J30.1', 'Alerjik rinit', TO_DATE('2025-05-01', 'YYYY-MM-DD'));

INSERT INTO Tani (TaniID, MuayeneID, ICD10Kodu, Aciklama, TaniTarihi)
VALUES (2, 2, 'H66.0', 'Akut otitis media', TO_DATE('2025-05-02', 'YYYY-MM-DD'));

INSERT INTO Tani (TaniID, MuayeneID, ICD10Kodu, Aciklama, TaniTarihi)
VALUES (3, 3, 'J03.0', 'Streptokokal tonsillit', TO_DATE('2025-05-04', 'YYYY-MM-DD'));

INSERT INTO Tani (TaniID, MuayeneID, ICD10Kodu, Aciklama, TaniTarihi)
VALUES (4, 4, 'H81.0', 'Vertigo, periferik kaynaklı', TO_DATE('2025-05-08', 'YYYY-MM-DD'));

INSERT INTO Tani (TaniID, MuayeneID, ICD10Kodu, Aciklama, TaniTarihi)
VALUES (5, 4, 'R42', 'Baş dönmesi ve denge bozukluğu', TO_DATE('2025-05-08', 'YYYY-MM-DD'));

-- 7. Tedavi Planı

INSERT INTO TedaviPlani (TedaviID, TaniID, Aciklama, BaslangicTarihi, BitisTarihi, RaporGunSayisi, DoktorID)
VALUES (1, 1, 'Alerji için antihistaminik tedavi', TO_DATE('2025-05-01', 'YYYY-MM-DD'), TO_DATE('2025-05-07', 'YYYY-MM-DD'), 7, 2);

INSERT INTO TedaviPlani (TedaviID, TaniID, Aciklama, BaslangicTarihi, BitisTarihi, RaporGunSayisi, DoktorID)
VALUES (2, 2, 'Akut otit için antibiyotik ve ağrı kesici', TO_DATE('2025-05-02', 'YYYY-MM-DD'), TO_DATE('2025-05-06', 'YYYY-MM-DD'), 5, 3);

INSERT INTO TedaviPlani (TedaviID, TaniID, Aciklama, BaslangicTarihi, BitisTarihi, RaporGunSayisi, DoktorID)
VALUES (3, 3, 'Tonsillit için antibiyotik ve istirahat', TO_DATE('2025-05-04', 'YYYY-MM-DD'), TO_DATE('2025-05-10', 'YYYY-MM-DD'), 7, 4);

INSERT INTO TedaviPlani (TedaviID, TaniID, Aciklama, BaslangicTarihi, BitisTarihi, RaporGunSayisi, DoktorID)
VALUES (4, 4, 'Vertigo için fizik tedavi ve ilaç', TO_DATE('2025-05-08', 'YYYY-MM-DD'), TO_DATE('2025-05-15', 'YYYY-MM-DD'), 5, 2);

-- 8. İlaçlar

INSERT INTO Ilac (IlacID, IlacAdi, EtkenMadde, Dozaj, Form, YanEtkiler)
VALUES (1, 'Alerdex', 'Loratadin', '10 mg', 'Tablet', 'Uyku hali, baş dönmesi');

INSERT INTO Ilac (IlacID, IlacAdi, EtkenMadde, Dozaj, Form, YanEtkiler)
VALUES (2, 'Augmentin', 'Amoksisilin + Klavulanik Asit', '500/125 mg', 'Tablet', 'İshal, mide bulantısı');

INSERT INTO Ilac (IlacID, IlacAdi, EtkenMadde, Dozaj, Form, YanEtkiler)
VALUES (3, 'Parol', 'Parasetamol', '500 mg', 'Tablet', 'Karaciğer etkileri (nadiren)');

INSERT INTO Ilac (IlacID, IlacAdi, EtkenMadde, Dozaj, Form, YanEtkiler)
VALUES (4, 'Otinil', 'Fenazon + Lidokain', '5 ml', 'Ampul', 'Kulak kaşıntısı');

INSERT INTO Ilac (IlacID, IlacAdi, EtkenMadde, Dozaj, Form, YanEtkiler)
VALUES (5, 'Betaserc', 'Betahistin', '16 mg', 'Tablet', 'Baş ağrısı, mide rahatsızlığı');

INSERT INTO Ilac (IlacID, IlacAdi, EtkenMadde, Dozaj, Form, YanEtkiler)
VALUES (6, 'Bactroban', 'Mupirosin', '2%', 'Krem', 'Ciltte yanma hissi');

-- 9. Reçeteler

INSERT INTO Recete (ReceteID, HastaID, DoktorID, MuayeneID, Tarih, Notlar)
VALUES (1, 1, 2, 1, TO_DATE('2025-05-01', 'YYYY-MM-DD'), 'Alerji için önerilen ilaçlar reçetelendi.');

INSERT INTO Recete (ReceteID, HastaID, DoktorID, MuayeneID, Tarih, Notlar)
VALUES (2, 2, 3, 2, TO_DATE('2025-05-02', 'YYYY-MM-DD'), 'Orta kulak iltihabı için antibiyotik reçete edildi.');

INSERT INTO Recete (ReceteID, HastaID, DoktorID, MuayeneID, Tarih, Notlar)
VALUES (3, 4, 4, 3, TO_DATE('2025-05-04', 'YYYY-MM-DD'), 'Tonsillit tedavisine yönelik ilaçlar verildi.');

INSERT INTO Recete (ReceteID, HastaID, DoktorID, MuayeneID, Tarih, Notlar)
VALUES (4, 3, 2, 4, TO_DATE('2025-05-08', 'YYYY-MM-DD'), 'Baş dönmesi için Betaserc reçetelendi.');

-- 10. Reçete-İlaç

INSERT INTO Recete_Ilac (ReceteID, IlacID, Dozaj, Siklik, GunSayisi, Miktar)
VALUES (1, 1, '10 mg', 'Günde 1 kez', 7, 7);

INSERT INTO Recete_Ilac (ReceteID, IlacID, Dozaj, Siklik, GunSayisi, Miktar)
VALUES (2, 2, '500/125 mg', 'Günde 2 kez', 5, 10);

INSERT INTO Recete_Ilac (ReceteID, IlacID, Dozaj, Siklik, GunSayisi, Miktar)
VALUES (2, 3, '500 mg', 'Günde 3 kez', 5, 15);

INSERT INTO Recete_Ilac (ReceteID, IlacID, Dozaj, Siklik, GunSayisi, Miktar)
VALUES (3, 2, '500/125 mg', 'Günde 2 kez', 7, 14);

INSERT INTO Recete_Ilac (ReceteID, IlacID, Dozaj, Siklik, GunSayisi, Miktar)
VALUES (3, 3, '500 mg', 'Günde 3 kez', 7, 21);

INSERT INTO Recete_Ilac (ReceteID, IlacID, Dozaj, Siklik, GunSayisi, Miktar)
VALUES (4, 5, '16 mg', 'Günde 2 kez', 5, 10);

-- 11. Envanter

INSERT INTO Envanter (EnvanterID, IlacID, UrunAdi, Miktar, KullanimAlani, SonKullanmaTarihi)
VALUES (1, 1, 'Alerdex 10 mg Tablet', 150, 'Alerji', TO_DATE('2026-03-31', 'YYYY-MM-DD'));

INSERT INTO Envanter (EnvanterID, IlacID, UrunAdi, Miktar, KullanimAlani, SonKullanmaTarihi)
VALUES (2, 2, 'Augmentin 500/125 mg', 200, 'Antibiyotik', TO_DATE('2025-12-15', 'YYYY-MM-DD'));

INSERT INTO Envanter (EnvanterID, IlacID, UrunAdi, Miktar, KullanimAlani, SonKullanmaTarihi)
VALUES (3, 3, 'Parol 500 mg', 300, 'Ağrı kesici', TO_DATE('2027-01-10', 'YYYY-MM-DD'));

INSERT INTO Envanter (EnvanterID, IlacID, UrunAdi, Miktar, KullanimAlani, SonKullanmaTarihi)
VALUES (4, 4, 'Otinil Ampul', 75, 'Kulak damlası', TO_DATE('2025-10-05', 'YYYY-MM-DD'));

INSERT INTO Envanter (EnvanterID, IlacID, UrunAdi, Miktar, KullanimAlani, SonKullanmaTarihi)
VALUES (5, 5, 'Betaserc 16 mg Tablet', 120, 'Baş dönmesi', TO_DATE('2026-06-20', 'YYYY-MM-DD'));

INSERT INTO Envanter (EnvanterID, IlacID, UrunAdi, Miktar, KullanimAlani, SonKullanmaTarihi)
VALUES (6, 6, 'Bactroban Krem 2%', 80, 'Cilt enfeksiyonları', TO_DATE('2025-11-30', 'YYYY-MM-DD'));

-- 12. Cihazlar

INSERT INTO Cihaz (CihazID, CihazAd, OdaID, Marka, Model, Durum)
VALUES (1, 'Odyometri Cihazı', 'KBB101', 'Interacoustics', 'AC40', 'Aktif');

INSERT INTO Cihaz (CihazID, CihazAd, OdaID, Marka, Model, Durum)
VALUES (2, 'Timpanometre', 'KBB102', 'Maico', 'MI34', 'Kalibrasyonda');

INSERT INTO Cihaz (CihazID, CihazAd, OdaID, Marka, Model, Durum)
VALUES (3, 'Endoskopi Sistemi', 'KBB103', 'Olympus', 'ENF-VH', 'Aktif');

INSERT INTO Cihaz (CihazID, CihazAd, OdaID, Marka, Model, Durum)
VALUES (4, 'Sterilizasyon Ünitesi', 'KBB104', 'Tuttnauer', '3870EA', 'Arızalı');

INSERT INTO Cihaz (CihazID, CihazAd, OdaID, Marka, Model, Durum)
VALUES (5, 'Nazal Endoskop', 'KBB105', 'Karl Storz', '11101RP2', 'Aktif');



-- 13. Tahliller

INSERT INTO Tahlil (TestID, HastaID, DoktorID, MuayeneID, TestTuru, Sonuc, Durum, TestTarihi)
VALUES (1, 1, 2, 1, 'Alerji Paneli', 'Toz akarına pozitif', 'Sonuçlandı', TO_DATE('2025-05-01', 'YYYY-MM-DD'));

INSERT INTO Tahlil (TestID, HastaID, DoktorID, MuayeneID, TestTuru, Sonuc, Durum, TestTarihi)
VALUES (2, 2, 3, 2, 'Tam Kan Sayımı', 'WBC yüksek', 'Sonuçlandı', TO_DATE('2025-05-02', 'YYYY-MM-DD'));

INSERT INTO Tahlil (TestID, HastaID, DoktorID, MuayeneID, TestTuru, Sonuc, Durum, TestTarihi)
VALUES (3, 3, 2, 4, 'Denge Testi', 'Normale yakın', 'Bekliyor', TO_DATE('2025-05-08', 'YYYY-MM-DD'));

INSERT INTO Tahlil (TestID, HastaID, DoktorID, MuayeneID, TestTuru, Sonuc, Durum, TestTarihi)
VALUES (4, 4, 4, 3, 'Boğaz Kültürü', 'Streptokok pozitif', 'Sonuçlandı', TO_DATE('2025-05-04', 'YYYY-MM-DD'));

-- 14. Fatura

INSERT INTO Fatura (FaturaID, HastaID, RandevuID, HizmetAciklamasi, Tutar, SigortaKapsami, OdemeDurumu)
VALUES (1, 1, 1, 'Muayene + Alerji Testi', 750.00, 'Evet', 'Ödendi');

INSERT INTO Fatura (FaturaID, HastaID, RandevuID, HizmetAciklamasi, Tutar, SigortaKapsami, OdemeDurumu)
VALUES (2, 2, 2, 'Muayene + Kan Tahlili', 650.00, 'Evet', 'Ödendi');

INSERT INTO Fatura (FaturaID, HastaID, RandevuID, HizmetAciklamasi, Tutar, SigortaKapsami, OdemeDurumu)
VALUES (3, 3, 3, 'Randevu (İptal Edildi)', 0.00, 'Evet', 'İptal');

INSERT INTO Fatura (FaturaID, HastaID, RandevuID, HizmetAciklamasi, Tutar, SigortaKapsami, OdemeDurumu)
VALUES (4, 4, 4, 'Muayene + Boğaz Kültürü', 800.00, 'Evet', 'Bekliyor');

INSERT INTO Fatura (FaturaID, HastaID, RandevuID, HizmetAciklamasi, Tutar, SigortaKapsami, OdemeDurumu)
VALUES (5, 5, 5, 'Muayene', 500.00, 'Evet', 'Bekliyor');

-- 15. Kullanıcılar

INSERT INTO Kullanici (KullaniciID, DoktorID, PersonelID, KullaniciAdi, Sifre, YetkiSeviyesi)
VALUES (1, 1, NULL, 'dr.ahmet', 'sifre123', 'Doktor');

INSERT INTO Kullanici (KullaniciID, DoktorID, PersonelID, KullaniciAdi, Sifre, YetkiSeviyesi)
VALUES (2, 2, NULL, 'dr.zeynep', 'sifre234', 'Doktor');

INSERT INTO Kullanici (KullaniciID, DoktorID, PersonelID, KullaniciAdi, Sifre, YetkiSeviyesi)
VALUES (3, NULL, 1, 'sevgi.sekreter', 'sifre345', 'Sekreter');

INSERT INTO Kullanici (KullaniciID, DoktorID, PersonelID, KullaniciAdi, Sifre, YetkiSeviyesi)
VALUES (4, NULL, 7, 'yasemin.admin', 'admin123', 'Admin');

INSERT INTO Kullanici (KullaniciID, DoktorID, PersonelID, KullaniciAdi, Sifre, YetkiSeviyesi)
VALUES (5, 3, NULL, 'dr.murat', 'sifre456', 'Doktor');

-- 16. Çalışma Takvimi

-- Pazartesi
INSERT INTO CalismaTakvimi (TakvimID, DoktorID, PersonelID, Gun, BaslangicSaat, BitisSaat)
VALUES (1, 1, NULL, 'Pazartesi', '09:00', '17:00');
INSERT INTO CalismaTakvimi (TakvimID, DoktorID, PersonelID, Gun, BaslangicSaat, BitisSaat)
VALUES (2, 2, NULL, 'Pazartesi', '09:00', '17:00');

-- Salı
INSERT INTO CalismaTakvimi (TakvimID, DoktorID, PersonelID, Gun, BaslangicSaat, BitisSaat)
VALUES (3, 3, NULL, 'Salı', '09:00', '17:00');
INSERT INTO CalismaTakvimi (TakvimID, DoktorID, PersonelID, Gun, BaslangicSaat, BitisSaat)
VALUES (4, 4, NULL, 'Salı', '09:00', '17:00');

-- Çarşamba
INSERT INTO CalismaTakvimi (TakvimID, DoktorID, PersonelID, Gun, BaslangicSaat, BitisSaat)
VALUES (5, 5, NULL, 'Çarşamba', '09:00', '17:00');
INSERT INTO CalismaTakvimi (TakvimID, DoktorID, PersonelID, Gun, BaslangicSaat, BitisSaat)
VALUES (6, 1, NULL, 'Çarşamba', '09:00', '17:00');

-- Perşembe
INSERT INTO CalismaTakvimi (TakvimID, DoktorID, PersonelID, Gun, BaslangicSaat, BitisSaat)
VALUES (7, 2, NULL, 'Perşembe', '09:00', '17:00');
INSERT INTO CalismaTakvimi (TakvimID, DoktorID, PersonelID, Gun, BaslangicSaat, BitisSaat)
VALUES (8, 3, NULL, 'Perşembe', '09:00', '17:00');

-- Cuma
INSERT INTO CalismaTakvimi (TakvimID, DoktorID, PersonelID, Gun, BaslangicSaat, BitisSaat)
VALUES (9, 4, NULL, 'Cuma', '09:00', '17:00');
INSERT INTO CalismaTakvimi (TakvimID, DoktorID, PersonelID, Gun, BaslangicSaat, BitisSaat)
VALUES (10, 5, NULL, 'Cuma', '09:00', '17:00');

-- Cumartesi (sadece 1 doktor)
INSERT INTO CalismaTakvimi (TakvimID, DoktorID, PersonelID, Gun, BaslangicSaat, BitisSaat)
VALUES (11, 1, NULL, 'Cumartesi', '09:00', '17:00');

-- Pazar (sadece 1 doktor)
INSERT INTO CalismaTakvimi (TakvimID, DoktorID, PersonelID, Gun, BaslangicSaat, BitisSaat)
VALUES (12, 2, NULL, 'Pazar', '09:00', '17:00');

--17. Oda
INSERT INTO Oda (OdaID, KullanimAmaci) VALUES ('KBB101', 'Muayene ve Odyometri');
INSERT INTO Oda (OdaID, KullanimAmaci) VALUES ('KBB102', 'Muayene ve Timpanometri');
INSERT INTO Oda (OdaID, KullanimAmaci) VALUES ('KBB103', 'Muayene ve Endoskopi');
INSERT INTO Oda (OdaID, KullanimAmaci) VALUES ('KBB104', 'Muayene ve Sterilizasyon');
INSERT INTO Oda (OdaID, KullanimAmaci) VALUES ('KBB105', 'Muayene ve Nazal Endoskopi');

