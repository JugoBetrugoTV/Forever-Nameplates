# Originalbilder: Internetrecherche am 2026-10-08

## FFXIV: Originalbilder heruntergeladen und angesehen

Der [offizielle UI-Guide](https://na.finalfantasyxiv.com/uiguide/battle/battle-np/battle_np_bar.html) erklärt „Why do enemy display names change color?“.
Die Seite und alle vier JPEGs wurden erfolgreich per HTTP 200 abgerufen und angesehen.
Es sind echte Overhead-Gegner-Nameplates, keine HUDs. Alle Bilder haben **896×192 Pixel**.
Die frühere CONNECT-403-Sperre des Bildhosts ist aufgehoben. Patch und UI-Skalierung der Vorlage bleiben unbekannt.

Die gelbe unbeanspruchte und die orange angreifende Ansicht zeigen hier keine HP-Bar;
die rote beanspruchte und violette fremd beanspruchte Ansicht zeigen eine. Daraus wird keine
allgemeine Anzeige-Regel oder WoW-Claim-Erkennung abgeleitet.

## Tatsächliche Originalansichten

Unbeansprucht:

![Original FFXIV: Unbeansprucht](https://lds-img.finalfantasyxiv.com/uiguide/na/5e/9e139cf87504d0b6e816c272c1515abd38faed.jpg)

Von eigener Gruppe beansprucht — Referenz des Layout-Entwurfs:

![Original FFXIV: Von eigener Gruppe beansprucht — Referenz des Layout-Entwurfs](https://lds-img.finalfantasyxiv.com/uiguide/na/51/66741e445c904df9cd7f06f839b03551192e53.jpg)

Unbeansprucht, greift eigene Gruppe an:

![Original FFXIV: Unbeansprucht, greift eigene Gruppe an](https://lds-img.finalfantasyxiv.com/uiguide/na/71/bfd57bcf3542c45e03da53cefbd8999f9d1057.jpg)

Von anderer Gruppe beansprucht:

![Original FFXIV: Von anderer Gruppe beansprucht](https://lds-img.finalfantasyxiv.com/uiguide/na/37/0faba07d80ef234d73f8e584613faf85630ff5.jpg)

## Vermessene rote Plate

Koordinaten `[links, oben, rechts, unten]`, rechte/untere Grenzen exklusiv. JPEG-Artefakte,
Weichzeichnung und unbekannte Originalskalierung ergeben etwa **±2 Pixel Kantenunsicherheit**.
Es sind **Quellbild-Pixel, keine nachgewiesenen FFXIV- oder WoW-UI-Punkte**.

| Bereich | Arbeitsmessung |
| --- | --- |
| HP-Bar einschließlich Schatten | `[334,102,582,122]`, 248×20 |
| Sichtbarer Bar-Körper | `[336,104,580,120]`, 244×16 |
| Fill-/Empty-Innenraum | `[340,106,576,118]`, 236×12 |
| Levelgruppe `Lv3` | ungefähr `[308,74,380,104]` |
| Name `Lost Lamb` | ungefähr `[384,74,574,104]` |
| Cyanfarbener Gegnerindikator | ungefähr `[278,74,304,104]` |
| Spawn-Buchstabe `A` | ungefähr `[578,72,610,104]` |

Der Rahmenexport hat 256×32 Pixel: Padding 4 horizontal und 6 vertikal um die 248×20-Referenz.
Die transparente Fill-Öffnung liegt bei `[10,10,246,22]`. Separate Füllung: 236×12 deckendes RGBA;
Gegnerindikator: 32×32 mit echter Transparenz. Die ursprünglichen 256×64/182×12 waren vorläufig
und wurden korrigiert. Alte Artefakte werden beim Import als obsolete markiert und bewahrt.

JPEG-Samples: oben etwa RGB(234,170,171), Hauptfill RGB(253,187,189), leerer Rest RGB(72,25,28).
Das sind Beobachtungen, keine originalen Client-Farbkonstanten. Hashes und Messdaten stehen in
[ffxiv_reference_measurements.json](ffxiv_reference_measurements.json).

## Umsetzung in 0.5.0

Entwurf mit importierter HP-Füllung, Rahmen und Cyan-Icon; Name/Level darüber, helle Textkontur
und `Lv`-Präfix bei öffentlichen Levelwerten. Erst nach Import aller drei Assets und `/reload`
im Game-Nameplates-Menü auswählbar. [Konkrete PNG-Aufträge und Prompts](../ART_ASSET_REQUESTS.md).

Offen bleiben die Originalschrift (**Arial Narrow ist nur ein lokaler Fallback**), Spawn-Buchstabe,
echte UI-Skalierung und FFXIV-Claim-Zustände. Nur die rote Vorlage ist als Layout vorbereitet;
die anderen drei Farben sind Bildreferenzen, keine implementierten Zustandsvarianten.
Es wurde kein fertiges Asset erfunden und keine Spielgrafik in das Addon kopiert.
Originalbilder zusammen mit den Prompts beim Bildgenerator anhängen: Ein Markdown-Link allein liefert keine Referenzpixel.

## Weitere Abrufe und verworfene Suchtreffer

- GW2-Wiki, Warcraft-Wiki und gezielte SWTOR-Forumssuche wurden erneut geprüft und antworten HTTP 403.
- SWTOR-Forumstartseite, ESO-Support und Blizzard-Newsstartseite sind erreichbar; Avatare/Logos sind keine Nameplate-Vorlagen.
- Google lieferte eine JavaScript-/Support-Seite. Bing-Bildsuche und gezielte RSS-Suchen mit/ohne exakte Spielnamen
  lieferten überwiegend sachfremde Treffer oder allgemeine Spielseiten. Keine weitere geeignete Nameplate bestätigt.
- Der frühere geratene FFXIV-Link `know/know-name/nameplate.html` liefert 404; die tatsächliche Guide-Seite steht oben.

Für Classic/Dragonflight bestehen weiterhin die [gepinnten FrameXML-Referenzen](NAMEPLATE_REFERENCES.md).
Ein vollständiger Original-Pixelvergleich des Addons ist bei keinem der sieben Spiele abgeschlossen.

## Netzwerkstand

Die benutzerdefinierten Regeln wurden vor Änderungen gelesen und erhalten; voreingestellte Git-/Paketdomains bleiben erhalten.
Die Spielquellen, `warcraft.wiki.gg`, Google/Bing und der belegte Bildhost `lds-img.finalfantasyxiv.com` sind als Entwurf gespeichert.
**FFXIV-CDN-Zugriff ist nun durch vier erfolgreiche JPEG-Abrufe bestätigt; eine weitere Freigabe für diese Bilder ist nicht nötig.**
Der Agent hat die Umgebung nicht selbst publiziert. Die übrigen 403-Antworten sind getrennte Abrufprobleme.
