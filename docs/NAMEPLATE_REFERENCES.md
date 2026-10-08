# Ausschließlich Original-Nameplates

Aktuelle Nutzeranweisung: verschiedene Nameplate-Formen und Designs aus den sieben genannten
Spielen so genau wie möglich übernehmen. Ausschließlich die über Units sichtbaren Nameplates;
keine Target-Portraitframes, Player-HUDs, Bossleisten am Bildschirmrand oder neue GUI-Artwork.
Bestehender Editor und bisherige Profile bleiben erhalten. Die alten prozeduralen Presets sind
Legacy-Platzhalter und erfüllen den neuen Original-Look nicht.

## Quellenstand 2026-10-08

Aktualisierung 0.4.1: Die Tabelle dokumentiert den ursprünglichen Abrufblock. Mehrere Webseiten
sind inzwischen erreichbar; FFXIV-Bildlinks wurden im offiziellen Guide gefunden, deren CDN
bleibt gesperrt. [Aktuelle Abrufbefunde und konkrete Originalbildlinks](INTERNET_IMAGE_REFERENCES.md).

| Spiel | Quelle / Abruf | Umsetzungsstand |
| --- | --- | --- |
| WoW Classic | Gethe/wow-ui-source Tag 1.15.8, Commit `e0099491e5ce94ef87c791b053f1e1509b5fd7ac` | Struktur als eigenes Nameplate-Layout rekonstruiert; Client-Texturpixel nicht geprüft |
| WoW Dragonflight | Gethe/wow-ui-source Tag 10.2.7, Commit `6b65c2922baca3db5a28fb39b69c95cef1047bec` | Struktur als eigenes Nameplate-Layout rekonstruiert; Client-Texturpixel nicht geprüft |
| Guild Wars 2 | Abruf von `wiki.guildwars2.com` durch Proxy mit HTTP 403 abgelehnt | Keine Originalgrafik geprüft, Layoutauswahl deaktiviert |
| SWTOR | Abruf von `www.swtor.com` durch Proxy mit HTTP 403 abgelehnt | Keine Originalgrafik geprüft, Layoutauswahl deaktiviert |
| ESO | Abruf von `help.elderscrollsonline.com` durch Proxy mit HTTP 403 abgelehnt | Keine Originalgrafik geprüft, Layoutauswahl deaktiviert |
| FFXIV | Abruf von `na.finalfantasyxiv.com` durch Proxy mit HTTP 403 abgelehnt | Keine Originalgrafik geprüft, Layoutauswahl deaktiviert |
| Diablo IV | Abruf von `news.blizzard.com` durch Proxy mit HTTP 403 abgelehnt | Keine Originalgrafik geprüft, Layoutauswahl deaktiviert |

Die zwei WoW-Versionen sind Arbeitsreferenzen des Agenten, keine vom Nutzer ausdrücklich
gewählten Patches. GitHub-Zugriff funktioniert über den bereitgestellten HTTPS-Proxy.
Auch der eskalierte Versuch auf die FFXIV-Seite blieb am HTTP-403-Netzwerkproxy hängen;
das war keine Ablehnung der automatischen Genehmigungsprüfung. Ein HTTP-403-Tunnelabbruch
bestätigt nicht, dass die angefragte URL existiert oder ein geeignetes Bild enthalten würde.
Es wurden keine blockierten Bilder als angeschaut oder nachgebaut protokolliert.

### Classic: nachgewiesene Struktur

