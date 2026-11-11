#!/usr/bin/env python3
"""Convert verified Bible sources into unified JSON packs for the Flutter app."""

from __future__ import annotations

import gzip
import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = Path("/tmp/bible_sources")
ETH = SRC / "ethiopia_usfx"
OUT_BUNDLED = ROOT / "assets" / "bible" / "bundled"
OUT_OPTIONAL = ROOT / "assets" / "bible" / "optional"
OUT_CATALOG = ROOT / "assets" / "bible" / "catalog.json"

CANON = [
    ("GEN", "Genesis", "old"),
    ("EXO", "Exodus", "old"),
    ("LEV", "Leviticus", "old"),
    ("NUM", "Numbers", "old"),
    ("DEU", "Deuteronomy", "old"),
    ("JOS", "Joshua", "old"),
    ("JDG", "Judges", "old"),
    ("RUT", "Ruth", "old"),
    ("1SA", "1 Samuel", "old"),
    ("2SA", "2 Samuel", "old"),
    ("1KI", "1 Kings", "old"),
    ("2KI", "2 Kings", "old"),
    ("1CH", "1 Chronicles", "old"),
    ("2CH", "2 Chronicles", "old"),
    ("EZR", "Ezra", "old"),
    ("NEH", "Nehemiah", "old"),
    ("EST", "Esther", "old"),
    ("JOB", "Job", "old"),
    ("PSA", "Psalms", "old"),
    ("PRO", "Proverbs", "old"),
    ("ECC", "Ecclesiastes", "old"),
    ("SNG", "Song of Solomon", "old"),
    ("ISA", "Isaiah", "old"),
    ("JER", "Jeremiah", "old"),
    ("LAM", "Lamentations", "old"),
    ("EZK", "Ezekiel", "old"),
    ("DAN", "Daniel", "old"),
    ("HOS", "Hosea", "old"),
    ("JOL", "Joel", "old"),
    ("AMO", "Amos", "old"),
    ("OBA", "Obadiah", "old"),
    ("JON", "Jonah", "old"),
    ("MIC", "Micah", "old"),
    ("NAM", "Nahum", "old"),
    ("HAB", "Habakkuk", "old"),
    ("ZEP", "Zephaniah", "old"),
    ("HAG", "Haggai", "old"),
    ("ZEC", "Zechariah", "old"),
    ("MAL", "Malachi", "old"),
    # Deuterocanonical / Apocrypha (Septuagint, Vulgate, Orthodox canons)
    ("TOB", "Tobit", "deutero"),
    ("JDT", "Judith", "deutero"),
    ("ESG", "Greek Esther", "deutero"),
    ("WIS", "Wisdom", "deutero"),
    ("SIR", "Sirach", "deutero"),
    ("BAR", "Baruch", "deutero"),
    ("LJE", "Letter of Jeremiah", "deutero"),
    ("S3Y", "Prayer of Azariah", "deutero"),
    ("SUS", "Susanna", "deutero"),
    ("BEL", "Bel and the Dragon", "deutero"),
    ("1MA", "1 Maccabees", "deutero"),
    ("2MA", "2 Maccabees", "deutero"),
    ("3MA", "3 Maccabees", "deutero"),
    ("4MA", "4 Maccabees", "deutero"),
    ("1ES", "1 Esdras", "deutero"),
    ("2ES", "2 Esdras", "deutero"),
    ("MAN", "Prayer of Manasseh", "deutero"),
    ("DAG", "Daniel (Greek)", "deutero"),
    ("PS2", "Psalm 151", "deutero"),
    ("ODA", "Odes", "deutero"),
    ("MAT", "Matthew", "new"),
    ("MRK", "Mark", "new"),
    ("LUK", "Luke", "new"),
    ("JHN", "John", "new"),
    ("ACT", "Acts", "new"),
    ("ROM", "Romans", "new"),
    ("1CO", "1 Corinthians", "new"),
    ("2CO", "2 Corinthians", "new"),
    ("GAL", "Galatians", "new"),
    ("EPH", "Ephesians", "new"),
    ("PHP", "Philippians", "new"),
    ("COL", "Colossians", "new"),
    ("1TH", "1 Thessalonians", "new"),
    ("2TH", "2 Thessalonians", "new"),
    ("1TI", "1 Timothy", "new"),
    ("2TI", "2 Timothy", "new"),
    ("TIT", "Titus", "new"),
    ("PHM", "Philemon", "new"),
    ("HEB", "Hebrews", "new"),
    ("JAS", "James", "new"),
    ("1PE", "1 Peter", "new"),
    ("2PE", "2 Peter", "new"),
    ("1JN", "1 John", "new"),
    ("2JN", "2 John", "new"),
    ("3JN", "3 John", "new"),
    ("JUD", "Jude", "new"),
    ("REV", "Revelation", "new"),
]
CANON_BY_NUM = {i + 1: CANON[i] for i in range(len(CANON))}
CANON_BY_ID = {c[0]: c for c in CANON}
# Protestant 66-book order (OT 1–39, NT 40–66) used by bible.com / ethiopian-bibles XML.
PROTESTANT_CANON = [c for c in CANON if c[2] in ("old", "new")]
PROTESTANT_BY_NUM = {i + 1: PROTESTANT_CANON[i] for i in range(len(PROTESTANT_CANON))}

