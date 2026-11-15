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
  ('Kopi', ['ngopi', 'kopi susu', 'es kopi', 'latte', 'cappuccino', 'americano', 'espresso']),
  ('Bensin', ['bensin', 'isi bensin', 'solar', 'fuel', 'petrol', 'gasoline']),
  ('Parkir', ['parking fee']),
  ('Transportasi', ['ojol', 'ojek', 'angkot', 'bus', 'busway', 'mrt', 'lrt', 'travel', 'tiket kereta', 'naik grab', 'naik gojek', 'transport', 'taxi', 'uber', 'train', 'ride', 'toll']),
  ('Tagihan', ['listrik', 'wifi', 'internet', 'cicilan', 'kos', 'kost', 'kosan', 'sewa', 'iuran', 'air pdam', 'bill', 'bills', 'electricity', 'rent', 'installment', 'subscription']),
  ('Kesehatan', ['obat', 'dokter', 'vitamin', 'periksa', 'berobat', 'medicine', 'doctor', 'hospital', 'vitamins', 'health']),
  ('Hiburan', ['nonton', 'film', 'netflix', 'spotify', 'youtube premium', 'game', 'konser', 'langganan', 'movie', 'movies', 'games', 'concert', 'entertainment']),
  ('Belanja Harian', ['sayur', 'belanja dapur', 'beras', 'galon', 'gas elpiji', 'elpiji', 'sabun', 'telur', 'minyak goreng', 'groceries', 'grocery', 'vegetables']),
  ('Belanja', ['baju', 'sepatu', 'celana', 'tas', 'shopee', 'tokopedia', 'lazada', 'olshop', 'online shop', 'shopping', 'clothes', 'shoes']),
  ('Makan', ['makan', 'sarapan', 'makan siang', 'makan malam', 'lunch', 'dinner', 'breakfast', 'nasgor', 'gorengan', 'jajan', 'snack', 'cemilan', 'martabak', 'seblak', 'mi ayam', 'indomie', 'es teh', 'minum', 'food', 'meal', 'snacks', 'eat']),
];

/// Income words → default income category name.
const chatIncomeRules = <CategoryRule>[
  ('Gaji', ['gaji', 'gajian', 'salary', 'thr', 'bonus', 'paycheck', 'wage', 'wages']),
  ('Uang Saku', ['uang saku', 'uang jajan', 'dikasih', 'dikirimin', 'kiriman', 'allowance', 'pocket money']),
  ('Freelance', ['freelance', 'proyek', 'project', 'fee', 'honor', 'komisi', 'commission']),
  ('Bisnis', ['jualan', 'bisnis', 'omzet', 'untung', 'laba', 'penjualan', 'business', 'sales', 'profit']),
  ('Investasi', ['dividen', 'bunga', 'investasi', 'reksadana', 'reksa dana', 'saham', 'kupon', 'dividend', 'interest', 'investment', 'stocks']),
];

/// Words that mark money coming in.
const incomeWords = [
  'pemasukan', 'pendapatan', 'penghasilan', 'income', 'terima', 'diterima', 'dapat', 'dapet',
  'masuk', 'uang masuk', 'transfer masuk',
  'received', 'receive', 'earned', 'got paid',
];
