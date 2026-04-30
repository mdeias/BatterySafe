---
name: quality-gate
description: Usa questa skill prima di aprire una pull request per qualsiasi ticket di BatterySafe. Esegue una checklist di test reali (build, run, simulator, regression, warnings) selezionati in base al tipo di ticket. Se uno dei test critici fallisce, blocca l'apertura della PR. Triggera dopo l'implementazione del codice di un ticket, prima di "git push" e "create_pull_request" via MCP. Usata sempre nel workflow di chiusura ticket prima di consegnare al review umano.
---

# Quality gate

Ultima fase del workflow di un ticket: verifica che il lavoro sia di qualità sufficiente per entrare in PR. **Se i test bloccanti falliscono, NON aprire la PR** — riporta a Matteo cosa è andato storto e aspetta indicazioni.

## Quando attivare questa skill

Dopo aver implementato il codice di un ticket, prima di:
- `git push`
- `mcp__github__create_pull_request`

Quindi **dopo** commit locale, **prima** di pubblicare lavoro per la review.

## Filosofia di fondo

- **Failure su test bloccante = niente PR.** La PR è un attestato di qualità, non un work-in-progress.
- **Test selettivi per tipo ticket.** Non tutti i ticket meritano gli stessi test (es. un docs ticket non ha bisogno di build).
- **Test visivo della watchface = sempre umano.** La skill segnala "richiesta verifica visiva", non la sostituisce.
- **Warning ≠ failure.** Warning del compilatore o anomalie minori sono segnalati nella PR description, non bloccano.

## Mapping tipo ticket → test da eseguire

| Tipo ticket | Build | Run | Scenari multipli | No new warnings | Visual check |
|-------------|-------|-----|------------------|-----------------|--------------|
| `type:feat` (UI/rendering) | ✅ | ✅ | se applicabile | ✅ | ✅ obbligatorio |
| `type:feat` (data/logic) | ✅ | ✅ | se applicabile | ✅ | ✅ se output visibile |
| `type:fix` | ✅ | ✅ | ✅ se reproducer | ✅ | ✅ se UI-related |
| `type:refactor` | ✅ | ✅ | n/a | ✅ | ✅ se rendering |
| `type:chore` (tooling: build.sh, run.sh, scripts) | ✅ via flusso normale | ✅ | ✅ se branching logic | n/a | ✅ minimo |
| `type:chore` (rename, cleanup file) | ✅ | ✅ | n/a | ✅ | ✅ minimo |
| `type:chore` (docs, CLAUDE.md, skill) | ❌ | ❌ | n/a | n/a | ❌ |
| `type:enhancement` | ✅ | ✅ | ✅ | ✅ | ✅ se UI-related |
| `type:docs` | ❌ | ❌ | n/a | n/a | ❌ |

**Regola di fallback**: se non sei sicuro del tipo, esegui tutti i test (overhead accettabile rispetto a perdere bug).

## Checklist completa dei test

### 1. Build verde (BLOCCANTE)

Esegui:
```bash
./build.sh
```

**Atteso**: exit code 0, output contiene `BUILD SUCCESSFUL`, file `bin/BatterySafe-epix2pro42mm.prg` presente e creato/aggiornato.

**Se fallisce**: STOP. Riporta a Matteo l'errore esatto. Niente PR.

### 2. Run verde — cold start (BLOCCANTE per ticket che toccano run.sh)

Esegui:
```bash
osascript -e 'quit app "ConnectIQ"' 2>/dev/null
sleep 2
./run.sh
```

**Atteso**: exit code 0, output contiene "Connect IQ simulator not running — launching...", "Simulator ready.", "Launching ...". Nessun errore.

**Se fallisce**: STOP. Riporta a Matteo l'errore. Niente PR.

### 3. Run verde — warm start (BLOCCANTE per ticket che toccano run.sh)

Con simulator già avviato dal test 2:
```bash
./run.sh
```

