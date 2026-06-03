# Minimarket Point of Sales Database
## Deskripsi Proyek

Proyek ini merupakan perancangan dan implementasi database untuk sistem Point of Sales (POS) pada minimarket. Database ini dirancang untuk mengelola data produk, kategori, supplier, karyawan, transaksi penjualan, serta laporan penjualan secara terstruktur.

## Teknologi yang Digunakan

- MySQL
- XAMPP
- phpMyAdmin

## Fitur Database

### Tabel

1. tb_category
2. tb_employeer
3. tb_product
4. tb_supplier
5. tb_transaction
6. tb_trans_detail
   
## View

- view_sales_report
- view_period_sales
- view_low_stock_products
- view_detail_transaksi
- view_employee_performance

## Stored Procedure

- proc_add_employee
- proc_add_new_product
- proc_add_to_cart
- proc_new_transactions
- proc_update_stock

## Trigger

- trg_check_stock
- trg_before_insert_tb_employe
- trg_before_update_transactio
- trg_cant_delete_trans_history
- trg_cant_same_name_product

## Struktur Database

Database ini menggunakan konsep relasional dengan hubungan antara tabel kategori, produk, supplier, karyawan, transaksi, dan detail transaksi untuk mendukung proses bisnis minimarket.

## Anggota Kelompok

- Hilwa Annisa
- Briant Abrar Antora
- M. Aufar Maulana Prasetia
