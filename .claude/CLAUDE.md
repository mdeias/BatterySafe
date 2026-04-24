# BatterySafe — Contesto per Claude Code

File letto automaticamente a ogni avvio di sessione Claude Code in questo repo. Contiene il contesto sempre-attivo del progetto. Conoscenza dettagliata e procedure vivono nelle skill in `.claude/skills/`.

## Cosa è BatterySafe

Watchface Garmin scritta in Monkey C. Principio guida: **consumare la minima CPU possibile per massimizzare l'autonomia della batteria**, soprattutto su dispositivi AMOLED con Always-On Display attivo.

Non usa sensori attivi (no HR, no GPS, no accelerometro). Solo batteria e orologio di sistema.

**Regola numero uno**: ogni modifica al codice deve rispettare il principio di minimo consumo. Se una feature richiede un timer aggiuntivo, polling frequente, o lettura sensori, è quasi sempre **da rifiutare** o ridisegnare prima di implementare.

## Stack

- **Linguaggio**: Monkey C
- **SDK**: Connect IQ ≥ 5.2.0
- **Target devices**: 29 dispositivi Garmin fascia premium (Fenix 7/8, Epix 2, FR 265/965, MARQ2, ecc.)
- **Device di default** per build/test rapidi: `epix2`
- **IDE di sviluppo**: VS Code con Monkey C extension

## Architettura (inviolabile)

Tre layer con responsabilità nette:

```
State → data container (solo stato, niente logica)
  ↓
DataManager → tutta la logica (calcoli, fetch system stats, formatting stringhe)
  ↓
Renderer → solo draw su Dc (mai calcoli, mai fetch dati)
```

Regole:
- **Renderer non legge mai da `System.*`**. Tutti i dati li riceve via `State`.
- **State non ha metodi con logica**. È puro data container.
- **DataManager è l'unico punto di accesso a `System.getSystemStats()`, `System.getClockTime()`, etc.**

Se una modifica richiede logica in un renderer o accesso system in State, fermati e chiedi conferma prima di procedere.

## Convenzioni naming

| Elemento | Convenzione | Esempio |
|---------|------------|---------|
| Field privati | `_camelCase` | `_state`, `_fontTop` |
| Classi | `PascalCase`, una per file | `BatterySafeView` |
| Moduli | `PascalCase` | `Palette`, `FontManager` |
| Costanti | `UPPER_SNAKE_CASE` | `BASE_SIZE`, `MAX_RETRIES` |
| Metodi | `camelCase` | `refreshFast()`, `onUpdate()` |

## Pattern fondamentali

**Scaling**: tutte le coordinate usano `s = screenSize / 390.0`. `BASE_SIZE = 390.0` è la reference.

**Dirty flags**: sistema di flag granulari (`dirtyTime`, `dirtyTopLines`, `dirtyHeader`, `dirtyMid`, `dirtyFooter`) per ridisegnare solo le sezioni cambiate. Massimo un redraw al minuto via throttle timestamp-based.

**Stringhe mai null**: nelle stringhe cached di `State` non deve mai esserci `null`. Ci sono fallback costanti in `State`.

**Stringhe costruite in DataManager**: renderer non fa mai concat o format, solo `dc.drawText(...)` con stringhe già pronte.

## Comandi

> TODO: Matteo verificherà e completerà questa sezione con i comandi esatti che usa normalmente (developer key path, wrapper eventuali, alias). Non eseguire build/run prima che questa sezione sia completa.

Stub dei comandi attesi (da confermare):

```bash
# Build per device di default (epix2)
monkeyc -d epix2 -f monkey.jungle -o bin/BatterySafe-epix2.prg -y <developer_key>

# Run nel simulatore
monkeydo bin/BatterySafe-epix2.prg epix2

# Build release package per Connect IQ Store
monkeyc -e -f monkey.jungle -o bin/BatterySafe.iq -y <developer_key>
```

## Git workflow

Progetto personale, singolo sviluppatore. Flusso semplificato:

- **Branch principale di sviluppo**: `develop`
- **Branch di release**: `main`
- **Feature branch**: `feat/<id>-<slug>`, `fix/<id>-<slug>`, `chore/<slug>`
- **Main**: mai commit diretti, solo merge di PR approvate da `develop`
- **Develop**: commit diretti ammessi per ora (no barriera hook)
- **Commit format**: Conventional Commits in inglese (`feat:`, `fix:`, `chore:`, `refactor:`, `docs:`)

## Linguaggio

- **Conversazioni con Matteo nel terminale**: italiano
- **Skill, CLAUDE.md, istruzioni interne**: italiano
- **Codice, commit message, issue GitHub, PR description, acceptance criteria**: inglese
- **LESSONS.md**: italiano

## Regole operative

**Cose da non fare mai senza chiedere**:
- Modificare `manifest.xml` (target devices, permessi, versione)
- Modificare `monkey.jungle` (build config)
- Fare commit direttamente su `main`
- Fare `git push --force` su qualsiasi branch
- Rimuovere file di risorse (`resources/**`) senza verificare che non siano referenziati
- Modificare `.claude/settings.json` autonomamente

**Cose che puoi fare autonomamente**:
- Leggere qualsiasi file nel repo
- Eseguire `monkeyc` per build locali (quando la sezione Comandi sarà completa)
- Creare feature branch e fare commit locali su di essi
- Lanciare `git status`, `git diff`, `git log`, `git branch`
- Usare il GitHub MCP per leggere/creare issue e PR

## Memoria evolutiva

Vedi `.claude/LESSONS.md` per apprendimenti dai cicli precedenti. Aggiornalo quando emergono pattern o errori significativi.
