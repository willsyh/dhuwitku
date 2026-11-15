/// Keyword → default category name rules, checked in order (more specific
/// first). Names match `defaultCategories`.
typedef CategoryRule = (String name, List<String> words);

/// Store / brand names, as printed on receipts.
const storeCategoryRules = <CategoryRule>[
  ('Bensin', ['spbu', 'pertamina', 'shell', 'bp akr', 'vivo energy', 'pertalite', 'pertamax', 'dexlite', 'bbm']),
  ('Parkir', ['parkir', 'parking', 'secure parking']),
  ('Kopi', ['kopi', 'coffee', 'cafe', 'starbucks', 'janji jiwa', 'kenangan', 'fore', 'tomoro', 'excelso']),
  ('Kesehatan', ['apotek', 'apotik', 'pharmacy', 'kimia farma', 'k-24', 'k24', 'guardian', 'century', 'klinik', 'rumah sakit']),
  ('Tagihan', ['pln', 'token listrik', 'pdam', 'telkom', 'indihome', 'pulsa', 'paket data', 'bpjs']),
  ('Hiburan', ['cinema', 'xxi', 'cgv', 'cinepolis', 'bioskop', 'karaoke', 'timezone']),
  ('Transportasi', ['grab', 'gojek', 'gocar', 'goride', 'kai', 'krl', 'kereta', 'e-toll', 'tol', 'damri', 'bluebird', 'taxi', 'transjakarta']),
  ('Makan', ['resto', 'restaurant', 'restoran', 'rumah makan', 'warung', 'warteg', 'bakso', 'mie', 'nasi', 'ayam', 'sate', 'kfc', 'mcdonald', 'mcd', 'burger', 'pizza', 'solaria', 'hokben', 'richeese', 'padang', 'dimsum', 'seafood']),
  ('Belanja Harian', ['indomaret', 'alfamart', 'alfamidi', 'superindo', 'hypermart', 'transmart', 'lotte mart', 'lottemart', 'giant', 'hero', 'carrefour', 'ranch market', 'farmers market', 'minimarket', 'supermarket', 'swalayan', 'grosir']),
  ('Belanja', ['matahari', 'uniqlo', 'h&m', 'zara', 'ace hardware', 'informa', 'miniso', 'erafone', 'ibox', 'gramedia', 'department store']),
];

/// Everyday words people type in chat ("ngopi 20rb", "ojol 15rb"), checked
/// before the store rules.
const chatExpenseRules = <CategoryRule>[
  ('Kopi', ['ngopi', 'kopi susu', 'es kopi', 'latte', 'cappuccino', 'americano']),
  ('Bensin', ['bensin', 'isi bensin', 'solar']),
  ('Transportasi', ['ojol', 'ojek', 'angkot', 'bus', 'busway', 'mrt', 'lrt', 'travel', 'tiket kereta', 'naik grab', 'naik gojek']),
  ('Tagihan', ['listrik', 'wifi', 'internet', 'cicilan', 'kos', 'kost', 'kosan', 'sewa', 'iuran', 'air pdam']),
  ('Kesehatan', ['obat', 'dokter', 'vitamin', 'periksa', 'berobat']),
  ('Hiburan', ['nonton', 'film', 'netflix', 'spotify', 'youtube premium', 'game', 'konser', 'langganan']),
  ('Belanja Harian', ['sayur', 'belanja dapur', 'beras', 'galon', 'gas elpiji', 'elpiji', 'sabun', 'telur', 'minyak goreng']),
  ('Belanja', ['baju', 'sepatu', 'celana', 'tas', 'shopee', 'tokopedia', 'lazada', 'olshop', 'online shop']),
  ('Makan', ['makan', 'sarapan', 'makan siang', 'makan malam', 'lunch', 'dinner', 'breakfast', 'nasgor', 'gorengan', 'jajan', 'snack', 'cemilan', 'martabak', 'seblak', 'mi ayam', 'indomie', 'es teh', 'minum']),
];

/// Income words → default income category name.
const chatIncomeRules = <CategoryRule>[
  ('Gaji', ['gaji', 'gajian', 'salary', 'thr', 'bonus']),
  ('Uang Saku', ['uang saku', 'uang jajan', 'dikasih', 'dikirimin', 'kiriman']),
  ('Freelance', ['freelance', 'proyek', 'project', 'fee', 'honor', 'komisi']),
  ('Bisnis', ['jualan', 'bisnis', 'omzet', 'untung', 'laba', 'penjualan']),
  ('Investasi', ['dividen', 'bunga', 'investasi', 'reksadana', 'reksa dana', 'saham', 'kupon']),
];

/// Words that mark money coming in.
const incomeWords = [
  'pemasukan', 'pendapatan', 'penghasilan', 'income', 'terima', 'diterima', 'dapat', 'dapet',
  'masuk', 'uang masuk', 'transfer masuk',
];
