# LESSONS — BatterySafe

Memoria storica del workflow Claude Code per BatterySafe. Accumula osservazioni concrete dai cicli completati. Periodicamente le lessons ricorrenti vengono distillate nelle skill (`.claude/skills/`) o in `CLAUDE.md`.

**Convenzioni:**
- Lingua: italiano. Frammenti tecnici (path, comandi, nomi binari) in inglese.
- Una lesson per episodio. Mai accorpare lessons diverse nella stessa voce.
- Quando una lesson è promossa in skill o CLAUDE.md, marcarla come `[PROMOSSA → <destinazione>]` invece di eliminarla, così resta tracciabile.
- Refactor periodico: ogni 6-8 settimane (o ogni 15-20 ticket) si rivede il file, si promuovono lessons stabili, si eliminano quelle obsolete.

---

## 2026-04-25 — `pgrep -f` matcha falsi positivi (Ticket #17)

**Cosa è successo**

Durante l'implementazione di `run.sh` con auto-launch del simulatore, il check `pgrep -f "ConnectIQ"` ha matchato 28 processi LanguageServer.jar (Java) attivi sul sistema. Questi processi hanno nella loro command line il path della SDK Garmin (`.../connectiq-sdk-mac-8.3.0/bin/LanguageServer.jar`), che contiene la stringa `ConnectIQ`. Risultato: lo script vedeva sempre il simulatore come "running" e saltava l'auto-launch.

**Cosa abbiamo imparato**

`pgrep -f "stringa"` cerca nella command line completa del processo, non solo nel nome. Una stringa che sembra specifica (`ConnectIQ`) può comparire dentro path, argomenti CLASSPATH Java, variabili d'ambiente, e matchare processi non correlati.

**Implicazione operativa**

Quando si usa `pgrep -f` per rilevare processi specifici, il pattern deve essere:
- Abbastanza unico da non matchare path di tooling (es. SDK directories)
- Preferibilmente specifico al binario reale (es. `ConnectIQ.app/Contents/MacOS` invece di solo `ConnectIQ`)
- Verificato empiricamente con `pgrep -fl` (con `-l` per vedere quali processi matchano) prima di usarlo in script production

**Promozione candidata**

→ Da promuovere a una futura skill `shell-scripting-conventions` se si scriverà altro tooling shell. Per ora resta qui come riferimento.

---

## 2026-04-25 — Binario reale del simulatore Connect IQ (Ticket #17)

**Cosa è successo**

Cercando come rilevare se il simulatore Connect IQ fosse in esecuzione, abbiamo scoperto che il processo non si chiama `ConnectIQ` ma è il binario chiamato `simulator` dentro l'app bundle `ConnectIQ.app`. Path completo:
```
~/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-X.Y.Z-.../bin/ConnectIQ.app/Contents/MacOS/simulator
```

**Cosa abbiamo imparato**

Le app macOS distribuite come `.app` bundle hanno spesso un binario interno con nome diverso dall'app. Rilevare il processo solo per nome è insufficiente — serve cercare il path completo del binario, non quello dell'app.

**Implicazione operativa**

Per rilevare il simulatore Connect IQ in script futuri, usare il pattern:
```bash
pgrep -f "ConnectIQ.app/Contents/MacOS"
```
Discriminatore perfetto: ritorna 0 processi quando il simulatore è chiuso, 1 PID col path completo quando è aperto.

**Promozione candidata**

→ Da promuovere a una futura skill `monkey-c-conventions` (sezione "Tooling e simulator").

---

## 2026-04-25 — Race condition: processo esiste ≠ processo ready (Ticket #17)

**Cosa è successo**

Dopo aver lanciato il simulatore con `open -a ConnectIQ`, il polling che controllava la presenza del processo `simulator` rilevava il processo ben prima che fosse effettivamente pronto a ricevere connessioni da `monkeydo`. Risultato: `monkeydo` veniva chiamato troppo presto, falliva con "Unable to connect to simulator".

Test empirico: con `sleep 10` fisso dopo `open -a ConnectIQ`, monkeydo funziona affidabilmente. Quindi sul Mac di test la "vera readiness" arriva tra "comparsa del processo" e ~10 secondi dopo l'apertura.