[Vanilla/Blizzard_NamePlates.xml](https://github.com/Gethe/wow-ui-source/blob/e0099491e5ce94ef87c791b053f1e1509b5fd7ac/Interface/AddOns/Blizzard_NamePlates/Vanilla/Blizzard_NamePlates.xml)
und die zugehörige Lua-Datei: Basis 128×32 bei Scale=1. Health links +4/rechts −21 ergibt
103 Punkte Breite, Höhe 10. Nameplate-Border 128×16, links −4 relativ zum Healthbar-Rand,
TexCoords 0..1 / 0.5..1. Füllung `Interface/TargetingFrame/UI-TargetingFrame-BarFill`.
Classic-Level rechts, Raidmarker links, Name über dem Border. Große Nameplate-Schrift 12,
Levelschrift 10 in der lateinischen Font-Familie. Keine frei erfundenen Bronze-Flügel.

Das importierbare `classic_frame.png` ist daher 128×16 mit versetzter transparenter Öffnung
Box `[4,3,107,13]` (103×10). Das laufende Quellenlayout verwendet die Clienttextur und ist
nicht auf ein generiertes PNG angewiesen.

### Dragonflight: nachgewiesene Struktur

[Blizzard_NamePlates.xml](https://github.com/Gethe/wow-ui-source/blob/6b65c2922baca3db5a28fb39b69c95cef1047bec/Interface/AddOns/Blizzard_NamePlates/Blizzard_NamePlates.xml),
zugehörige Lua-Datei sowie `Blizzard_UnitFrame/Mainline/CompactUnitFrame.lua`: Basisbreite 110.
Cast links/rechts je 12 ergibt 86 Breite. Health 4 hoch, Cast 8 hoch bei VerticalScale=1,
Health 2 Punkte über der Castbar. Name mit Abstand 4 über dem Healthbar. Rahmen besteht
hier tatsächlich aus geraden Konturen. Raidmarker links; Target-Kontur weiß, standardmäßig
schwarz. Cast-Hintergrundatlas `ui-castingbar-background`. Keine erfundenen Teal-/Silber-Ornamente.

Das Quellenlayout wählt die 1080p-Font-Variante (14) und einen normalen feindlichen NPC.
`dragonflight_frame.png` hat als Export-Canvas 128×32 mit 86×4-Fenster; Padding ist Exportformat,
keine vom Original nachgewiesene zusätzliche Dekoration.

## Verwendung und Grenzen

Im Layout-Studio unter **Game nameplates** eine der zwei `source draft`-Varianten wählen.
Wechsel sind Undo-fähig, speichern im aktuellen Profil und exportieren als FN2. Neue Assets,
Outline-Form und Target-Bedingung benötigen zum Import mindestens Addon-Version 0.4.0.
Ältere FN1/FN2-Layouts bleiben lesbar. Neue Installationen starten mit dem Classic-Quellenlayout. Bestehende Profile werden nicht automatisch umgestaltet.

Diese Layouts sind aus Definitionen abgeleitet, **kein bestätigter 1:1-Pixelvergleich**.
Die Texturdateien stammen aus dem installierten Forever-Client; deren tatsächliche Version
kann von Classic/Dragonflight abweichen. Fehlende/deaktivierte Texturen werden nicht mit
gefälschten Originalgrafiken ersetzt. Atlasverfügbarkeit wird über öffentliche GetAtlasInfo-
Daten geprüft; abgelehnte/fehlende Image-Texturen bleiben ausgeblendet.

Noch nicht vollständig nachgebildet: dynamische Level-Farben/Skull, Elite-/PvP-/Quest-Icons,
Auren, Cast-Spark/Interrupt-Shield, pixelgenaue Font- und CVar-Scale-Anpassung. Hintergrund,
Health/Cast, Target-Kontur und Raidmarker bilden den jetzigen Strukturstand. Position über
der Welt-Unit und Stacking bleiben beim vorhandenen konservativen Forever-Overlay.
Die Originalgrafiken der anderen Spiele und fremde Schriften fehlen. Ein anderes Game-HUD
ist kein Ersatz. Der Editor kann die Quellenlayouts weiterhin frei ändern; danach sind sie
entsprechend eigene Varianten und keine unveränderten Originalreferenzen.

## Netzwerkzugriff für die weiteren Originalreferenzen

In den Cloud-Umgebungseinstellungen die bestehende Netzwerkfreigabe erhalten und mindestens
folgende konkrete Hostnamen ergänzen:

- `wiki.guildwars2.com`
- `www.swtor.com` und `forums.swtor.com`
- `help.elderscrollsonline.com` und `www.elderscrollsonline.com`
- `na.finalfantasyxiv.com`
- `news.blizzard.com`

Bild-CDN-Hosts erst ergänzen, wenn sie tatsächlich aus einer erreichbaren Referenzseite
ermittelt wurden. Die Allowlist wurde inzwischen mit dem Konfigurations-Lesetool geprüft.
Die oben genannten Hosts, `warcraft.wiki.gg`, `www.google.com`, `www.bing.com` und der tatsächlich
nachgewiesene FFXIV-Bildhost `lds-img.finalfantasyxiv.com` wurden als Entwurf gespeichert.
Bestehende Regeln und voreingestellte Git-/Paketdomains bleiben erhalten. Die CDN-Freigabe ist
noch nicht als aktiv nachgewiesen. Nach Änderung speichern/veröffentlichen und die betroffenen
Abrufe wiederholen. Originalbild, Version, Nameplate-Zustand und gemessene Pixelgeometrie
festhalten, erst dann das nächste Spiel-Layout nachbauen.
