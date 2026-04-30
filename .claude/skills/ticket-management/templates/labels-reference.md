# Labels reference (BatterySafe)

Questa è la lista hardcoded delle labels configurate sul repo `mdeias/BatterySafe`. Usala come **fallback** quando il GitHub MCP non riesce a listare le labels via API.

**Mantenimento**: se aggiungi/rimuovi label sul repo, aggiorna questo file di conseguenza.

## Type (una e una sola)

| Label | Descrizione | Esempio d'uso |
|-------|-------------|---------------|
| `type:feat` | Nuova feature visibile all'utente | Aggiungere complicazione meteo |
| `type:fix` | Bug fix | Colore batteria non aggiorna |
| `type:chore` | Manutenzione, cleanup, tooling | Rename file, cleanup codice morto |
| `type:refactor` | Miglioramento struttura senza cambio funzionale | Estrarre helper in modulo separato |
| `type:docs` | Documentazione | Aggiornare CLAUDE.md, README |
| `type:enhancement` | Miglioramento di feature esistente | Auto-discovery key da VS Code (ticket #18) |

## Area (una o più)

| Label | Descrizione |
|-------|-------------|
| `area:ui` | Layout, colori, fonts, rendering su Dc |
| `area:data` | DataManager, State, calcoli, system stats |
| `area:battery` | Ottimizzazioni consumo, throttling, dirty flags |
| `area:tooling` | Script, build, CI, configs (.zshrc, VS Code) |
| `area:resources` | manifest.xml, strings.xml, images, layouts XML |

## Priority (una e una sola)

| Label | Descrizione | Esempio |
|-------|-------------|---------|
| `priority:p0` | Bloccante (app non funziona, store rifiuta) | App crash sui device principali |
| `priority:p1` | Importante (feature principale, bug evidente) | Build script, bug batteria |
| `priority:p2` | Medio (miglioramento UX, bug minore) | Auto-launch simulator, rename file referenziati |
| `priority:p3` | Nice-to-have | Pulizia commenti, rename file standalone |

## Meta

| Label | Descrizione |
|-------|-------------|
| `claude-code-friendly` | Ticket con scope chiaro, AC testabili, nessuna decisione di prodotto aperta. Ottimo candidato per workflow agentico. |

## Guida veloce alla scelta di priority

- **p0**: il progetto letteralmente non funziona come prodotto (crash, manifest rotto, store rifiuta la release)
- **p1**: una feature importante o un bug visibile al primo colpo d'occhio dell'utente
- **p2**: miglioramento misurabile dell'UX o della DX, ma c'è workaround
- **p3**: "sarebbe carino", nessun dolore nel non farlo

Default se non sai: **p2**. Si può sempre modificare dopo.

## Note operative

- **Nuove label**: se serve una label che non esiste, il GitHub MCP **non supporta** la creazione di label. Vedi `.claude/LESSONS.md` per il workaround (creare manualmente via browser).
- **Consistency check**: prima di creare un ticket, verifica che tutte le label scelte esistano davvero. Se una manca, avvisa Matteo prima di creare.