**Cosa abbiamo imparato**

Il fatto che un processo esista nei tool di sistema (`pgrep`, `ps`) non implica che sia funzionalmente pronto. Per applicazioni complesse con UI grafica, server interno, plugin loading, ecc., serve un buffer aggiuntivo o un check di readiness più sofisticato.

**Implicazione operativa**

Per il simulatore Connect IQ specificamente: aggiungere un buffer fisso di **5 secondi** dopo la rilevazione del processo via pgrep. Soluzione semplice ma pragmatica.

Approccio più robusto (ticket follow-up futuro): retry su `monkeydo` stesso quando fallisce con "Unable to connect". Si adatterebbe automaticamente al ritmo della macchina invece di usare un valore fisso.

**Promozione candidata**

→ Da promuovere a `monkey-c-conventions` insieme alla lesson "Binario reale del simulatore". I due insieme formano la sezione "Tooling e simulator".

---

## 2026-04-25 — Test di Claude Code ≠ validazione reale (trasversale)

**Cosa è successo**

Nel ticket #17, Claude Code ha implementato l'auto-launch, eseguito test interni nel suo ambiente (verifica `pgrep` su processi esistenti, formato messaggi di errore, exit code), e dichiarato "logica corretta". Tutti i suoi test passavano.

Quando ho fatto il test reale (`./run.sh` da terminale normale), sono emersi **due bug consecutivi** che i test interni di Claude Code non potevano rilevare:
1. Falsi positivi del `pgrep` (perché Claude Code non ha le 28 istanze LanguageServer nel suo ambiente)
2. Race condition di readiness (perché Claude Code non aveva monkeyc/monkeydo nel PATH per testare il flusso completo)

**Cosa abbiamo imparato**

I test che Claude Code esegue nel proprio ambiente sandboxed sono **complementari**, non sostitutivi del test umano nell'ambiente reale. Sono utili per validare logica isolata (regex, flussi di controllo, parsing, exit code), ma non possono rilevare:
- Differenze di ambiente (PATH, processi attivi, configurazioni utente)
- Race condition o tempistiche reali
- Comportamenti di tool esterni non disponibili nel suo ambiente

**Implicazione operativa**

Regola permanente del workflow: **prima di mergiare ogni PR, l'utente deve eseguire un test reale nel proprio terminale**, separato da Claude Code. Il test interno di Claude Code è solo un primo filtro, non l'approvazione finale.

Aggiungere questa regola alla skill `quality-gate` quando verrà creata.

**Promozione candidata**

→ Già implicita in CLAUDE.md (regole di review umana) ma vale la pena renderla esplicita in una futura skill `quality-gate`.

---

## 2026-04-25 — 28 istanze LanguageServer.jar orfane (dominio)

**Cosa è successo**

Il sistema aveva 28 processi `LanguageServer.jar` Java attivi simultaneamente, presumibilmente avviati dall'estensione Monkey C di VS Code. Ogni processo è una JVM separata che consuma memoria. Probabile causa: l'estensione VS Code Monkey C lascia processi "orfani" quando VS Code viene chiuso, riavviato, o crasha.

**Cosa abbiamo imparato**

L'estensione Monkey C di VS Code può accumulare processi LanguageServer non terminati nel tempo. Sono invisibili (non hanno UI), ma occupano memoria e potenzialmente rallentano il sistema.

**Implicazione operativa**

Pulizia periodica raccomandata:
```bash
pkill -f "LanguageServer.jar"
```

Da fare quando si nota lentezza generale del Mac, o periodicamente (es. una volta a settimana). Non è urgente ma utile sapere.

**Promozione candidata**

→ Possibile ticket futuro: `chore: document Monkey C VS Code extension orphan processes cleanup`. Andrebbe in CLAUDE.md sezione "Troubleshooting" se la creiamo.

---

## 2026-04-25 — Iterazioni multiple su un ticket sono sane (trasversale)

**Cosa è successo**

Il ticket #17 ha richiesto 3 commit per essere completato:
1. Implementazione iniziale (logica base)
2. Fix pattern `pgrep` (falsi positivi)
3. Fix race condition (buffer di readiness)

