"""Keep the reviewable artwork prompts in sync with the import contracts."""
import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def render():
    contract = json.loads((ROOT / "Tools/art_requests.json").read_text())
    rows = [
        "# Nameplate-Grafikaufträge — sieben Originalspiele", "",
        "Ausschließlich Nameplates über Units aus WoW Classic, Dragonflight, GW2, SWTOR, ESO, FFXIV und Diablo IV.",
        "Keine Target-Portraitframes, Player-HUDs, Bossleisten am Bildschirmrand oder GUI-Artwork.",
        "Die Liste enthält sieben Rahmen sowie die separat nötige FFXIV-HP-Füllung und den Gegnerindikator.", "",
        "## Originalreferenzen und Maßstab", "",
        "Classic/Dragonflight beruhen auf gepinnten FrameXML-Definitionen. Die vier offiziellen FFXIV-Bilder",
        "wurden heruntergeladen und angesehen. [Originalbilder und Vermessung](docs/INTERNET_IMAGE_REFERENCES.md).",
        "Die FFXIV-Maße beziehen sich auf JPEG-Pixel; Patch/UI-Scale sind unbekannt, Kanten etwa ±2 Pixel unsicher.",
        "Der FFXIV-Entwurf bildet die rote beanspruchte Gegner-Plate ab. Originalschrift, Spawn-Buchstabe und",
        "automatische FFXIV-Claim-Zustände sind im WoW-Client nicht nachgewiesen. Keine 1:1-Abnahme behauptet.",
        "Die anderen vier Fremdspiel-Referenzen fehlen weiterhin; deren Maße sind vorläufig.", "",
        "## Assets liefern", "",
        "Jeweils das tatsächliche ORIGINAL-NAMEPLATE-BILD zusammen mit dem Prompt an den Bildgenerator anhängen.",
        "Ein Markdown-Link allein liefert keine Referenzpixel. Die offiziellen FFXIV-JPEGs sind unten verlinkt.",
        "Die fertigen PNGs in `ArtDrop/` ablegen, `python Tools/import_art.py` ausführen und im Spiel `/reload`.",
        "Der FFXIV-Eintrag wird erst mit `fantasy_frame.png`, `ffxiv_hp_fill.png` und `ffxiv_enemy_icon.png` auswählbar.",
        "Rahmen/Icons benötigen echte Transparenz; die HP-Füllung benötigt vollständig deckende RGBA-Pixel.",
        "Fehler bewahren vorhandene Dateien. Frühere Vertragsmaße werden als obsolete markiert und nicht gelöscht.",
        "Technische PNG- und Alpha-Prüfungen bestätigen keine Originaltreue; bei 100 % neben der Vorlage vergleichen.", "",
        "Diese Datei entsteht aus `Tools/art_requests.json`: `python Tools/art_prompts.py`.", "",
    ]
    batch = None
    for asset in sorted(contract["assets"], key=lambda a: a["batch"]):
        if batch != asset["batch"]:
            batch = asset["batch"]
            rows.extend([f"## Batch {batch}", ""])
        ref = asset["reference"]
        rows.extend([f"### {ref['game']} — {asset['file']}", "",
                     f"- Version: **{ref.get('version') or 'noch nicht verifiziert'}**.",
                     f"- Status: `{ref['status']}`.",
                     f"- Canvas: **{asset['width']} × {asset['height']}**.",
                     f"- Aufgabe: {asset['purpose']}.",
                     "- Alpha: " + ("echte Transparenz" if asset["alpha"] else "vollständig deckendes RGBA, alpha=255") + "."])
        if asset.get("window"):
            rows.append(f"- Healthöffnung: **{asset['window'][0]} × {asset['window'][1]}**; " +
                        (f"Box `{asset['window_box']}`." if asset.get("window_box") else "zentriert."))
        if ref.get("source_url"):
            rows.append(f"- [Quelle]({ref['source_url']}).")
        else:
            rows.append("- Originalreferenz fehlt; keine bestätigte Bildgeometrie.")
        if ref.get("image_urls"):
            rows.append("- Originalbilder: " + " · ".join(f"[Bild {i}]({url})" for i, url in enumerate(ref["image_urls"], 1)) + ".")
        rows.extend(["", "```text", asset["prompt"], "```", ""])
    return "\n".join(rows)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    path = ROOT / "ART_ASSET_REQUESTS.md"
    content = render()
    if args.check:
        if path.read_text() != content:
            raise SystemExit("Artwork prompts are stale; run python Tools/art_prompts.py")
        print("Artwork prompts match import contracts")
    else:
        path.write_text(content)
        print(path)
