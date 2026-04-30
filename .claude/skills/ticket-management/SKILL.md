---
name: ticket-management
description: Usa questa skill quando Matteo descrive in modo informale una feature, un bug o un miglioramento che vuole ticketare. Triggera su frasi come "voglio aggiungere", "c'è un bug", "potremmo", "mi piacerebbe", "serve un", "crea un ticket", "apri una issue", oppure quando Matteo descrive un problema/desiderio che chiaramente merita un ticket anche senza usare esplicitamente quelle parole. Trasforma l'input informale in una GitHub issue ben strutturata secondo le convenzioni del progetto BatterySafe.
---

# Ticket management

Trasforma input informali di Matteo in GitHub issue ben strutturate. Claude Code è il "tech lead junior" che fa refining e formattazione — Matteo controlla il *cosa*, questa skill controlla il *come*.

## Input atteso

Frasi informali in italiano come:
- "Voglio aggiungere la complicazione meteo"
- "C'è un bug: il colore batteria non cambia sotto il 20%"
- "Potremmo pulire i commenti obsoleti in launch.json"
- "Serve rinominare GraphicsWrapper.mc in GraphicsManager.mc"

## Output atteso

Una GitHub issue creata via `mcp__github__*` con:
- Titolo in inglese, imperativo, actionable
- Body strutturato secondo il template (sezione successiva)
- Labels appropriate
- Assignee: `mdeias`

## Flusso operativo

### Step 1 — Classifica il tipo

Identifica il tipo di ticket dall'input:

| Tipo | Indicatori linguistici | Esempi |
|------|----------------------|--------|
| `feat` | "voglio", "aggiungi", "implementa", "serve", "mi piacerebbe" | "voglio la complicazione meteo" |
| `fix` | "bug", "non funziona", "sbagliato", "rotto", "errore" | "il colore non cambia sotto il 20%" |
| `chore` | "pulisci", "rinomina", "rimuovi codice morto", "aggiorna" | "rinomina GraphicsWrapper.mc" |
| `refactor` | "riscrivi", "migliora struttura", "refactor" | "refactor di DataManager" |
| `docs` | "documenta", "aggiungi README", "aggiorna docs" | "aggiungi esempi in CLAUDE.md" |
| `spike` | "indaga", "capisci", "valuta fattibilità" | "valuta se passare a SDK 9.0" |

Se non è chiaro, chiedi una sola domanda diretta: *"È una feature nuova, un bug fix, o altro?"*

### Step 2 — Valuta la complessità

Scala di complessità per decidere quante domande fare:

- **Trivial** (0 domande): chore banali (rename, cleanup, comment update). Procedi direttamente.
- **Simple** (1-2 domande): bug fix chiari, feat piccoli ben definiti. Chiedi solo se servono dati critici.
- **Medium** (2-3 domande): feat con più sotto-componenti, bug con cause non ovvie.
- **Large** (3-5 domande, con disclaimer): feat che attraversano più layer, epiche travestite da feature. Prefissa: *"Questo sembra grande, ti faccio qualche domanda in più per capire lo scope."*

Se un input sembra **Large** e senza refining porterebbe a un ticket di più di 1 giornata di lavoro, valuta anche di proporre: *"Questo sembra più un'epic. Vogliamo scomporla in più ticket?"*

### Step 3 — Chiedi solo le ambiguità importanti