AMHARIC_NAMES = [
    "ዘፍጥረት", "ዘጸአት", "ዘሌዋውያን", "ዘኍልቍ", "ዘዳግም",
    "ኢያሱ", "መሣፍንት", "ሩት", "ሳሙኤል ቀዳማዊ", "ሳሙኤል ካልዕ",
    "ነገሥት ቀዳማዊ", "ነገሥት ካልዕ", "ዜና መዋዕል ቀዳማዊ", "ዜና መዋዕል ካልዕ",
    "ዕዝራ", "ነህምያ", "አስቴር", "ኢዮብ", "መዝሙረ ዳዊት", "ምሳሌ",
    "መክብብ", "መኃልየ መኃልይ", "ኢሳይያስ", "ኤርምያስ", "ሰቆቃወ ኤርምያስ",
    "ሕዝቅኤል", "ዳንኤል", "ሆሴዕ", "ኢዮኤል", "አሞጽ", "አብድዩ",
    "ዮናስ", "ሚክያስ", "ናሆም", "ዕንባቆም", "ሶፎንያስ", "ሐጌ",
    "ዘካርያስ", "ሚልክያስ", "ማቴዎስ", "ማርቆስ", "ሉቃስ", "ዮሐንስ",
    "ሐዋርያት", "ሮሜ", "1 ቆሮንቶስ", "2 ቆሮንቶስ", "ገላትያ", "ኤፌሶን",
    "ፊልጵስዩስ", "ቆላስይስ", "1 ተሰሎንቄ", "2 ተሰሎንቄ", "1 ጢሞቴዎስ",
    "2 ጢሞቴዎስ", "ቲቶ", "ፊልሞና", "ዕብራውያን", "ያዕቆብ", "1 ጴጥሮስ",
    "2 ጴጥሮስ", "1 ዮሐንስ", "2 ዮሐንስ", "3 ዮሐንስ", "ይሁዳ", "ራእይ",
]

LICENSE_CC_BY_SA = {
    "type": "CC-BY-SA-4.0",
    "commercialUse": True,
    "url": "https://creativecommons.org/licenses/by-sa/4.0/",
}
LICENSE_CC_BY_NC_ND = {
    "type": "CC-BY-NC-ND-4.0",
    "commercialUse": False,
    "url": "https://creativecommons.org/licenses/by-nc-nd/4.0/",
}
LICENSE_PD = {
    "type": "PublicDomain",
    "commercialUse": True,
    "url": "https://ebible.org/",
}
LICENSE_CC_BY = {
    "type": "CC-BY-4.0",
    "commercialUse": True,
    "url": "https://creativecommons.org/licenses/by/4.0/",
}
LICENSE_VERIFY = {
    "type": "claimed_public_domain_verify_before_commercial",
    "commercialUse": False,
    "url": "https://github.com/wuletawwonte/ethiopian-bibles",
}

