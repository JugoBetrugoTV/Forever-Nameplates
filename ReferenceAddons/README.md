# Vergleichs-Addons

`Plater/` enthält einen vollständigen, unveränderten Checkout von
[Tercioo/Plater-Nameplates](https://github.com/Tercioo/Plater-Nameplates), als Git-Submodule.
Stand: **bcc65131c3f5886fb53a36b3e7858d6c4bfe4f5d**, Datum 2026-10-09,
Tag `Plater-v657`. Der Download wurde am 2026-10-09 durchgeführt und der Commit geprüft.

GitHub zeigt den Ordner als Verweis auf genau diesen Upstream-Stand. Beim normalen Klonen
eines Repositories werden Submodule zunächst nicht ausgecheckt. Bei Bedarf nachladen:

```bash
git submodule update --init ReferenceAddons/Plater
```

Der Vergleich steht in [PLATER_REVIEW.md](PLATER_REVIEW.md). Lua Language Server ignoriert
`ReferenceAddons`, damit Platers Globals/Clientannahmen unsere Forever-Diagnostik nicht vermischen.
Der Ordner liegt außerhalb
von `ForeverNameplates/` und wird nicht in unser installierbares Addon-ZIP aufgenommen.
Der Checkout ist eine Entwicklungsreferenz; Platers TOCs zielen auf andere WoW-Versionen,
seine Forever-Kompatibilität wurde nicht geprüft. Seine Dateien werden unverändert
untersucht, inklusive aller vorhandenen Bibliotheks-/Font-Lizenzhinweise.

Für weitere Vergleiche diesen Commit beibehalten. Ein Update des Submodules ist eine
bewusste Änderung des Referenzstands und braucht einen aktualisierten Bericht.
