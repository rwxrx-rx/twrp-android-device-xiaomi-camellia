# Perubahan dari tree asli (OrangeFox, prebuilt kernel)

Tree ini adalah hasil modifikasi dari `twrp-android-device-xiaomi-camellia-fox_12.1`
(OrangeFox) agar:
1. Kernel di-build dari source, bukan prebuilt binary.
2. Ditargetkan untuk build **TWRP official** (minimal manifest resmi TeamWin),
   bukan sync manifest OrangeFox.

## 1. BoardConfig.mk
- `TARGET_FORCE_PREBUILT_KERNEL` diubah dari `true` -> `false`.
- Menambahkan branch `else` yang mengisi:
  - `TARGET_KERNEL_SOURCE := kernel/xiaomi/camellia`
  - `TARGET_KERNEL_CONFIG := camellia_user_defconfig`
  - `TARGET_KERNEL_ARCH`, `TARGET_KERNEL_HEADER_ARCH`, `TARGET_KERNEL_CLANG_COMPILE`
  - `BOARD_INCLUDE_DTB_IN_BOOTIMG := true` (dtb otomatis diambil dari hasil build
    kernel, bukan lagi dari `prebuilt/dtb.img`)
- Branch lama (`TARGET_FORCE_PREBUILT_KERNEL := true`) tetap disimpan sebagai
  fallback kalau sewaktu-waktu ingin balik ke prebuilt.
- `OFOX_DONT_WIPE_FBE_METADATA` (variabel khusus OrangeFox) dihapus karena tidak
  dikenali oleh source resmi TWRP.

## 2. vendorsetup.sh
- Semua `export FOX_*` / `export OF_*` (variabel khusus OrangeFox) dihapus.
  Source resmi TWRP tidak membaca variabel ini sama sekali, jadi kalau
  dibiarkan cuma jadi sampah env var.
- Sekarang cuma berisi `add_lunch_combo twrp_camellia-eng`.

## 3. CI: .github/workflows/twrp-official.yml (pengganti orangefox.yml)
- `repo init` memakai manifest resmi TWRP:
  `https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git`
  branch `twrp-12.1` — bukan lagi `orangefox_sync.sh`.
- Menambahkan step clone kernel source ke `kernel/xiaomi/camellia`.
- `lunch twrp_camellia-eng` (bukan `twrp_camellia-eng` lewat OrangeFox tree).

## 4. local_manifest.xml (baru)
Contoh isi untuk ditaruh di `.repo/local_manifests/local_manifest.xml` pada
pohon source resmi TWRP kamu, supaya `repo sync` otomatis menarik device tree
ini + kernel source ke tempat yang benar.

## ⚠️ Yang WAJIB kamu cek sebelum build (tidak bisa saya verifikasi dari sini)
Saya tidak punya akses jaringan untuk clone kernel source
`rwxrx-rx/android_kernel_xiaomi_camellia` secara penuh (747rb+ commit, ukurannya
besar), jadi bagian ini saya set berdasarkan konvensi umum kernel camellia dan
tree resmi crDroid untuk device yang sama — **cek ulang sebelum build**:

- **Nama defconfig**: saya set `camellia_user_defconfig`. Pastikan file ini
  benar-benar ada di `arch/arm64/configs/` pada branch `lineage-23.2` kernel
  tersebut. Kalau tidak ada, ganti `TARGET_KERNEL_CONFIG` sesuai nama yang ada.
- **Toolchain**: kernel 4.14 non-GKI MTK biasanya butuh GCC
  `aarch64-linux-android-4.9` (dan `arm-linux-androideabi-4.9` untuk 32-bit)
  atau clang tertentu untuk `TARGET_KERNEL_CLANG_COMPILE`. Kalau build gagal
  karena toolchain tidak ketemu, tambahkan project toolchain yang sesuai di
  `local_manifest.xml`.
- **`prebuilt/kernel` dan `prebuilt/dtb.img`**: masih ada di tree ini sebagai
  fallback (tidak dipakai selama `TARGET_FORCE_PREBUILT_KERNEL := false`), aman
  dihapus kalau memang tidak mau dipakai lagi.