# Preferred eBible editions (full Bible preferred; NT-only when that is all that exists).
# Skip redundant NT editions when a full edition already covers the language+script.
EBIBLE_PACKS = [
    # Defaults / core
    dict(id="gaz", language="om", languageName="Afaan Oromoo", dialect="West Central Oromo",
         name="Open New Oromo Contemporary Version", shortName="ONCV", publisher="Biblica, Inc.",
         year=2022, license=LICENSE_CC_BY_SA, bundled=False, script="Latin",
         attribution="© 2022 Biblica, Inc. CC BY-SA 4.0 via eBible.org."),
    dict(id="gaze", language="om", languageName="Afaan Oromoo", dialect="West Central Oromo",
         name="Open New Oromo Contemporary Version (Ethiopic)", shortName="ONCV-E",
         publisher="Biblica, Inc.", year=2022, license=LICENSE_CC_BY_SA, bundled=False,
         script="Ethiopic", attribution="© 2022 Biblica, Inc. CC BY-SA 4.0 via eBible.org."),
    dict(id="gax", language="om", languageName="Afaan Oromoo", dialect="Borana-Arsi-Guji",
         name="Kitaaba Woyyuu", shortName="Guji", publisher="The Word for the World International",
         year=2025, license=LICENSE_CC_BY_SA, bundled=False, script="Latin",
         attribution="© TWFTW. CC BY-SA 4.0 via eBible.org."),
    dict(id="engwebp", language="en", languageName="English", dialect=None,
         name="World English Bible", shortName="WEB", publisher="eBible.org", year=2020,
         license=LICENSE_PD, bundled=False, script="Latin",
         attribution='World English Bible is Public Domain. "World English Bible" is a trademark of eBible.org.'),
    dict(id="eng-kjv", language="en", languageName="English", dialect=None,
         name="King James Version", shortName="KJV", publisher="Public Domain", year=1769,
         license=LICENSE_PD, bundled=True, script="Latin", out_id="engkjv",
         attribution="King James Version (1769). Public Domain."),
    # Amharic NT from eBible (restricted/non-commercial)
    dict(id="amh", language="am", languageName="አማርኛ", dialect=None,
         name="Amharic New Testament (UBS)", shortName="AM-NT", publisher="United Bible Societies",
         year=2003, license=LICENSE_CC_BY_NC_ND, bundled=False, script="Ethiopic",
         attribution="© 1962, 2003 United Bible Societies. Non-commercial use with full copyright notice. Commercial use needs Bible Society of Ethiopia permission."),
    # Other Ethiopian languages from eBible
    dict(id="alw", language="alw", languageName="Alaba-K'abeena", dialect=None,
         name="Alaba-K'abeena New Testament", shortName="ALW", publisher="eBible.org",
         year=None, license=LICENSE_CC_BY_SA, bundled=False, script="Ethiopic",
         attribution="Alaba-K'abeena NT via eBible.org. CC BY-SA."),
    dict(id="bswl", language="bsw", languageName="Baiso", dialect=None,
         name="Baiso New Testament (Latin)", shortName="BSW-L", publisher="eBible.org",
         year=None, license=LICENSE_CC_BY_SA, bundled=False, script="Latin",
         attribution="Baiso NT (Latin) via eBible.org. CC BY-SA."),
    dict(id="bswe", language="bsw", languageName="Baiso", dialect=None,
         name="Baiso New Testament (Ethiopic)", shortName="BSW-E", publisher="eBible.org",
         year=None, license=LICENSE_CC_BY_SA, bundled=False, script="Ethiopic",
         attribution="Baiso NT (Ethiopic) via eBible.org. CC BY-SA."),
    dict(id="bwo", language="bwo", languageName="Borna", dialect=None,
         name="Borna New Testament", shortName="BWO", publisher="eBible.org",
         year=None, license=LICENSE_CC_BY_SA, bundled=False, script="Latin",
         attribution="Borna NT via eBible.org."),
    dict(id="dwrENT", language="dwr", languageName="Dawro", dialect=None,
         name="Dawro Bible (Ethiopic)", shortName="DWR-E", publisher="eBible.org",
         year=None, license=LICENSE_CC_BY_SA, bundled=False, script="Ethiopic",
         attribution="Dawro Bible (Ethiopic) via eBible.org. CC BY-SA."),
    dict(id="dwrl", language="dwr", languageName="Dawro", dialect=None,
         name="Dawro Bible (Latin)", shortName="DWR-L", publisher="eBible.org",
         year=None, license=LICENSE_CC_BY_SA, bundled=False, script="Latin",
         attribution="Dawro Bible (Latin) via eBible.org. CC BY-SA."),
    dict(id="gmve", language="gmv", languageName="Gamo", dialect=None,
         name="Gamo Bible (Ethiopic)", shortName="GMV-E", publisher="eBible.org",
         year=None, license=LICENSE_CC_BY_SA, bundled=False, script="Ethiopic",
         attribution="Gamo Bible (Ethiopic) via eBible.org. CC BY-SA."),
    dict(id="gmvl", language="gmv", languageName="Gamo", dialect=None,
         name="Gamo Bible (Latin)", shortName="GMV-L", publisher="eBible.org",
         year=None, license=LICENSE_CC_BY_SA, bundled=False, script="Latin",
         attribution="Gamo Bible (Latin) via eBible.org. CC BY-SA."),
    dict(id="gyl", language="gyl", languageName="Gayil", dialect=None,
         name="Gayil New Testament", shortName="GYL", publisher="eBible.org",
         year=None, license=LICENSE_CC_BY_SA, bundled=False, script="Ethiopic",
         attribution="Gayil NT via eBible.org. CC BY-SA."),
    dict(id="gofe", language="gof", languageName="Gofa", dialect=None,
         name="Gofa Bible (Ethiopic)", shortName="GOF-E", publisher="eBible.org",
         year=None, license=LICENSE_CC_BY_SA, bundled=False, script="Ethiopic",
         attribution="Gofa Bible (Ethiopic) via eBible.org. CC BY-SA."),
    dict(id="gofl", language="gof", languageName="Gofa", dialect=None,
         name="Gofa Bible (Latin)", shortName="GOF-L", publisher="eBible.org",
         year=None, license=LICENSE_CC_BY_SA, bundled=False, script="Latin",
         attribution="Gofa Bible (Latin) via eBible.org. CC BY-SA."),
    dict(id="amf", language="amf", languageName="Hamer-Banna", dialect=None,
         name="Banna New Testament", shortName="AMF", publisher="eBible.org",
         year=None, license=LICENSE_CC_BY_NC_ND, bundled=False, script="Latin",
         attribution="Banna NT via eBible.org. CC BY-NC-ND."),
    dict(id="mdyeth", language="mdy", languageName="Maale", dialect=None,
         name="Maale Bible (Ethiopic)", shortName="MDY", publisher="eBible.org",
         year=None, license=LICENSE_CC_BY_SA, bundled=False, script="Ethiopic",
         attribution="Maale Bible (Ethiopic) via eBible.org. CC BY-SA."),
    dict(id="mfxl", language="mfx", languageName="Melo", dialect=None,
         name="Melo New Testament (Latin)", shortName="MFX-L", publisher="eBible.org",
         year=None, license=LICENSE_CC_BY_SA, bundled=False, script="Latin",
         attribution="Melo NT (Latin) via eBible.org. CC BY-SA."),
    dict(id="mfxe", language="mfx", languageName="Melo", dialect=None,
         name="Melo New Testament (Ethiopic)", shortName="MFX-E", publisher="eBible.org",
         year=None, license=LICENSE_CC_BY_SA, bundled=False, script="Ethiopic",
         attribution="Melo NT (Ethiopic) via eBible.org. CC BY-SA."),
    dict(id="oydl", language="oyd", languageName="Oyda", dialect=None,
         name="Oyda New Testament (Latin)", shortName="OYD-L", publisher="eBible.org",
         year=None, license=LICENSE_CC_BY_SA, bundled=False, script="Latin",
         attribution="Oyda NT (Latin) via eBible.org. CC BY-SA."),
    dict(id="oyde", language="oyd", languageName="Oyda", dialect=None,
         name="Oyda New Testament (Ethiopic)", shortName="OYD-E", publisher="eBible.org",
         year=None, license=LICENSE_CC_BY_SA, bundled=False, script="Ethiopic",
         attribution="Oyda NT (Ethiopic) via eBible.org. CC BY-SA."),
    dict(id="wal", language="wal", languageName="Wolaytta", dialect=None,
         name="Wolaytta Bible", shortName="WAL", publisher="SIM",
         year=2004, license=LICENSE_CC_BY_NC_ND, bundled=False, script="Latin",
         attribution="Wolaytta Bible © 2004 SIM. CC BY-NC-ND via eBible.org."),
    dict(id="jnjl", language="jnj", languageName="Yemsa", dialect=None,
         name="Yemsa New Testament (Latin)", shortName="JNJ-L", publisher="eBible.org",
         year=None, license=LICENSE_CC_BY_SA, bundled=False, script="Latin",
         attribution="Yemsa NT (Latin) via eBible.org. CC BY-SA."),
    dict(id="jnje", language="jnj", languageName="Yemsa", dialect=None,
         name="Yemsa New Testament (Ethiopic)", shortName="JNJ-E", publisher="eBible.org",
         year=None, license=LICENSE_CC_BY_SA, bundled=False, script="Ethiopic",
         attribution="Yemsa NT (Ethiopic) via eBible.org. CC BY-SA."),
    dict(id="som", language="so", languageName="Somali", dialect=None,
         name="Kitaabka Quduuska Ah", shortName="SOM", publisher="SIM Kenya",
         year=2008, license=LICENSE_CC_BY_NC_ND, bundled=False, script="Latin",
         attribution="Somali Bible © 1979, 2008 SIM. CC BY-NC-ND via eBible.org."),
    # Ancient / original-language editions
    dict(id="grclxx", language="grc", languageName="Ancient Greek", dialect="Septuagint",
         name="Septuaginta (LXX)", shortName="LXX", publisher="Public Domain",
         year=None, license=LICENSE_PD, bundled=False, script="Greek",
         textDirection="ltr",
         attribution="Greek Septuagint (LXX). Public Domain via eBible.org. Includes deuterocanonical books."),
    dict(id="grcbrent", language="grc", languageName="Ancient Greek", dialect="Septuagint",
         name="Brenton Septuagint Greek", shortName="LXX-Brenton", publisher="Public Domain",
         year=1851, license=LICENSE_PD, bundled=False, script="Greek",
         textDirection="ltr",
         attribution="Brenton Septuagint Greek text. Public Domain via eBible.org."),
    dict(id="eng-Brenton", language="en", languageName="English", dialect="Septuagint English",
         name="Brenton English Septuagint", shortName="Brenton", publisher="Public Domain",
         year=1851, license=LICENSE_PD, bundled=False, script="Latin", out_id="engbrent",
         textDirection="ltr",
         attribution="Sir Lancelot C. L. Brenton English Septuagint (1851). Public Domain."),
    dict(id="hebwlc", language="hbo", languageName="Biblical Hebrew", dialect="Masoretic / WLC",
         name="Hebrew Westminster Leningrad Codex", shortName="WLC", publisher="Public Domain",
         year=None, license=LICENSE_PD, bundled=False, script="Hebrew",
         textDirection="rtl",
         attribution="Westminster Leningrad Codex Hebrew Bible. Public Domain via eBible.org."),
    dict(id="grcbyz", language="grc", languageName="Ancient Greek", dialect="Byzantine NT",
         name="Byzantine Greek New Testament", shortName="ByzNT", publisher="Public Domain",
         year=None, license=LICENSE_PD, bundled=False, script="Greek",
         textDirection="ltr",
         attribution="Byzantine Greek New Testament. Public Domain via eBible.org."),
    dict(id="grctr", language="grc", languageName="Ancient Greek", dialect="Textus Receptus",
         name="Textus Receptus Greek NT", shortName="TR", publisher="Public Domain",
         year=None, license=LICENSE_PD, bundled=False, script="Greek",
         textDirection="ltr",
         attribution="Greek Textus Receptus New Testament. Public Domain via eBible.org."),
    dict(id="grcsbl", language="grc", languageName="Ancient Greek", dialect="Critical NT",
         name="SBL Greek New Testament", shortName="SBLGNT",
         publisher="Society of Biblical Literature / Logos",
         year=2010, license=LICENSE_CC_BY, bundled=False, script="Greek",
         textDirection="ltr",
         attribution="SBLGNT © 2010 Society of Biblical Literature and Logos Bible Software. CC BY 4.0."),
    dict(id="latclem", language="la", languageName="Latin", dialect="Clementine Vulgate",
         name="Clementine Latin Vulgate", shortName="Vulgate", publisher="Public Domain",
         year=1592, license=LICENSE_PD, bundled=False, script="Latin",
         textDirection="ltr",
         attribution="Clementine Latin Vulgate. Public Domain."),
]

