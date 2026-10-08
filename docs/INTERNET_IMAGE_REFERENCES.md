# Originalbilder: Internetrecherche am 2026-10-08

## FFXIV: offizielle Bildkandidaten gefunden

Der [offizielle UI-Guide](https://na.finalfantasyxiv.com/uiguide/battle/battle-np/battle_np_bar.html)
erklärt „Why do enemy display names change color?“ und enthält diese vier Original-Bildlinks.
Die HTML-Seite wurde erfolgreich abgerufen. Die Bilddateien sind hier wegen der getrennten
CDN-Netzwerkfreigabe noch nicht abrufbar: `Tunnel connection failed: 403 Forbidden`.
Sie wurden daher **noch nicht angesehen, vermessen oder als fertige Nameplate nachgebaut**.
Die Seite nennt für die Abbildungen keine konkrete Patchversion oder UI-Skalierung.
Links und Zustände sind belegt; die Eignung als vollständige Healthbar-/Rahmenreferenz ist offen.

| Zustand laut offiziellem Guide | Originalbild |
| --- | --- |
| Unclaimed | [Bild 1](https://lds-img.finalfantasyxiv.com/uiguide/na/5e/9e139cf87504d0b6e816c272c1515abd38faed.jpg) |
| Claimed by you or your party | [Bild 2](https://lds-img.finalfantasyxiv.com/uiguide/na/51/66741e445c904df9cd7f06f839b03551192e53.jpg) |
| Unclaimed, yet attacking you or your party | [Bild 3](https://lds-img.finalfantasyxiv.com/uiguide/na/71/bfd57bcf3542c45e03da53cefbd8999f9d1057.jpg) |
| Claimed by another party or individual | [Bild 4](https://lds-img.finalfantasyxiv.com/uiguide/na/37/0faba07d80ef234d73f8e584613faf85630ff5.jpg) |

Diese Originaldateien bleiben externe Referenzen; sie werden nicht in das Addon kopiert.
Für den Bildgenerator ein geeignetes Originalbild herunterladen und zusammen mit dem
jeweiligen Prompt anhängen. Ein Markdown-Link allein übermittelt keine Referenzpixel.

## Weitere Abrufe und verworfene Suchtreffer

- Google und Bing sind inzwischen per HTTP erreichbar. Google lieferte eine JavaScript-/Support-Seite;
  Bing-Bildtreffer waren überwiegend sachfremd oder WoW-Marketingbilder, keine belegten Original-Nameplates.
  Solche Treffer wurden nicht als Nameplate-Vorlage übernommen.
- `wiki.guildwars2.com/wiki/Health_bar` und `warcraft.wiki.gg/wiki/Nameplate` antworteten weiterhin
  mit HTTP 403, jetzt als Seitenantwort statt der ursprünglichen CONNECT-Sperre.
- SWTOR-Forumstartseite erreichbar; gezielte Forumssuche `search/?q=nameplates&type=forums_topic`
  antwortete mit HTTP 403. Avatare/Logos der Startseite sind keine Nameplate-Referenzen.
- ESO-Supportstartseite und Blizzard-Newsstartseite erreichbar; keine geeignete Nameplate-Grafik
  daraus bestätigt. Der frühere geratene FFXIV-Link `know/know-name/nameplate.html` liefert 404
  und wurde durch den tatsächlich im Guide gefundenen Link oben ersetzt.

Für Classic/Dragonflight bestehen weiterhin die [gepinnten FrameXML-Referenzen](NAMEPLATE_REFERENCES.md).
Ein Original-Pixelvergleich ist bei keinem der sieben Spiele abgeschlossen.

## Netzwerkentwurf

Die aktuellen benutzerdefinierten Regeln wurden vor jeder Änderung gelesen und erhalten;
die voreingestellten Paket-/Git-Domains bleiben automatisch erhalten. Gespeichert wurden die
Spielquellen aus `NAMEPLATE_REFERENCES.md`, `warcraft.wiki.gg`, `www.google.com`, `www.bing.com`
und der aus dem FFXIV-Guide nachgewiesene Bildhost **`lds-img.finalfantasyxiv.com`**.
Speichern eines Entwurfs beweist keine Laufzeitaktivierung. Für den weiter gesperrten Bildhost
den Entwurf in den Cloud-Umgebungseinstellungen prüfen/speichern und die Umgebung veröffentlichen;
danach den Bildabruf wiederholen. Es werden keine Quellenmaße aus ungeprüften Bildern erfunden.