**Non chiedere dettagli minori assumibili.** Non chiedere mai:
- Nome esatto del branch (segue convenzione CLAUDE.md)
- Formato commit (segue Conventional Commits)
- Path dei file (deducibile dall'architettura)
- Convenzioni naming (già in CLAUDE.md)

**Chiedi sempre se ambiguo:**
- Scope (cosa è incluso, cosa è escluso)
- Acceptance criteria critici (come sapremo che funziona)
- Device target (se non default `epix2pro42mm`)
- Vincoli di performance (importante per watchface: consumo batteria)
- Interazione con componenti esistenti (es. rompe il contratto State/DataManager/Renderer?)

Chiedi **una domanda alla volta** in conversazione, non un questionario. Fermati a ogni risposta, valuta se ti basta, continua.

### Step 4 — Applica il template

Usa `templates/issue-template.md` come struttura base. Tutte le sezioni sono **obbligatorie**, ma per ticket trivial/simple alcune possono essere brevi (1 riga).

### Step 5 — User story formale

**Sempre** trasforma l'input informale in formato user story formale:

```
As <actor> (<role>)
I want <action/capability>
So that <value/benefit>
```

**Actor di default**:
- `As Matteo (developer)` → chore, refactor, docs, feat che riguarda il workflow
- `As Matteo (user)` → feat visibili sulla watchface (complicazioni, colori, layout)
- `As Matteo (maintainer)` → chore infrastrutturali, cleanup, tooling

Scegli in base al contenuto — non chiedere a Matteo.

### Step 6 — Proponi labels

Leggi le labels esistenti via `mcp__github__list_labels` o equivalente. Se il MCP non supporta la list, usa la lista hardcoded in `templates/labels-reference.md`.

Applica queste regole per scegliere labels:

**Type** (sempre una e una sola):
- `type:feat` → nuove feature visibili all'utente
- `type:fix` → bug fix
- `type:chore` → manutenzione, cleanup, tooling
- `type:refactor` → miglioramento struttura senza cambio funzionale
- `type:docs` → documentazione
- `type:enhancement` → miglioramento di una feature esistente

**Area** (una o più):
- `area:ui` → layout, colori, fonts, rendering
- `area:data` → DataManager, State, calcoli
- `area:battery` → ottimizzazioni consumo, throttling
- `area:tooling` → script, build, CI, configs
- `area:resources` → manifest, strings, images, layouts

**Priority** (sempre una):
- `priority:p0` → bloccante (app non funziona, store rifiuta)
- `priority:p1` → importante (feature principale, bug evidente)
- `priority:p2` → medio (miglioramento UX, bug minore)
- `priority:p3` → nice-to-have

**Claude-code-friendly** (applica se vero):
- `claude-code-friendly` → ticket adatto al workflow agentico (scope chiaro, AC testabili, no decisioni di prodotto aperte)

Se serve una label che non esiste, **informa Matteo** e chiedigli di crearla manualmente sul browser (il GitHub MCP non supporta la creazione di label — vedi LESSONS.md).

### Step 7 — Presenta e crea

Prima di creare, mostra a Matteo il ticket formattato con questo formato:

```
Propongo questo ticket:

Title: <titolo>
Labels: <labels>

Body:
---
<body completo>
---

Creo con questi parametri. Interrompimi se vuoi modificare.
```

Dopo la proposta, **procedi con la creazione via `mcp__github__create_issue`** senza aspettare un "ok" esplicito — Matteo ha avuto tempo di leggere e intervenire durante la proposta.

### Step 8 — Conferma

Dopo la creazione, riporta:
- Numero issue (`#N`)
- Link completo (`https://github.com/mdeias/BatterySafe/issues/N`)
- Eventuali avvertimenti (es. label mancanti da creare manualmente)

## Regole inviolabili

1. **Mai inventare scope**: se Matteo non ha detto X, X non finisce nel ticket. Se serve X, chiedi.
2. **Mai aggiungere feature "bonus"** non richieste. Se vedi un'opportunità adiacente, proponila come ticket separato alla fine.
3. **Mai tradurre testo tecnico** in italiano nel body del ticket. Body sempre in inglese.
4. **Mai usare emoji** nel body o nel titolo.
5. **Acceptance criteria sempre testabili**: ogni AC deve essere verificabile in modo binario (sì/no). Se un AC è vago ("deve funzionare bene"), riformulalo.
6. **Out of scope esplicito**: sempre. Anche solo "Out of scope: none for this ticket" è meglio di niente.

## Esempi di buone chiamate

Se Matteo scrive:
> "Voglio mostrare l'altitudine GPS come complicazione"

La tua risposta dovrebbe essere qualcosa come:
> "Prima di formalizzare, due domande:
> 1. BatterySafe per principio non usa sensori attivi (no GPS, vedi CLAUDE.md). L'altitudine la prenderemmo dall'ultimo valore cached da altre app? O vuoi davvero attivare GPS (rompe il principio)?
> 2. Posizione nel layout: dove la metteresti?"

Se Matteo scrive:
> "Rinomina GraphicsWrapper.mc in GraphicsManager.mc"

Procedi direttamente senza domande (è chore trivial).

## Vedi anche

- `templates/issue-template.md` — struttura completa del body
- `templates/labels-reference.md` — labels hardcoded (fallback se MCP non funziona)
- `.claude/CLAUDE.md` — convenzioni generali del progetto