# Languages not available on eBible, from wuletawwonte/ethiopian-bibles.
CUSTOM_XML_PACKS = [
    dict(out_id="ti", file="AmharicTigrinyaBible.xml", language="ti", languageName="ትግርኛ",
         name="Tigrinya Bible", shortName="TI", names=None),
    dict(out_id="sid", file="SidamoBible.xml", language="sid", languageName="Sidaamu Afoo",
         name="Sidamo Bible", shortName="SID", names=None),
    dict(out_id="hdy", file="HadiyyaBible.xml", language="hdy", languageName="Hadiyyisa",
         name="Hadiyya Bible", shortName="HDY", names=None),
    dict(out_id="nus", file="NuerBible.xml", language="nus", languageName="Nuer",
         name="Nuer Bible", shortName="NUS", names=None),
    # NOTE: MacQul is Afaan Oromo (YouVersion 3202), not Amharic Catholic.
    # Bundled macqul.json is built separately from BSE MacQul text.
    # Amharic Catholic / Emmaus is optional amcatholic from AmharicCatholicBible.xml.
    dict(out_id="amcatholic", file="AmharicCatholicBible.xml", language="am", languageName="አማርኛ",
         name="መጽሐፍ ቅዱስ (ካቶሊካዊ እትም - ኤማሁስ)", shortName="መቅካእኤ", names=AMHARIC_NAMES,
         bundled=False, canon="catholic"),
    dict(out_id="nasv", file="AmharicNASVBible.xml", language="am", languageName="አማርኛ",
         name="አዲሱ መደበኛ ትርጕም (Addisu Medebegna Tirgum)", shortName="አመት",
         names=AMHARIC_NAMES, bundled=True, year=2001, publisher="Biblica, Inc.",
         dialect="Addisu Medebegna Tirgum"),
    dict(out_id="am54", file="AmharicBible.xml", language="am", languageName="አማርኛ",
         name="መጽሐፍ ቅዱስ (አማ54)", shortName="AM54", names=AMHARIC_NAMES),
    dict(out_id="am05", file="AmharicNSTBible.xml", language="am", languageName="አማርኛ",
         name="አማርኛ አዲሱ መደበኛ ትርጉም (አማ05 / 2005)", shortName="AM05", names=AMHARIC_NAMES,
         year=2005, publisher="Bible Society of Ethiopia"),
    dict(out_id="am2005", file="AmharicNSTBible.xml", language="am", languageName="አማርኛ",
         name="Amharic NST 2005 (አማ2005)", shortName="AM2005", names=AMHARIC_NAMES,
         year=2005, publisher="Bible Society of Ethiopia"),
    dict(out_id="am2000", file="Amharic2000Bible.xml", language="am", languageName="አማርኛ",
         name="የአማርኛ መጽሐፍ ቅዱስ (አማ2000)", shortName="AM2000", names=AMHARIC_NAMES,
         year=2000, publisher="Bible Society of Ethiopia"),
    dict(out_id="om_waaqa", file="OromoKitaabaWaaqaBible.xml", language="om",
         languageName="Afaan Oromoo", name="Kitaaba Waaqa", shortName="Waaqa", names=None),
    dict(out_id="om_kakuu", file="OromoKakuuHaaraakaBible.xml", language="om",
         languageName="Afaan Oromoo", name="Kakuu Haaraaka", shortName="Kakuu", names=None),
    dict(out_id="om_haarawa", file="OromoWaadaaHaarawaBible.xml", language="om",
         languageName="Afaan Oromoo", name="Waadaa Haarawa", shortName="Haarawa", names=None),
    dict(out_id="om_lammataa", file="OromoWaadaaLammataaBible.xml", language="om",
         languageName="Afaan Oromoo", name="Waadaa Lammataa", shortName="Lammataa", names=None),
]


