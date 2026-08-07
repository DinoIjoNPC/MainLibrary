# EmeraldUI

**Lightweight, adaptive Roblox UI Library untuk semua perangkat.**

> by **Dino** · Doz Y

---

## Instalasi

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/DinoIjoNPC/MainLibrary/refs/heads/main/EmeraldUI"))()
```

> ⚠️ URL tidak pakai ekstensi `.lua`

---

## Membuat Window

```lua
local Window = Library:CreateWindow({
    Title       = "NamaScript",
    Description = "Nama Game",
    Theme       = "Green",
    Icon        = "rbxassetid://136893287430224",
})
```

| Key | Fungsi | Default |
|---|---|---|
| `Title` | Judul window di topbar | `"EmeraldUI"` |
| `Description` | Badge di sebelah kanan judul | `""` (tidak muncul jika kosong) |
| `Theme` | Warna tema | `"Green"` |
| `Icon` | Icon di kiri judul | `"rbxassetid://136893287430224"` |

---

## Membuat Tab

```lua
local Tab = Window:CreateTab({
    Name      = "Main",
    Icon      = "rbxassetid://10723407389",
    Thumbnail = "https://i.pinimg.com/originals/xx.jpg",
})
```

| Key | Fungsi | Default |
|---|---|---|
| `Name` | Nama tab di sidebar | wajib |
| `Icon` | Icon tab | `""` |
| `Thumbnail` | Gambar thumbnail di atas konten tab | `nil` |

---

## Membuat Section / Accordion

```lua
local Section = Tab:AddSection("Nama Section", true)
```

| Parameter | Fungsi |
|---|---|
| `"Nama Section"` | Judul section |
| `true` | Buka saat load (`false` = tutup) |

---

## Toggle

```lua
Section:AddToggle({
    "Nama Toggle",
    "Deskripsi",
    false,
    function(value)
        print(value)
    end
})
```

| Index | Fungsi |
|---|---|
| `1` | Nama toggle |
| `2` | Deskripsi |
| `3` | Default value (`true`/`false`) |
| `4` | Callback, `value` = kondisi saat ini |

---

## Button

```lua
Section:AddButton({
    "Nama Button",
    "Deskripsi",
    "rbxassetid://10723407389",
    function()
        print("Klik!")
    end
})
```

| Index | Fungsi |
|---|---|
| `1` | Nama button |
| `2` | Deskripsi |
| `3` | Icon (kosongkan `""` jika tidak pakai) |
| `4` | Callback |

---

## Slider

```lua
local MySlider = Section:AddSlider({
    "Nama Slider",
    "Deskripsi",
    1,
    0,
    100,
    50,
    function(value)
        print(value)
    end
})
```

| Index | Fungsi |
|---|---|
| `1` | Nama |
| `2` | Deskripsi |
| `3` | Increment (langkah per geser) |
| `4` | Nilai minimum |
| `5` | Nilai maksimum |
| `6` | Nilai default |
| `7` | Callback |

**Set nilai dari luar:**
```lua
MySlider:Set(75)
```

---

## Input

```lua
local MyInput = Section:AddInput({
    "Nama Input",
    "Placeholder...",
    "",
    function(value)
        print(value)
    end
})
```

| Index | Fungsi |
|---|---|
| `1` | Nama |
| `2` | Placeholder teks |
| `3` | Nilai default |
| `4` | Callback (dipanggil saat FocusLost) |

**Set nilai dari luar:**
```lua
MyInput:Set("teks baru")
```

---

## Dropdown

```lua
local MyDrop = Section:AddDropdown({
    "Nama Dropdown",
    "Deskripsi",
    false,
    {"Opsi A", "Opsi B", "Opsi C"},
    {},
    function(value)
        print(value[1])
    end
})
```

| Index | Fungsi |
|---|---|
| `1` | Nama |
| `2` | Deskripsi |
| `3` | Multi-select (`true`/`false`) |
| `4` | Daftar opsi |
| `5` | Default selected (tabel) |
| `6` | Callback, `value` = tabel opsi terpilih |

**Set / refresh dari luar:**
```lua
MyDrop:Set({"Opsi A"})
MyDrop:Refresh({"Opsi Baru 1", "Opsi Baru 2"}, {})
MyDrop:AddOption("Opsi D")
MyDrop:Clear()
```

---

## Paragraph

```lua
Section:AddParagraph({
    "Judul",
    "Isi teks paragraph di sini."
})
```

---

## Separator

```lua
Section:AddSeperator({ "Label Separator" })
```

---

## Line

```lua
Section:AddLine()
```

---

## Notification

```lua
Library:SetNotification({
    "Judul",
    "Subjudul",
    "Isi pesan notifikasi.",
    nil,
    0.4,
    5,
})
```

| Index | Fungsi |
|---|---|
| `1` | Judul notifikasi |
| `2` | Subjudul (warna accent) |
| `3` | Isi pesan |
| `4` | Tidak dipakai, isi `nil` |
| `5` | Durasi animasi (detik) |
| `6` | Waktu sebelum auto-close (detik) |

**Notifikasi saat execute:**
```lua
Library:SetNotification({
    "EmeraldUI",
    "Loaded!",
    "Script berhasil dijalankan.",
    nil, 0.4, 4,
})
```

**Notifikasi numpuk** → otomatis naik ke atas secara smooth.

---

## Theme Switcher

**Set tema saat buat window:**
```lua
local Window = Library:CreateWindow({
    Title = "Script",
    Theme = "Purple",
})
```

**Ganti tema saat runtime:**
```lua
Window:SetTheme("Blue")
```

| Nama | Warna |
|---|---|
| `"Green"` | Hijau ← Default |
| `"Blue"` | Biru |
| `"Purple"` | Ungu |
| `"Red"` | Merah |
| `"Gold"` | Emas |
| `"Cyan"` | Cyan |
| `"Pink"` | Pink |
| `"Orange"` | Orange |

---

## Thumbnail

**Thumbnail global (semua tab):**
```lua
local Window = Library:CreateWindow({
    Title     = "Script",
    Thumbnail = "https://link-gambar.com/img.jpg",
})
```

**Thumbnail per tab:**
```lua
local Tab = Window:CreateTab({
    Name      = "Main",
    Thumbnail = "https://link-gambar.com/img.jpg",
})
```

**Ganti thumbnail saat runtime:**
```lua
Window:SetThumbnail("https://link-gambar.com/img.jpg")
Window:SetTabThumbnail(0, "https://link-gambar.com/img.jpg")
```

> ℹ️ Pakai direct link ke file gambar, bukan halaman web. Di Pinterest: klik kanan gambar → Copy image address.

---

## Search Bar Global

Tidak perlu setup apapun. Search bar otomatis muncul di atas daftar tab dan memfilter tab secara realtime saat diketik.

---

## Window Icon

```lua
local Window = Library:CreateWindow({
    Title = "Script",
    Icon  = "rbxassetid://10723407389",
})
```

Jika tidak diisi, otomatis pakai icon default.

---

## Minimize & Close

- **`—`** → Minimize, GUI hilang tapi script tetap jalan. Muncul tombol kecil untuk restore.
- **`X`** → Muncul dialog konfirmasi. Pilih **Close** untuk matikan semua, pilih **Cancel** untuk batal.

---

## Contoh Script Lengkap

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/DinoIjoNPC/MainLibrary/refs/heads/main/EmeraldUI"))()

local Window = Library:CreateWindow({
    Title       = "MyScript",
    Description = "Game Name",
    Theme       = "Green",
    Icon        = "rbxassetid://10723407389",
})

Library:SetNotification({
    "MyScript", "Loaded!", "Script aktif.", nil, 0.4, 4,
})

local Tab = Window:CreateTab({ Name = "Main", Icon = "rbxassetid://10723407389" })
local Sec = Tab:AddSection("Fitur", true)

Sec:AddToggle({
    "God Mode", "Tidak bisa mati", false,
    function(v)
        -- kode di sini
    end
})

Sec:AddSlider({
    "Speed", "Kecepatan jalan", 1, 16, 500, 16,
    function(v)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = v
        end
    end
})

Sec:AddButton({
    "Rejoin", "Masuk server baru", "",
    function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end
})
```

