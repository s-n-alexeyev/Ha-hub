# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.2.0] - 2026-11-23

This release puts a language into the widget. Until now the interface was English
with one Italian translation compiled through gettext; the strings are now held in
per-language catalogs that the tests keep complete, and the language chosen in
Settings is the language the running widget paints.

### Added
- 32 languages in all: Belarusian, Bulgarian, Bosnian, Chinese, Czech, Danish, Dutch,
  English, Estonian, Finnish, French, German, Icelandic, Kazakh, Latvian, Lithuanian,
  Norwegian (Bokmål and Nynorsk), Polish, Portuguese (and Brazilian Portuguese),
  Romanian, Russian, Serbian (Cyrillic and Latin), Slovak, Slovenian, Spanish, Swedish,
  Turkish, Ukrainian. Each catalog holds every string the interface asks for — 251 keys
  — and the placeholders in each value are checked.
- `contents/l10n/`: the language list, the catalogs, and a `Loc` singleton that
  answers a translation request from the language it was last given.
- A language picker in General settings, listing every language by the name it writes
  for itself, with "System language" first. The dialog repaints as soon as one is
  picked, so a language can be tried before it is stored.
- The widget's description in the store, in every language the widget itself speaks —
  a language offered in settings without a `Description[<code>]` reads as English to
  someone browsing in it.
- `contents/ui/components/LanguageBridge.qml`: the piece that gets a saved language
  into a running engine, and into each of the three engines the applet has — the
  popup, the settings dialog and the dialog's list of categories.
- The plain helper functions now take a translator from QML, so the words a helper
  chooses by itself (a binary sensor's state, decided from the entity's class) follow
  the configured language rather than the system's.
- Tests: `node --test tests/js/*.test.js` and `tests/run_qml_tests.sh`, covering the
  catalogs, the language matching, the bridge's contract, and that every relative
  import in the QML resolves. GitHub Actions runs them on every pull request
  (`.github/workflows/ci.yml`); a tag publishes the packaged widget
  (`.github/workflows/release.yml`).
- `scripts/make-plasmoid.sh` builds the `.plasmoid` from `metadata.json`, and
  `scripts/new-catalog.mjs` registers a new language the way the tests expect.

### Changed
- Interface strings come from `contents/l10n/catalogs/` instead of gettext. One
  plural form ("1 entity" / "5 entities") is left on Plasma's `i18np()`, so
  `translate/*.po` and `contents/locale/` keep a job.
- Version numbering moved off the `-beta` suffix, so the release checks that a
  published version is a plain `major.minor.patch` can pass.

## [1.1.0-beta1]

Their line: three views (rows, tiles, Liquid Glass cards), reliable reconnect with
exponential back-off and a ping watchdog, category tabs and search, 49 bundled icons,
Italian through gettext. See the pull request that brought it in.