def clean_text(text: str) -> str:
    return re.sub(r"\s+", " ", text or "").strip()


def strip_xml_tags(fragment: str) -> str:
    fragment = re.sub(
        r"<(note|f|x|fig|table)\b[^>]*>.*?</\1>",
        " ",
        fragment,
        flags=re.DOTALL | re.IGNORECASE,
    )
    fragment = re.sub(r"<[^>]+>", " ", fragment)
    fragment = (
        fragment.replace("&amp;", "&")
        .replace("&lt;", "<")
        .replace("&gt;", ">")
        .replace("&quot;", '"')
        .replace("&apos;", "'")
        .replace("&#160;", " ")
        .replace("&nbsp;", " ")
    )
    text = clean_text(fragment)
    return re.sub(r"\s+([,.;:!?])", r"\1", text)


def parse_book_names(path: Path) -> dict[str, dict]:
    if not path.exists():
        return {}
    root = ET.parse(path).getroot()
    names: dict[str, dict] = {}
    for book in root:
        tag = book.tag.rsplit("}", 1)[-1]
        if tag != "book":
            continue
        code = book.attrib.get("code")
        if not code:
            continue
        names[code] = {
            "short": book.attrib.get("short") or "",
            "long": book.attrib.get("long") or "",
        }
    return names


