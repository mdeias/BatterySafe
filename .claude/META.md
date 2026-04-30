# META — Sessioni strategiche di BatterySafe

Policy operativa per le **sessioni meta**: momenti di riflessione strategica che si tengono nella chat su Claude.ai (non in Claude Code), separati dal lavoro quotidiano sui ticket.

## Filosofia

Il workflow quotidiano (ticket, codice, test, PR) gira da solo grazie alle skill in `.claude/skills/`. Le sessioni meta esistono per ciò che il workflow quotidiano non può fare: **giudizio strategico, retrospettive, valutazione di nuove direzioni**.

Sono distinte da una "richiesta puntuale" (es. "Claude, ho un dubbio su X"): una sessione meta è **proattiva** — tu ti siedi a riflettere, non reagisci a un blocco specifico.

## Quando aprire una sessione meta

### Trigger primario — a sintomi

Apri una sessione meta quando noti uno di questi segnali:

- **Skill che non funzionano più come dovrebbero** — Claude Code "salta" passaggi della skill, o segue procedure obsolete
- **Pattern ricorrente di errori** simili in più ticket consecutivi
- **Backlog gonfio** che non riesci a smaltire (>10 ticket aperti per più di 4 settimane)
- **`LESSONS.md` cresciuto oltre 15-20 voci attive** — è il momento di distillare in skill
- **Decisioni architetturali importanti** in vista (introdurre subagenti, hook, nuovi MCP)
- **Sensazione di "sto lavorando contro lo strumento"** anziché con esso
- **Voglia di valutare nuove feature** di Claude Code uscite di recente

### Trigger di sicurezza — temporale

Anche senza sintomi attivi, fai un check se sono passate **4-6 settimane** dall'ultima sessione meta. Serve a evitare che problemi silenti si accumulino. È leggero — se davvero non c'è niente da discutere, la sessione finisce in 15 minuti.

### NON sono trigger per sessione meta

- Bug specifici di un ticket → fai una richiesta puntuale, non meta
- Domande di sintassi, API, design del codice → richiesta puntuale
- Refining di un ticket → skill `ticket-management`, non meta

## Argomenti tipici

Le sessioni meta toccano (in ordine di frequenza attesa):

1. **Refactor delle skill** — sono ancora coerenti col tuo workflow? Vanno aggiornate?
2. **Distillazione di `LESSONS.md`** — quali lessons promuovere a skill o a CLAUDE.md
3. **Retrospettive su ticket difficili** — cosa è andato storto, cosa migliorare
4. **Valutazione nuove feature/strumenti** — subagenti, hook, plugin, MCP nuovi
5. **Pulizia backlog** — quali ticket chiudere come "won't fix", quali prioritizzare
6. **Decisioni architetturali del workflow** — non del codice di BatterySafe ma del sistema Claude Code stesso
7. **Validazione del sistema nel tempo** — sta migliorando? Sta degenerando? Andiamo nella direzione giusta?

## Format

**Per ora**: conversazione libera. Ti siedi nella chat, dici cosa ti gira in testa, conversiamo. Aperta a connessioni inaspettate.

**In futuro** (se le sessioni si ripetono simili e disperdono): può essere strutturata con scaletta ricorrente. Da valutare dopo 3-4 sessioni meta, non prima.

## Output attesi

Una sessione meta deve produrre **almeno un artefatto concreto**, altrimenti è chiacchiera. Possibili output:

- **Modifiche a skill esistenti** (riscrivere, semplificare, aggiungere regole)
- **Nuove skill** create
- **Nuove voci in `LESSONS.md`** o promozione di lessons in skill
- **Nuovi ticket aperti** nel backlog per lavoro futuro
- **Modifiche a CLAUDE.md** (convenzioni, regole, riferimenti)
- **Modifiche a `settings.json`** (permessi)
- **Modifiche a questo file `META.md`** (auto-update della policy meta)

Se a fine sessione non c'è alcun output, è un segnale che la sessione era prematura o non avevi davvero materiale di cui discutere.

## Come ricordarsi di questo file

Quando entri in una nuova chat su Claude.ai per riprendere il lavoro su BatterySafe, basta scrivere qualcosa come:

> "Apriamo una sessione meta su BatterySafe. [descrizione del sintomo o dubbio]"

L'assistente in chat saprà recuperare il contesto e applicare la policy di questo file.

## Storico delle sessioni meta

Aggiungi qui la data e il "tema" di ogni sessione meta tenuta, per tracciabilità:

| Data | Tema principale | Output prodotti |
|------|----------------|-----------------|
| 2026-04-26 | Costituzione del workflow + creazione META.md | quality-gate skill, META.md |

(Aggiornare a fine ogni sessione meta successiva.)