**Atteso**: exit code 0, NON deve apparire "Connect IQ simulator not running — launching..." (skip dell'auto-launch). Ricarica la watchface direttamente.

**Se fallisce**: STOP. Riporta.

### 4. Test scenari multipli (BLOCCANTE se applicabile)

Per ticket che introducono branching logic (es. discovery con priorità, fix con multiple cause possibili), enumera gli scenari nelle AC e testali tutti.

**Pattern di test isolato consigliato**: usa env variables di override (vedi `build.sh` con `GARMIN_VSCODE_SETTINGS` e `GARMIN_STANDARD_KEY_PATH` come riferimento). Mai modificare file in `~/Library/`, sempre isolare in `/tmp/`.

**Se uno scenario fallisce**: STOP.

### 5. No new warnings (SEGNALATO, non bloccante)

Esegui `./build.sh` e cattura lo stderr. Conta i warning del compilatore monkeyc.

**Atteso**: nessun warning nuovo rispetto al main / develop. (Warnings preesistenti vanno tracciati ma non bloccano.)

**Se ci sono warning nuovi**: NON bloccare la PR, ma includere nella description:
```
⚠️ N new compiler warnings detected:
- <line:col> <warning text>
- ...
Review and decide if to fix in this ticket or defer.
```

### 6. Regression check (BLOCCANTE per modifiche a codice esistente)

Per ticket che modificano file già esistenti (non solo aggiunte), verifica che il "uso normale" funzioni ancora.

**Esempio concreto**: se il ticket modifica `build.sh`, esegui:
```bash
./build.sh
```
con env vars come Matteo le ha (cioè quelle reali del suo `~/.zshrc`). Deve produrre lo stesso comportamento di prima del ticket.

**Se rotto**: STOP. Hai introdotto regressione.

### 7. Visual check (UMANO, sempre richiesto se UI-related)

**Non eseguibile da Claude Code.** Quando uno dei test del flusso ha richiesto avvio del simulator, Matteo dovrà verificare visivamente che la watchface appaia correttamente prima di mergiare la PR.

**Azione skill**: includi sempre nella PR description la riga:
```
⚠️ **Visual verification required by Matteo before merge**: please confirm that the watchface renders correctly in the simulator.
```

Per ticket che non toccano UI/rendering (es. modifica a script di build), puoi versione meno enfatica:
```
Visual check (optional): no UI changes expected, but simulator boot was successful.
```

## Procedura operativa

### Step 1 — Identifica i test da eseguire

Leggi le labels del ticket (specialmente `type:`). Consulta la mapping table. Identifica i test applicabili.

### Step 2 — Esegui i test in ordine

Per ogni test bloccante: esegui, controlla atteso, prosegui solo se ok.

Se uno fallisce:
- **STOP** — non procedere con i test successivi
- Riporta a Matteo:
  - Quale test ha fallito
  - Output exatto dell'errore
  - Diagnosi rapida (se ovvia) o "richiesta diagnosi"
- Aspetta indicazioni prima di procedere

### Step 3 — Compila il quality-gate report

Una volta passati tutti i test bloccanti, prepara una sezione da includere nella PR description:

```markdown
## Quality gate report

Tests executed:
- ✅ Build successful (exit 0, BatterySafe-epix2pro42mm.prg created)
- ✅ Run cold start (simulator launched, watchface loaded, exit 0)
- ✅ Run warm start (skipped auto-launch, watchface reloaded, exit 0)
- ✅ Scenario tests (4/4 passed: env / vscode / standard / fail)
- ⚠️ 2 new compiler warnings detected (see below)
- ✅ Regression check (build.sh works with default env vars)

⚠️ Visual verification required by Matteo before merge: please confirm that the watchface renders correctly in the simulator.

### Warnings detail
- src/Wrapper/GraphicsManager.mc:42:5 — Unused variable `_temp`
- src/core/State.mc:12:8 — Implicit type cast
```

### Step 4 — Procedi con `git push` e creazione PR

Solo a questo punto, e solo se step 2 è andato pulito.

### Step 5 — In caso di fallimento durante step 2

Non distruggere il branch, non rollbacka i commit. Lascia tutto in stato visibile a Matteo, con commit locali ancora presenti, così che possa decidere lui se:
- Fixare e ritentare
- Abbandonare e ricominciare diversamente
- Aprire la PR comunque (override esplicito)

## Regole inviolabili

1. **Mai aprire una PR se un test bloccante fallisce.** Questa è la regola più importante.
2. **Mai falsificare risultati di test.** Se exit code è 1, è 1. Non riprovare 5 volte sperando che vada.
3. **Mai modificare file in `~/Library/`** durante i test scenari. Sempre isolare in `/tmp/`.
4. **Mai chiudere il simulator durante un test reale dell'utente.** Solo nei test isolati eseguiti dalla skill.
5. **Sempre includere "Visual verification required" nella PR description** se almeno uno dei test ha richiesto run.sh.
6. **Sempre riportare warning nuovi**, anche se non bloccano.
7. **Mai assumere che "Claude ha testato" basti.** I test interni sono complementari ai test umani, mai sostitutivi.

## Esempi pratici

### Esempio 1 — Ticket type:chore (rename file)

Ticket: rename GraphicsWrapper.mc → GraphicsManager.mc

Mapping table → tutti i test sono applicabili (build, run, regression, no warnings, visual minimo).

Test eseguiti:
1. ✅ `./build.sh` → BUILD SUCCESSFUL
2. ✅ `./run.sh` cold → simulator ok, watchface load
3. ✅ Regression → build con env vars normali funziona
4. ✅ No new warnings
5. Visual check incluso nella PR description

### Esempio 2 — Ticket type:docs (aggiornamento CLAUDE.md)

Ticket: aggiornare CLAUDE.md sezione comandi

Mapping table → solo "no test required". Skip tutti.

PR description: nessuna sezione "Quality gate report" (o sezione minima "No code changes — no tests applicable").

### Esempio 3 — Ticket type:fix (bug colore batteria sotto 20%)

Ticket: fix battery color update under 20%

Mapping table → tutti i test, **e visual check obbligatorio + scenario manuale per riprodurre il bug fixato**.

Test eseguiti:
1. ✅ Build
2. ✅ Run cold
3. ✅ Scenario reproducer del bug (es. mock battery a 25% poi 18% e verifica colori in stati intermedi)
4. ✅ Regression check (battery > 20% comportamento invariato)
5. PR description include: "⚠️ Visual verification: please verify color transition at 20% threshold."

## Vedi anche

- `.claude/CLAUDE.md` — convenzioni progetto, comandi base
- `.claude/skills/ticket-management/SKILL.md` — come si valutano i tipi di ticket
- `.claude/LESSONS.md` — pattern emersi dai cicli precedenti, in particolare:
  - "Test di Claude Code ≠ validazione reale" (informa: visual check sempre umano)
  - "Race condition: processo esiste ≠ ready" (informa: test run.sh richiede sleep)
  - "GitHub MCP non supporta creazione labels" (informa: workaround manuale)