def parse_usfx(usfx_path: Path, book_names_path: Path | None = None) -> list[dict]:
    names = parse_book_names(book_names_path) if book_names_path else {}
    raw = usfx_path.read_text(encoding="utf-8-sig", errors="replace")
    books: list[dict] = []
    for book_match in re.finditer(
        r'<book\s+id="([A-Za-z0-9]+)"[^>]*>(.*?)</book>',
        raw,
        flags=re.DOTALL | re.IGNORECASE,
    ):
        book_id = book_match.group(1).upper()
        if book_id not in CANON_BY_ID:
            continue
        meta = CANON_BY_ID[book_id]
        local = names.get(book_id, {})
        book_xml = book_match.group(2)
        book = {
            "id": book_id,
            "name": local.get("short") or meta[1],
            "nameLong": local.get("long") or meta[1],
            "testament": meta[2],
            "chapters": [],
        }
        parts = re.split(r'<c\s+id="(\d+)"\s*/>', book_xml)
        for i in range(1, len(parts), 2):
            chapter_num = int(parts[i])
            body = parts[i + 1] if i + 1 < len(parts) else ""
            chapter = {"number": chapter_num, "verses": []}
            for verse_match in re.finditer(
                r'<v\s+id="(\d+)"[^>]*/>\s*(.*?)\s*<ve\s*/>',
                body,
                flags=re.DOTALL | re.IGNORECASE,
            ):
                text = strip_xml_tags(verse_match.group(2))
                if text:
                    chapter["verses"].append(
                        {"number": int(verse_match.group(1)), "text": text}
                    )
            if chapter["verses"]:
                book["chapters"].append(chapter)
        if book["chapters"]:
            books.append(book)
    return books


def parse_custom_xml(xml_path: Path, localized_names: list[str] | None = None) -> list[dict]:
    root = ET.parse(xml_path).getroot()
    book_els = root.findall(".//book")
    nums = [int(b.attrib.get("number", "0") or 0) for b in book_els]
    # bible.com-style sources use Protestant 1–66 numbering, not the expanded canon index.
    use_protestant = bool(nums) and max(nums) <= 66 and len(nums) <= 66
    number_map = PROTESTANT_BY_NUM if use_protestant else CANON_BY_NUM
    books: list[dict] = []
    for book_el in book_els:
        num = int(book_el.attrib.get("number", "0") or 0)
        if num not in number_map:
            continue
        book_id, eng_name, testament = number_map[num]
        name = eng_name
        if localized_names and 0 <= num - 1 < len(localized_names):
            name = localized_names[num - 1]
        book = {
            "id": book_id,
            "name": name,
            "nameLong": name,
            "testament": testament,
            "chapters": [],
        }
        for chapter_el in book_el.findall("chapter"):
            chapter_num = int(chapter_el.attrib.get("number", "0") or 0)
            chapter = {"number": chapter_num, "verses": []}
            for verse_el in chapter_el.findall("verse"):
                verse_num = int(verse_el.attrib.get("number", "0") or 0)
                text = clean_text(verse_el.text or "")
                if text:
                    chapter["verses"].append({"number": verse_num, "text": text})
            if chapter["verses"]:
                book["chapters"].append(chapter)
        if book["chapters"]:
            books.append(book)
    return books


def normalize_amharic_title(title: str) -> str:
    title = title.replace("ኦሪት ", "").replace("መጽሐፈ ", "").replace("ትንቢተ ", "")
    title = title.replace("ትንቢት ", "").replace("።", "").strip()
    replacements = {
        "የሉቃስ ወንጌል": "ሉቃስ",
        "የማቴዎስ ወንጌል": "ማቴዎስ",
        "የማርቆስ ወንጌል": "ማርቆስ",
        "የዮሐንስ ወንጌል": "ዮሐንስ",
        "የሐዋርያት ሥራ": "ሐዋርያት",
        "ሰቆቃው ኤርምያስ": "ሰቆቃወ ኤርምያስ",
    }
    return replacements.get(title, title)


