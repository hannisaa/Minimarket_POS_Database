-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 03 Jun 2026 pada 06.35
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_minimarket`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_employee` (IN `p_employeer_name` VARCHAR(255), IN `p_gender` CHAR(1), IN `p_place_of_birth` VARCHAR(50), IN `p_date_of_birth` DATE, IN `p_address` VARCHAR(255))   BEGIN
    -- Menambahkan data karyawan baru, abaikan jika ada duplikat
    INSERT IGNORE INTO tb_employeer (employeer_name, gender, place_of_birth, date_of_birth, address)
    VALUES (p_employeer_name, p_gender, p_place_of_birth, p_date_of_birth, p_address);

    -- Menampilkan pesan sukses
    -- Perhatikan bahwa pesan ini akan selalu muncul, 
    -- bahkan jika data gagal ditambahkan karena duplikat
    SELECT 'Data karyawan berhasil ditambahkan.' AS message;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_new_product` (IN `p_id_product` INT, IN `p_product_name` VARCHAR(255), IN `p_id_category` INT, IN `p_stock` INT, IN `p_prod_price` DECIMAL(10,2), IN `p_id_supplier` INT)   BEGIN
    -- Insert data produk baru 
    INSERT INTO tb_product (id_product, product_name, id_category, stock, prod_price, id_supplier) 
    VALUES (p_id_product, p_product_name, p_id_category, p_stock, p_prod_price, p_id_supplier);

    -- Menampilkan pesan sukses dengan ID produk (opsional)
    -- SELECT LAST_INSERT_ID(); 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_to_cart` (IN `p_id_product` INT, IN `p_quantity` INT)   BEGIN
    INSERT INTO temp_cart (id_product, quantity)
    VALUES (p_id_product, p_quantity);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `new_transactions` (IN `p_id_employeer` INT, IN `p_trans_date` DATE, IN `p_trans_time` TIME)   BEGIN
    -- Memasukkan data ke tabel tb_transaction dengan total harga dari temp_cart
    INSERT INTO tb_transaction (id_employeer, trans_date, trans_time, price)
    SELECT p_id_employeer, p_trans_date, p_trans_time, SUM(tp.quantity * pr.prod_price)
    FROM temp_cart tp
    JOIN tb_product pr ON tp.id_product = pr.id_product;

    -- Mendapatkan id_transaction yang baru saja ditambahkan
    SET @last_id = LAST_INSERT_ID();

    -- Memasukkan data detail transaksi ke tb_trans_detail
    INSERT INTO tb_trans_detail (id_transaction, id_product, quantity, total_price)
    SELECT @last_id, tp.id_product, tp.quantity, (tp.quantity * pr.prod_price)
    FROM temp_cart tp
    JOIN tb_product pr ON tp.id_product = pr.id_product;

    -- Mengurangi stok produk di tb_product
    UPDATE tb_product pr
    JOIN temp_cart tc ON pr.id_product = tc.id_product
    SET pr.stock = pr.stock - tc.quantity;

    -- Menghapus data dari temp_cart
    DELETE FROM temp_cart;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_stock` (IN `p_id_product` INT, IN `jumlah_perubahan` INT)   BEGIN
    -- Mengecek apakah jumlah_perubahan positif (menambah) atau negatif (mengurangi)
    IF jumlah_perubahan > 0 THEN
        UPDATE tb_product 
        SET stock = stock + jumlah_perubahan 
        WHERE id_product = p_id_product; -- Perbaikan pada klausa WHERE
    ELSE
        -- Memastikan stok tidak menjadi negatif
        UPDATE tb_product 
        SET stock = GREATEST(0, stock + jumlah_perubahan) 
        WHERE id_product = p_id_product; -- Perbaikan pada klausa WHERE
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_category`
--

