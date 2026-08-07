# EmeraldUI
**A lightweight, adaptive Roblox UI Library built for performance and consistency across all devices.**

> Developed by **Dino** · Brand: **Doz Y / Violence District**

---

## Features

| Feature | Description |
|---|---|
| 🎨 **Theme Switcher** | 8 preset warna ikonik dengan gradient, bisa diganti dari script pemanggil |
| 🖼️ **Tab Thumbnail** | Load gambar dari URL apapun sebagai thumbnail per tab |
| 🔍 **Global Search Bar** | Search tab secara realtime, ada di atas sidebar |
| 📱 **Adaptive DPI Scaling** | GUI otomatis proporsional di HP, Tablet, dan PC |
| 🪟 **Draggable Window** | Window bisa dipindah bebas |
| 🔒 **Close Confirmation** | Dialog konfirmasi sebelum menutup script |
| ⚡ **Smooth Animations** | Semua transisi pakai TweenService |
| 📦 **Accordion Section** | Section bisa dibuka/tutup |
| 🔽 **Searchable Dropdown** | Dropdown dengan search bar bawaan |
| 🔔 **Notification Popup** | Notifikasi pojok layar dengan auto-close |
| 🗂️ **Multi-Tab + Icon** | Sidebar multi tab dengan icon |

---

## Installation

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/DinoIjoNPC/MainLibrary/refs/heads/main/EmeraldUI"))()
```

> ⚠️ Tidak ada ekstensi `.lua` pada URL.

---

## Quick Start

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/DinoIjoNPC/MainLibrary/refs/heads/main/EmeraldUI"))()

local Window = Library:CreateWindow({
    Title       = "MyScript",
    Description = "Game Name",
    Theme       = "Green",      -- Default tema
    Thumbnail   = "",           -- URL thumbnail global (opsional)
})

local Tab = Window:CreateTab({
    Name      = "Main",
    Icon      = "rbxassetid://10723407389",
    Thumbnail = "",   -- URL thumbnail per tab (opsional, override global)
})

local Section = Tab:AddSection("Features", true)

Section:AddToggle({
    "God Mode", "Toggle invincibility", false,
    function(v) print("GodMode:", v) end
})
```

---

## Theme Switcher

### Preset yang tersedia

| Nama | Warna Accent |
|---|---|
| `"Green"` | Hijau `RGB(0,200,100)` ← Default |
| `"Blue"` | Biru `RGB(0,140,255)` |
| `"Purple"` | Ungu `RGB(160,60,255)` |
| `"Red"` | Merah `RGB(255,50,80)` |
| `"Gold"` | Emas `RGB(255,190,0)` |
| `"Cyan"` | Cyan `RGB(0,220,220)` |
| `"Pink"` | Pink `RGB(255,80,180)` |
| `"Orange"` | Orange `RGB(255,130,0)` |

### Set dari script pemanggil

```lua
-- Set saat CreateWindow
local Window = Library:CreateWindow({
    Title = "MyScript",
    Theme = "Purple",   -- ganti tema di sini
})

-- Set setelah window dibuat (runtime)
Window:SetTheme("Blue")
Window:SetTheme("Gold")
```

---

## Tab Thumbnail

Load gambar dari URL apapun sebagai thumbnail di bagian atas konten tab.

```lua
-- Thumbnail global (semua tab pakai ini kalau tidak ada per-tab)
local Window = Library:CreateWindow({
    Title     = "MyScript",
    Thumbnail = "https://i.pinimg.com/originals/xx/xx/xx.jpg",
})

-- Thumbnail per tab (override global)
local Tab = Window:CreateTab({
    Name      = "Main",
    Icon      = "rbxassetid://10723407389",
    Thumbnail = "https://i.pinimg.com/originals/xx/xx/xx.jpg",
})

-- Set thumbnail runtime dari script
Window:SetThumbnail("https://...")           -- ganti global
Window:SetTabThumbnail(0, "https://...")     -- ganti tab index 0
```

> ℹ️ Thumbnail support semua URL yang mengembalikan gambar (PNG/JPG/WEBP). Tidak ada whitelist domain.

---

## Global Search Bar