---

## Changelog

### v4.0.0 — Latest
- ✅ Window Icon di topbar
- ✅ Description Badge modern (border + rounded)
- ✅ Theme Switcher — 8 preset gradient
- ✅ `SetTheme()` dari script pemanggil
- ✅ Tab Thumbnail dari URL apapun
- ✅ Global Search Bar di atas sidebar
- ✅ Notification stack naik ke atas saat numpuk
- ✅ Button icon conditional (tidak buat frame kosong)
- ✅ Search icon emoji (tidak bergantung asset ID)
- ✅ OpenCloseBtn dikembalikan ke ImageButton
- ✅ `GetGuiParent()` helper berlapis untuk semua executor

### v3.0.0
- ✅ Toggle circle fix
- ✅ Slider smooth di HP
- ✅ Close confirmation dialog
- ✅ DPI Scaling HP diperbaiki

### v2.0.0
- ✅ `Opt.OptionText` crash fix
- ✅ ZIndex 0 fix
- ✅ shadowHolder posisi fix
- ✅ `Custom:Create` order fix

### v1.0.0
- 🚀 Initial release

---

## Requirements

| Executor | Support |
|---|---|
| Delta | ✅ |
| Arceus X | ✅ |
| Fluxus | ✅ |
| Hydrogen | ✅ |
| Solara | ✅ |
| Synapse X | ✅ |

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