CREATE TABLE `tb_category` (
  `id_category` int(11) NOT NULL,
  `category_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_category`
--

INSERT INTO `tb_category` (`id_category`, `category_name`) VALUES
(1, 'Drink'),
(2, 'Snack');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_employeer`
--

CREATE TABLE `tb_employeer` (
  `id_employeer` int(11) NOT NULL,
  `employeer_name` varchar(255) NOT NULL,
  `gender` char(1) NOT NULL,
  `place_of_birth` varchar(50) NOT NULL,
  `date_of_birth` date NOT NULL,
  `address` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_employeer`
--

INSERT INTO `tb_employeer` (`id_employeer`, `employeer_name`, `gender`, `place_of_birth`, `date_of_birth`, `address`) VALUES
(1, 'Andra', 'M', 'Jakarta', '1994-05-21', 'Jl. Pattimura No. 23'),
(2, 'Bisma', 'F', 'Semarang', '1998-03-17', 'Jl. Kebon Jeruk No. 7'),
(3, 'Nayla', 'F', 'Yogyakarta', '1997-09-19', 'Jl. Anggrek No. 8B'),
(4, 'Paul', 'M', 'Bali', '1987-03-30', 'Jl. Moh. Yamin No. 56'),
(5, 'Ridho', 'M', 'Jakarta', '1999-02-28', 'Jl. Bougenvile No. 12A'),
(6, 'Zaki', 'M', 'Ambon', '1995-11-09', 'Jl. H. Juanda No. 35'),
(7, 'zara', 'F', 'Kalimantan', '1999-01-01', 'Jl.Kober No. 1');

--
-- Trigger `tb_employeer`
--
DELIMITER $$
CREATE TRIGGER `trg_before_insert_tb_employeer` BEFORE INSERT ON `tb_employeer` FOR EACH ROW BEGIN
    -- Memeriksa apakah nama karyawan sudah ada
    DECLARE jumlah_karyawan INT;
    SELECT COUNT(*) INTO jumlah_karyawan FROM tb_employeer WHERE employeer_name = NEW.employeer_name;

    IF jumlah_karyawan > 0 THEN
        -- Menampilkan pesan error jika nama karyawan sudah ada
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Nama karyawan sudah ada dalam database.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_product`
--

CREATE TABLE `tb_product` (
  `id_product` int(11) NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `id_category` int(11) NOT NULL,
  `stock` int(11) NOT NULL,
  `prod_price` decimal(10,2) NOT NULL,
  `id_supplier` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_product`
--

INSERT INTO `tb_product` (`id_product`, `product_name`, `id_category`, `stock`, `prod_price`, `id_supplier`) VALUES
(1, 'Aqua', 1, 50, 5000.00, 1),
(2, 'Sosro Teh Botol', 1, 47, 4500.00, 1),
(3, 'UltraMilk', 1, 3, 6500.00, 1),
(4, 'KokoKrunch', 2, 64, 13000.00, 1),
(5, 'Lays', 2, 31, 12000.00, 2),
(6, 'Sari Gandum', 2, 59, 9900.00, 2),
(7, 'Kit Kat', 2, 1, 18000.00, 2),
(8, 'SilverQueen', 2, 57, 18500.00, 2),
(9, 'Chitato', 2, 69, 15000.00, 2),
(1056, 'Cimory', 1, 76, 13000.00, 1);

--
-- Trigger `tb_product`
--
DELIMITER $$
CREATE TRIGGER `trg_cant_same_name_product` BEFORE INSERT ON `tb_product` FOR EACH ROW BEGIN
    IF EXISTS (SELECT 1 FROM tb_product WHERE product_name = NEW.product_name) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Produk dengan nama tersebut sudah ada.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_check_stock` AFTER UPDATE ON `tb_product` FOR EACH ROW BEGIN
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stok produk tidak mencukupi';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_supplier`
--

CREATE TABLE `tb_supplier` (
  `id_supplier` int(11) NOT NULL,
  `supplier_name` varchar(255) NOT NULL,
  `supplier_address` varchar(255) NOT NULL,
  `contact_person` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_supplier`
--

INSERT INTO `tb_supplier` (`id_supplier`, `supplier_name`, `supplier_address`, `contact_person`) VALUES
(1, 'PT Mitra Logistik', 'Kawasan Industri Cikarang, Jl. Industri No. 10', '082156789012'),
(2, 'PT Sumber Abadi', 'Jl. Raya Merdeka No. 45', '081234567890');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_transaction`
--

CREATE TABLE `tb_transaction` (
  `id_transaction` int(11) NOT NULL,
  `id_employeer` int(11) NOT NULL,
  `trans_date` date NOT NULL,
  `trans_time` time NOT NULL,
  `price` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_transaction`
--

INSERT INTO `tb_transaction` (`id_transaction`, `id_employeer`, `trans_date`, `trans_time`, `price`) VALUES
(1, 1, '2024-12-31', '10:21:00', 9000.00),
(2, 1, '2024-12-31', '11:40:00', 20000.00),
(3, 2, '2024-12-31', '11:40:00', 20000.00),
(4, 4, '2024-12-31', '00:00:12', 30000.00),
(5, 1, '2024-12-31', '00:00:12', 55000.00),
(6, 2, '2024-12-31', '10:28:00', 75000.00),
(7, 1, '2024-12-31', '00:00:12', 50000.00),
(8, 1, '2024-12-31', '00:00:12', 50000.00),
(9, 1, '2024-12-31', '00:00:12', 50000.00),
(10, 1, '2024-12-31', '00:00:12', 50000.00),
(11, 1, '2024-12-31', '00:00:12', 50000.00),
(12, 1, '2024-12-31', '00:00:12', 50000.00),
(13, 1, '2024-12-31', '00:00:12', 50000.00),
(14, 1, '2024-12-31', '00:00:12', 50000.00),
(15, 1, '2024-12-31', '00:00:12', 50000.00),
(17, 1, '2024-12-31', '00:00:12', 50000.00),
(18, 1, '0000-00-00', '10:48:00', 100000.00),
(19, 1, '2024-12-31', '00:00:12', 140000.00),
(20, 2, '2024-12-31', '10:00:00', 55000.00),
(21, 2, '2024-12-31', '10:00:00', 55000.00),
(22, 2, '2024-12-31', '10:00:00', 55000.00),
(23, 2, '2024-12-31', '10:00:00', 55000.00),
(24, 5, '2024-12-31', '17:57:33', 65000.00);

--
-- Trigger `tb_transaction`
--
DELIMITER $$
CREATE TRIGGER `trg_before_update_transaction` BEFORE UPDATE ON `tb_transaction` FOR EACH ROW BEGIN
    IF EXISTS (SELECT 1 FROM tb_trans_detail WHERE id_transaction = OLD.id_transaction) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tidak bisa mengubah transaksi yang sudah memiliki detail transaksi.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_cant_detele_trans_history` BEFORE DELETE ON `tb_transaction` FOR EACH ROW BEGIN
    IF EXISTS (SELECT 1 FROM tb_trans_detail WHERE id_transaction = OLD.id_transaction) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tidak bisa menghapus transaksi yang sudah memiliki detail transaksi.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_trans_detail`
--

CREATE TABLE `tb_trans_detail` (
  `id_trans_detail` int(11) NOT NULL,
  `id_transaction` int(11) NOT NULL,
  `id_product` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `total_price` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_trans_detail`
--

INSERT INTO `tb_trans_detail` (`id_trans_detail`, `id_transaction`, `id_product`, `quantity`, `total_price`) VALUES
(1, 1, 2, 2, 9000.00),
(3, 4, 9, 2, 30000.00),
(4, 5, 1, 2, 10000.00),
(5, 5, 9, 3, 45000.00),
(7, 6, 1, 2, 10000.00),
(8, 6, 3, 10, 65000.00),
(10, 7, 1, 10, 50000.00),
(15, 13, 1, 10, 50000.00),
(18, 17, 1, 10, 50000.00),
(19, 18, 1, 20, 100000.00),
(20, 19, 1, 10, 50000.00),
(21, 19, 2, 20, 90000.00),
(22, 20, 1, 11, 55000.00),
(23, 21, 1, 11, 55000.00),
(24, 22, 1, 11, 55000.00),
(25, 23, 1, 11, 55000.00);

-- --------------------------------------------------------

--
-- Struktur dari tabel `temp_cart`
--

CREATE TABLE `temp_cart` (
  `id_cart` int(11) NOT NULL,
  `id_product` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `temp_cart`
--

INSERT INTO `temp_cart` (`id_cart`, `id_product`, `quantity`) VALUES
(12, 1, 2);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `view_laporan_penjualan`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `view_laporan_penjualan` (
`id_transaction` int(11)
,`trans_date` date
,`cashier` varchar(255)
,`produk_terjual` mediumtext
,`total_jumlah_barang` decimal(32,0)
,`total_harga` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `view_penjualan_per_periode`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `view_penjualan_per_periode` (
`trans_date` date
,`total_penjualan` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `view_performa_karyawan`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `view_performa_karyawan` (
`id_employeer` int(11)
,`employeer_name` varchar(255)
,`total_penjualan` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `view_produk_stok_rendah`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `view_produk_stok_rendah` (
`id_product` int(11)
,`product_name` varchar(255)
,`category_name` varchar(255)
,`stock` int(11)
);

-- --------------------------------------------------------

--
-- Struktur untuk view `view_laporan_penjualan`
--
DROP TABLE IF EXISTS `view_laporan_penjualan`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_laporan_penjualan`  AS SELECT `t`.`id_transaction` AS `id_transaction`, `t`.`trans_date` AS `trans_date`, `e`.`employeer_name` AS `cashier`, group_concat(`p`.`product_name` separator ', ') AS `produk_terjual`, sum(`td`.`quantity`) AS `total_jumlah_barang`, sum(`td`.`total_price`) AS `total_harga` FROM (((`tb_transaction` `t` join `tb_employeer` `e` on(`t`.`id_employeer` = `e`.`id_employeer`)) join `tb_trans_detail` `td` on(`t`.`id_transaction` = `td`.`id_transaction`)) join `tb_product` `p` on(`td`.`id_product` = `p`.`id_product`)) GROUP BY `t`.`id_transaction`, `t`.`trans_date`, `e`.`employeer_name` ;

-- --------------------------------------------------------

--
-- Struktur untuk view `view_penjualan_per_periode`
--
DROP TABLE IF EXISTS `view_penjualan_per_periode`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_penjualan_per_periode`  AS SELECT `t`.`trans_date` AS `trans_date`, sum(`t`.`price`) AS `total_penjualan` FROM `tb_transaction` AS `t` GROUP BY `t`.`trans_date` ;

-- --------------------------------------------------------

--
-- Struktur untuk view `view_performa_karyawan`
--
DROP TABLE IF EXISTS `view_performa_karyawan`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_performa_karyawan`  AS SELECT `e`.`id_employeer` AS `id_employeer`, `e`.`employeer_name` AS `employeer_name`, sum(`t`.`price`) AS `total_penjualan` FROM (`tb_employeer` `e` join `tb_transaction` `t` on(`e`.`id_employeer` = `t`.`id_employeer`)) GROUP BY `e`.`id_employeer`, `e`.`employeer_name` ;

-- --------------------------------------------------------

--
-- Struktur untuk view `view_produk_stok_rendah`
--
DROP TABLE IF EXISTS `view_produk_stok_rendah`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_produk_stok_rendah`  AS SELECT `p`.`id_product` AS `id_product`, `p`.`product_name` AS `product_name`, `c`.`category_name` AS `category_name`, `p`.`stock` AS `stock` FROM (`tb_product` `p` join `tb_category` `c` on(`p`.`id_category` = `c`.`id_category`)) WHERE `p`.`stock` < 10 ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `tb_category`
--
ALTER TABLE `tb_category`
  ADD PRIMARY KEY (`id_category`);

--
-- Indeks untuk tabel `tb_employeer`
--
ALTER TABLE `tb_employeer`
  ADD PRIMARY KEY (`id_employeer`);

--
-- Indeks untuk tabel `tb_product`
--
ALTER TABLE `tb_product`
  ADD PRIMARY KEY (`id_product`),
  ADD KEY `id_category` (`id_category`),
  ADD KEY `id_supplier` (`id_supplier`);

--
-- Indeks untuk tabel `tb_supplier`
--
ALTER TABLE `tb_supplier`
  ADD PRIMARY KEY (`id_supplier`);

--
-- Indeks untuk tabel `tb_transaction`
--
ALTER TABLE `tb_transaction`
  ADD PRIMARY KEY (`id_transaction`),
  ADD KEY `id_employeer` (`id_employeer`);

--
-- Indeks untuk tabel `tb_trans_detail`
--
ALTER TABLE `tb_trans_detail`
  ADD PRIMARY KEY (`id_trans_detail`),
  ADD KEY `id_product` (`id_product`),
  ADD KEY `id_transaction` (`id_transaction`);

--
-- Indeks untuk tabel `temp_cart`
--
ALTER TABLE `temp_cart`
  ADD PRIMARY KEY (`id_cart`),
  ADD KEY `id_product` (`id_product`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `tb_category`
--
ALTER TABLE `tb_category`
  MODIFY `id_category` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `tb_employeer`
--
ALTER TABLE `tb_employeer`
  MODIFY `id_employeer` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT untuk tabel `tb_supplier`
--
ALTER TABLE `tb_supplier`
  MODIFY `id_supplier` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `tb_transaction`
--
ALTER TABLE `tb_transaction`
  MODIFY `id_transaction` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT untuk tabel `tb_trans_detail`
--
ALTER TABLE `tb_trans_detail`
  MODIFY `id_trans_detail` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT untuk tabel `temp_cart`
--
ALTER TABLE `temp_cart`
  MODIFY `id_cart` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `tb_product`
--
ALTER TABLE `tb_product`
  ADD CONSTRAINT `tb_product_ibfk_1` FOREIGN KEY (`id_supplier`) REFERENCES `tb_supplier` (`id_supplier`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `tb_product_ibfk_2` FOREIGN KEY (`id_category`) REFERENCES `tb_category` (`id_category`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `tb_transaction`
--
ALTER TABLE `tb_transaction`
  ADD CONSTRAINT `tb_transaction_ibfk_1` FOREIGN KEY (`id_employeer`) REFERENCES `tb_employeer` (`id_employeer`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `tb_trans_detail`
--
ALTER TABLE `tb_trans_detail`
  ADD CONSTRAINT `tb_trans_detail_ibfk_2` FOREIGN KEY (`id_product`) REFERENCES `tb_product` (`id_product`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `tb_trans_detail_ibfk_3` FOREIGN KEY (`id_transaction`) REFERENCES `tb_transaction` (`id_transaction`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `temp_cart`
--
ALTER TABLE `temp_cart`
  ADD CONSTRAINT `temp_cart_ibfk_1` FOREIGN KEY (`id_product`) REFERENCES `tb_product` (`id_product`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