Search bar otomatis muncul di atas daftar tab sidebar. Mengetik di sana akan memfilter tab secara realtime. Tidak perlu setup apapun dari script pemanggil.

---

## API Reference

### `Library:CreateWindow(config)`

| Key | Type | Default | Description |
|---|---|---|---|
| `Title` | string | `"EmeraldUI"` | Judul window |
| `Description` | string | `""` | Subjudul |
| `Theme` | string | `"Green"` | Preset tema warna |
| `Thumbnail` | string | `nil` | URL gambar thumbnail global |

---

### `Window:CreateTab(config)`

| Key | Type | Description |
|---|---|---|
| `Name` | string | Nama tab |
| `Icon` | string | Asset ID icon |
| `Thumbnail` | string | URL thumbnail khusus tab ini |

---

### `Window:SetTheme(presetName)`
Ganti tema runtime. `presetName` harus salah satu dari 8 preset.

### `Window:SetThumbnail(url)`
Ganti thumbnail global runtime.

### `Window:SetTabThumbnail(tabIndex, url)`
Ganti thumbnail tab tertentu. Index mulai dari `0`.

---

### `Tab:AddSection(title, open)`

| Parameter | Type | Description |
|---|---|---|
| `title` | string | Judul section |
| `open` | boolean | `true` = buka, `false` = tutup saat load |

---

### Components

#### `Section:AddToggle(config)`
```lua
Section:AddToggle({ "Title", "Description", false, function(v) end })
```

#### `Section:AddButton(config)`
```lua
Section:AddButton({ "Title", "Description", "rbxassetid://...", function() end })
```

#### `Section:AddSlider(config)`
```lua
Section:AddSlider({ "Title", "Description", 1, 0, 100, 50, function(v) end })
--                                           ^inc ^min ^max ^default
```

#### `Section:AddInput(config)`
```lua
Section:AddInput({ "Title", "Placeholder", "default", function(v) end })
```

#### `Section:AddDropdown(config)`
```lua
Section:AddDropdown({ "Title", "Description", false, {"A","B","C"}, {}, function(v) end })
--                                             ^multi                ^default selected
```

#### `Section:AddParagraph(config)`
```lua
Section:AddParagraph({ "Title", "Content text" })
```

#### `Section:AddSeperator(config)`
```lua
Section:AddSeperator({ "Label" })
```

#### `Section:AddLine()`
```lua
Section:AddLine()
```

---

### `Library:SetNotification(config)`

```lua
Library:SetNotification({
    "EmeraldUI",
    "Success",
    "Action completed.",
    nil,
    0.5,   -- tween time
    5,     -- auto-close delay (detik)
})
```

---

## Changelog

### v4.0.0 — Latest
- ✅ Theme Switcher (8 preset gradient ikonik)
- ✅ `SetTheme()` dari script pemanggil
- ✅ Tab Thumbnail — load gambar dari URL apapun
- ✅ `SetThumbnail()` dan `SetTabThumbnail()` runtime
- ✅ Global Search Bar di atas sidebar tab

### v3.0.0
- ✅ Toggle circle fix (hilang saat ON)
- ✅ Slider smooth di HP
- ✅ Close confirmation dialog
- ✅ DPI Scaling HP diperbaiki

### v2.0.0
- ✅ `Opt.OptionText` crash fix
- ✅ ZIndex 0 fix
- ✅ shadowHolder posisi fix
- ✅ Custom:Create order fix

### v1.0.0
- 🚀 Initial release

---

## Notes

> **Important:** File di GitHub tidak menggunakan ekstensi. URL harus diakhiri `/EmeraldUI` tanpa `.lua`.

> **Important:** Thumbnail menggunakan `ImageLabel.Image` — URL harus direct link ke file gambar, bukan halaman web. Contoh Pinterest: klik kanan gambar → "Copy image address".

> **Warning:** Penggunaan library ini sepenuhnya tanggung jawab pengguna.

---

## License

```
MIT License — Free to use, modify, and distribute.
Credit appreciated but not required.
```

---

<div align="center">
  <b>EmeraldUI</b> · Made with 💚 by Dino · Doz Y / Violence District
</div>