def parse_amharic_magna(path: Path) -> list[dict]:
    data = json.loads(path.read_text(encoding="utf-8"))
    books_in = data["books"] if isinstance(data, dict) else data
    books: list[dict] = []
    for idx, book in enumerate(books_in):
        if idx >= len(CANON):
            break
        book_id, _, testament = CANON[idx]
        raw_title = book.get("title") or AMHARIC_NAMES[idx]
        name = normalize_amharic_title(str(raw_title))
        out_book = {
            "id": book_id,
            "name": name,
            "nameLong": name,
            "testament": testament,
            "chapters": [],
        }
        for chapter_index, chapter in enumerate(book.get("chapters", []), start=1):
            raw_chapter = str(chapter.get("chapter", "")).strip()
            chapter_num = int(raw_chapter) if raw_chapter.isdigit() else chapter_index
            verses = []
            for i, text in enumerate(chapter.get("verses", [])):
                verses.append({"number": i + 1, "text": clean_text(str(text))})
            if verses:
                out_book["chapters"].append({"number": chapter_num, "verses": verses})
        if out_book["chapters"]:
            books.append(out_book)
    return books


def pack_stats(books: list[dict]) -> dict:
    return {
        "bookCount": len(books),
        "chapterCount": sum(len(b["chapters"]) for b in books),
        "verseCount": sum(len(c["verses"]) for b in books for c in b["chapters"]),
    }


def infer_scope(books: list[dict]) -> str:
    ids = {b["id"] for b in books}
    has_ot = any(CANON_BY_ID[i][2] == "old" for i in ids if i in CANON_BY_ID)
    has_nt = any(CANON_BY_ID[i][2] == "new" for i in ids if i in CANON_BY_ID)
    if has_ot and has_nt and len(books) >= 66:
        return "full"
    if has_ot and has_nt:
        return "partial"
    if has_nt and not has_ot:
        return "nt"
    if has_ot and not has_nt:
        return "ot"
    return "partial"


