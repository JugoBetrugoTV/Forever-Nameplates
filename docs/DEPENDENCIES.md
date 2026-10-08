# Libraries und Entwicklungswerkzeuge

| Library | Version / Pin | Quelle | Lizenz | Zweck |
| --- | --- | --- | --- | --- |
| LibStub | Major LibStub, Minor 2; Ace3 `40f4cc1356ae7fcc0cf71fc0a19dc7d50d6ae6c2` | https://github.com/WoWUIDev/Ace3 | Public Domain, Hinweis im Dateikopf | Versionssichere Library-Registrierung |
| LibDeflate | 1.0.2-release, Minor 3; `afc3b78d12fb3bcfa6b21e5332031ad3d7572e19` | https://github.com/SafeteeWoW/LibDeflate | zlib; vollständiger Lizenztext eingebettet | Kompression und druckbare Share-Codes |

Beide werden vor dem eigenen Code über die TOC geladen und sind unverändert eingebettet.
SHA-256, genaue Upstream-Pfade und Commit-Pins stehen in `Tools/libraries.json`.
`python Tools/vendor_libraries.py` überprüft die Dateien; `--refresh` lädt exakt diese
Versionen erneut über HTTPS und prüft alle Checksums, bevor Dateien ersetzt werden.
Eine neue Version erfordert eine bewusst geprüfte Änderung der Pins und Hashes.
Für das bestehende ZIP ist kein Download durch den Spieler nötig.

AceAddon/AceEvent/AceDB/AceLocale sind für diesen Kern nicht erforderlich: ein Event-Frame,
ein kleines validiertes Datenmodell und ein lokales Wörterbuch genügen. Kein AceConfig-GUI.
LibSerialize wurde recherchiert (MIT, `aa6e50dddad28f8dfa6c27c9b1e15ae40262b4a5`),
aber nicht eingebettet: das feste, nicht ausführbare Share-Schema benötigt keinen allgemeinen
Table-Deserializer. LibSharedMedia, LDB und DBIcon sind für spätere Medien-/Launcher-Integration
optional und im ersten Stand nicht enthalten.

Share-Codes: Präfix `FN1:`, feste deklarative Felder, maximal 64 Elemente, 32 KiB Rohdaten,
48.000 Zeichen Code, kleine unabhängig komprimierte 160-Byte-Blöcke. Import überprüft Blockgrößen,
Gesamtlänge, Typen, Bereiche, IDs, bekannte Assets und Schema-Version. LibDeflate bietet keine
Streaming-Ausgabelimit-Option; deshalb wird die Eingabe pro Aufruf auf 180 komprimierte Bytes
begrenzt und die Ausgabe unmittelbar auf 160 Bytes geprüft. Es erfolgt kein `loadstring`, kein
`dofile`, kein beliebiger Asset-Pfad und kein Import von Lua-Funktionen.

Die Python-Entwicklungswerkzeuge (Lupa, pytest, Pillow und deren Abhängigkeiten) sind separat
in `requirements-dev.lock` gepinnt; sie werden nicht mit dem Addon ausgeliefert.
Lupa stellt Lua 5.1 bereit. Pillow verarbeitet die Grafiken lokal, pytest führt die Tests aus.
Die externen Forschungscheckouts dienen nur als Dokumentation/Editor-Definitionen und sind
keine Addon-Abhängigkeiten. Aus dem Atraeau-Repository werden keine ungeklärten Lizenzen
ins Addon-Paket übernommen.
