# Ethiopian Bible (Offline Multilingual)

A Flutter Bible reader focused on Ethiopian languages and offline use. Translation packs are converted into a unified JSON schema, installed into local SQLite storage, and readable without internet.

## Coverage

**46 translation packs · 24 languages/script traditions**

Most modern Ethiopian/English packs are Protestant 66-book base. Expanded-canon and ancient editions are also included:

- **Septuagint (LXX)** Greek + Brenton English
- **Biblical Hebrew** (Westminster Leningrad Codex, RTL)
- **Greek NT**: Byzantine, Textus Receptus, SBLGNT
- **Latin Vulgate** (Clementine), including deuterocanon
- WEB/KJV packs also include available deuterocanonical books

### Default offline Bibles

These install automatically on first launch:

1. **Afaan Oromoo** — Open New Oromo Contemporary Version (Biblica, CC BY-SA 4.0)
2. **አማርኛ** — Full Amharic Bible pack
3. **English** — World English Bible (Public Domain; includes deuterocanon where present)

### Installable languages

Afaan Oromoo (multiple dialects/editions), Amharic, English, Tigrinya, Somali, Wolaytta, Sidamo, Hadiyya, Nuer, Dawro, Gamo, Gofa, Maale, Alaba-K'abeena, Baiso, Borna, Gayil, Hamer-Banna, Melo, Oyda, Yemsa, Ancient Greek, Biblical Hebrew, Latin.

Ge'ez classical Ethiopian Scripture is not yet bundled: no clean redistributable complete Ge'ez USFX pack was available from eBible under a clear redistribution license.

## Features

- Fully offline reading after install
- Language/translation switching
- Search, bookmarks, highlights
- Dark/light themes and adjustable font size
- Structured packs with books, chapters, verses, script, and license metadata

## Data pipeline

```bash
python3 scripts/build_bible_packs.py
```

Primary sources:

- [eBible.org](https://ebible.org/) Ethiopian / Somali / English USFX downloads
- [magna25/amharic-bible-json](https://github.com/magna25/amharic-bible-json)
- [wuletawwonte/ethiopian-bibles](https://github.com/wuletawwonte/ethiopian-bibles) for languages missing from eBible

Output:

```
assets/bible/
  catalog.json
  bundled/*.json.gz
  optional/*.json.gz
```

## Licensing notes

- Prefer CC BY-SA and Public Domain texts
- CC BY-NC-ND editions are non-commercial with attribution
- Some Amharic/community packs require publisher verification before commercial redistribution
- Copyrighted commercial English editions (NIV/ESV/etc.) are excluded

## Run

```bash
flutter pub get
flutter run
```