def write_pack(meta: dict, books: list[dict], out_path: Path) -> dict:
    stats = pack_stats(books)
    payload = {
        **meta,
        "scope": meta.get("scope") or infer_scope(books),
        **stats,
        "books": books,
    }
    out_path.parent.mkdir(parents=True, exist_ok=True)
    raw = json.dumps(payload, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
    with gzip.open(out_path, "wb", compresslevel=9) as f:
        f.write(raw)
    entry = {
        k: payload[k]
        for k in [
            "id",
            "language",
            "languageName",
            "dialect",
            "name",
            "shortName",
            "publisher",
            "year",
            "license",
            "textDirection",
            "bundled",
            "scope",
            "script",
            "canon",
            "source",
            "bookCount",
            "chapterCount",
            "verseCount",
            "attribution",
        ]
        if k in payload
    }
    entry["asset"] = str(out_path.relative_to(ROOT / "assets" / "bible"))
    entry["sizeBytes"] = out_path.stat().st_size
    print(
        f"Wrote {out_path.name}: {entry['bookCount']} books / "
        f"{entry['verseCount']} verses / {entry['sizeBytes']/1024:.0f} KB "
        f"[{entry.get('scope')}]"
    )
    return entry


def find_usfx_dir(ebible_id: str) -> Path:
    candidates = [ETH / ebible_id, SRC / ebible_id, ETH / ebible_id.replace("-", "")]
    for path in candidates:
        if path.exists():
            return path
    raise FileNotFoundError(f"Missing extracted USFX for {ebible_id}")


def convert_ebible_pack(spec: dict) -> dict:
    ebible_id = spec["id"]
    out_id = spec.get("out_id", ebible_id)
    folder = find_usfx_dir(ebible_id)
    usfx_files = sorted(folder.glob("*_usfx.xml")) + sorted(folder.glob("*usfx.xml"))
    if not usfx_files:
        raise FileNotFoundError(f"No USFX XML in {folder}")
    books = parse_usfx(usfx_files[0], folder / "BookNames.xml")
    meta = {
        "id": out_id,
        "language": spec["language"],
        "languageName": spec["languageName"],
        "dialect": spec.get("dialect"),
        "name": spec["name"],
        "shortName": spec["shortName"],
        "publisher": spec.get("publisher"),
        "year": spec.get("year"),
        "license": spec["license"],
        "textDirection": spec.get("textDirection", "ltr"),
        "bundled": bool(spec.get("bundled")),
        "script": spec.get("script"),
        "canon": spec.get("canon", "protestant"),
        "source": (
            "open-bibles / Public Domain"
            if ebible_id == "latclem"
            else f"eBible.org ({ebible_id})"
        ),
        "attribution": spec.get("attribution", ""),
    }
    if any(b["testament"] == "deutero" for b in books):
        meta["canon"] = "expanded"
    if len(books) <= 39 and all(b["testament"] == "old" for b in books):
        meta["canon"] = "hebrew"
    if all(b["testament"] == "new" for b in books) and len(books) <= 27:
        meta["canon"] = "nt"
    out_dir = OUT_BUNDLED if meta["bundled"] else OUT_OPTIONAL
    return write_pack(meta, books, out_dir / f"{out_id}.json.gz")


def main() -> None:
    OUT_BUNDLED.mkdir(parents=True, exist_ok=True)
    OUT_OPTIONAL.mkdir(parents=True, exist_ok=True)
    # Clear previous optional packs so removed/renamed IDs do not linger.
    for old in OUT_OPTIONAL.glob("*.json.gz"):
        old.unlink()
    for old in OUT_BUNDLED.glob("*.json.gz"):
        old.unlink()

    catalog: list[dict] = []

    # 1) Full Amharic default from magna25 (complete 66 books)
    am_path = SRC / "amharic-bible-json-main" / "amharic_bible.json"
    am_books = parse_amharic_magna(am_path)
    catalog.append(
        write_pack(
            {
                "id": "am",
                "language": "am",
                "languageName": "አማርኛ",
                "dialect": None,
                "name": "መጽሐፍ ቅዱስ (Amharic)",
                "shortName": "AM",
                "publisher": "Bible Society of Ethiopia / UBS tradition",
                "year": None,
                "license": {
                    "type": "redistribution_with_attribution",
                    "commercialUse": False,
                    "url": "https://github.com/magna25/amharic-bible-json",
                },
                "textDirection": "ltr",
                "bundled": False,
                "script": "Ethiopic",
                "source": "magna25/amharic-bible-json",
                "attribution": (
                    "Amharic Bible packaged from magna25/amharic-bible-json. "
                    "Commercial redistribution of Scripture text needs Bible Society of Ethiopia permission."
                ),
            },
            am_books,
            OUT_OPTIONAL / "am.json.gz",
        )
    )

    # 2) All preferred eBible packs
    for spec in EBIBLE_PACKS:
        try:
            catalog.append(convert_ebible_pack(spec))
        except Exception as exc:  # noqa: BLE001
            print(f"ERROR {spec['id']}: {exc}")

    # 3) Custom XML packs for languages missing from eBible
    original_dir = SRC / "ethiopian-bibles-main" / "original"
    for spec in CUSTOM_XML_PACKS:
        xml_path = original_dir / spec["file"]
        if not xml_path.exists():
            print(f"Skipping missing {spec['file']}")
            continue
        books = parse_custom_xml(xml_path, spec.get("names"))
        bundled = bool(spec.get("bundled"))
        out_path = (
            (OUT_BUNDLED / f"{spec['out_id']}.json.gz")
            if bundled
            else (OUT_OPTIONAL / f"{spec['out_id']}.json.gz")
        )
        catalog.append(
            write_pack(
                {
                    "id": spec["out_id"],
                    "language": spec["language"],
                    "languageName": spec["languageName"],
                    "dialect": None,
                    "name": spec["name"],
                    "shortName": spec["shortName"],
                    "publisher": spec.get("publisher") or "See wuletawwonte/ethiopian-bibles",
                    "year": spec.get("year"),
                    "license": LICENSE_VERIFY,
                    "textDirection": "ltr",
                    "bundled": bundled,
                    "script": "Latin/Ethiopic",
                    "canon": spec.get("canon", "protestant"),
                    "source": "wuletawwonte/ethiopian-bibles",
                    "attribution": (
                        f"{spec['name']} from wuletawwonte/ethiopian-bibles. "
                        "Verify publisher rights before commercial redistribution."
                    ),
                },
                books,
                out_path,
            )
        )

    # 4) English ASV (public domain)
    asv_path = SRC / "ethiopian-bibles-main" / "english" / "EnglishASVBible.xml"
    if asv_path.exists():
        catalog.append(
            write_pack(
                {
                    "id": "engasv",
                    "language": "en",
                    "languageName": "English",
                    "dialect": None,
                    "name": "American Standard Version",
                    "shortName": "ASV",
                    "publisher": "Public Domain",
                    "year": 1901,
                    "license": LICENSE_PD,
                    "textDirection": "ltr",
                    "bundled": False,
                    "script": "Latin",
                    "source": "ASV 1901",
                    "attribution": "American Standard Version (1901). Public Domain.",
                },
                parse_custom_xml(asv_path),
                OUT_OPTIONAL / "engasv.json.gz",
            )
        )

    # Stable sort: bundled first, then by language name / short name.
    catalog.sort(
        key=lambda item: (
            0 if item.get("bundled") else 1,
            item.get("languageName") or "",
            item.get("shortName") or "",
        )
    )

    languages = []
    seen_lang = set()
    for item in catalog:
        code = item["language"]
        if code in seen_lang:
            continue
        seen_lang.add(code)
        languages.append(
            {
                "code": code,
                "name": item["languageName"],
                "nativeName": item["languageName"],
            }
        )

    catalog_doc = {
        "schemaVersion": 2,
        "defaultTranslationIds": ["macqul", "nasv", "engkjv"],
        "languages": languages,
        "translations": catalog,
        "notes": [
            "Bundled defaults install automatically for offline reading.",
            "Optional packs ship in-app and install into local SQLite/documents storage on demand.",
            "Prefer CC BY-SA and Public Domain texts from eBible.org.",
            "CC BY-NC-ND editions are for non-commercial use with attribution.",
            "Copyrighted commercial English editions (NIV/ESV/etc.) are excluded.",
        ],
    }
    OUT_CATALOG.write_text(
        json.dumps(catalog_doc, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print(f"\nCatalog written with {len(catalog)} translations across {len(languages)} languages")


if __name__ == "__main__":
    main()