Ciascun commit è emerso da test reali che rivelavano un nuovo bug del precedente. Confronto: ticket #15 era andato "liscio" in un commit, ma era infrastrutturale e isolato.

**Cosa abbiamo imparato**

Iterazioni multiple su un ticket non sono un fallimento. Sono il pattern naturale quando il codice interagisce con sistemi esterni complessi (processi, file system, tool esterni). I bug emergono a strati: risolto il primo, il secondo diventa visibile.

L'errore sarebbe accettare una PR senza test reali oppure scoraggiarsi alla seconda iterazione e abbandonare la qualità per chiudere.

**Implicazione operativa**

Aspettarsi 2-4 iterazioni per ticket "non triviali". Non sentirsi in colpa, non considerarlo un bug del processo, non saltare iterazioni per "chiudere prima". L'efficienza vera è chiudere il ticket con qualità, anche se richiede tre commit invece di uno.

**Promozione candidata**

→ Lesson trasversale, non promuovibile in una skill specifica. Resta qui come promemoria psicologico/metodologico.

---

## 2026-04-25 — Ambiente Claude Code vs shell utente (trasversale)

**Cosa è successo**

Più volte abbiamo scoperto che la sessione di Claude Code lavorava in un ambiente shell **diverso** da quello del terminale utente:
- `monkeyc` non era nel PATH della sessione Claude Code, ma era nel PATH del terminale dopo aver modificato `~/.zshrc`
- `$GARMIN_DEVELOPER_KEY` non era settata nella sessione Claude Code, ma era nel terminale utente

Questo perché le sessioni di Claude Code partono in un sub-shell che eredita l'ambiente al momento del lancio. Modifiche successive a `~/.zshrc` non si propagano alla sessione già in esecuzione.

**Cosa abbiamo imparato**

Tre regole pratiche:
1. Modifiche a `~/.zshrc` (PATH, env vars) richiedono **chiusura e riapertura** della sessione Claude Code per essere visibili.
2. I test che richiedono PATH specifici (build, run di tool esterni) **non possono essere eseguiti dentro Claude Code** se l'ambiente non è configurato.
3. Se serve testare comandi che richiedono SDK esterne, va fatto sempre in un terminale utente separato dopo aver verificato il PATH.

**Implicazione operativa**

Documentato in `CLAUDE.md` (sezione "Comandi" con TODO da completare). Da rendere esplicito quando la sezione sarà completa: "I test di build/run vanno fatti sempre nel terminale utente, non dentro la sessione Claude Code".

**Promozione candidata**

→ Da promuovere a CLAUDE.md sezione "Comandi" o "Testing" quando la sezione sarà completa.

---

## 2026-04-25 — GitHub MCP non supporta creazione labels (trasversale)

**Cosa è successo**

Durante la creazione dei ticket #17 e #18, abbiamo scoperto che il GitHub MCP server **non espone un tool per creare labels** sul repo. Le labels usate nel ticket devono già esistere, altrimenti la creazione dell'issue fallisce o usa solo le labels esistenti.

Tentativi di workaround sono stati:
- `gh` CLI: non installato sul sistema
- `curl` diretto all'API GitHub: scartato per sicurezza (token GitHub esposto in argomenti bash)

Soluzione: creare le labels manualmente sul browser GitHub (1 minuto di lavoro umano), poi procedere con la creazione delle issue via MCP.

**Cosa abbiamo imparato**

Il GitHub MCP server attuale supporta operazioni "frequenti" (issue R/W, PR R/W, commenti, branch) ma non operazioni "rare" come creazione labels, milestones, configurazione repo. Per quelle operazioni serve sempre intervento manuale.

**Implicazione operativa**

Quando il GitHub MCP non supporta un'operazione, **preferire sempre il workaround umano** (browser, 1 minuto) rispetto a soluzioni tecniche con `curl` o tool non installati. La sicurezza e la semplicità battono la "completezza dell'automazione" per operazioni rare.

Documentato già nella skill `ticket-management/templates/labels-reference.md`.

**Promozione candidata**

→ Già coperto nella skill `ticket-management`. Resta qui come riferimento al *perché* della scelta.

---
