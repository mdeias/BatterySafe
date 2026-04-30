# Issue body template

Usa questo template per strutturare il body di ogni issue. Tutte le sezioni sono obbligatorie. Per ticket trivial/simple alcune sezioni possono essere brevi (1 riga).

---

```markdown
## User story

As <Matteo (developer|user|maintainer)>
I want <action/capability>
So that <value/benefit>

## Context

<Breve contesto: perché questo ticket esiste adesso? Cosa lo motiva? Se è un bug, qual è il comportamento attuale vs atteso? Se è una feature, in che punto del progetto si inserisce? 2-5 righe.>

<Opzionale: riferimenti a ticket correlati, PR, discussioni, lessons. Usa link GitHub.>

## Scope

<Descrizione stringata di COSA si fa. Elenca cosa è INCLUSO nel ticket. Non decisioni implementative dettagliate — quelle emergono durante il lavoro.>

## Acceptance criteria

- [ ] <AC 1: testabile in modo binario sì/no>
- [ ] <AC 2: atomico, non compound>
- [ ] <AC 3: specifico, non vago>
...

<Raggruppare in sottoseszioni se sono molti (es. "### build.sh", "### run.sh") o se coprono aspetti diversi.>

## Out of scope

- <Cosa NON è parte di questo ticket, anche se adiacente>
- <Cose che potrebbero sembrare incluse ma sono esplicitamente escluse>

<Se davvero niente è out of scope: "None for this ticket.">

## Definition of done

- [ ] <Checklist di chiusura: tutti gli AC soddisfatti>
- [ ] <Testato localmente dal developer>
- [ ] <PR opened linked to this issue>
- [ ] <PR description documenta decisioni architetturali prese>
- [ ] <Eventuali altre verifiche specifiche del ticket>

## Labels

`type:X`, `area:Y`, `priority:Z`, eventualmente `claude-code-friendly`

## Related

- Depends on: #N (se applicabile)
- Blocks: #N (se applicabile)  
- See also: #N (se applicabile)

<Se niente: rimuovi la sezione "Related">
```

---

## Esempi pratici della struttura

### Per feature grande

Body ricco, tutte le sezioni piene. Vedi ticket #15 (build.sh/run.sh) come riferimento.

### Per bug fix

```markdown
## User story

As Matteo (user)
I want the battery color to update immediately when dropping below 20%
So that I have visual feedback for low battery state.

## Context

Currently the battery color in the footer remains white even when battery drops under 20%. Expected behavior (per design): switch to red/orange under 20%. Likely a missing dirty flag toggle in DataManager.refreshBatteryIfNeeded.

Reproduced on epix2pro42mm simulator.

## Scope

Investigate and fix the color update logic for battery threshold transitions.

## Acceptance criteria

- [ ] Battery color switches to red (or configured threshold color) when crossing 20% downward
- [ ] Color switches back to normal when battery goes back above 20% (e.g., after charging)
- [ ] Transition is visible at the next onUpdate (no delay beyond normal throttle)
- [ ] No regression on existing color logic above 20%

## Out of scope

- Changing the threshold from 20% to another value
- Adding a new color for sub-10% (separate ticket if needed)

## Definition of done

- [ ] All AC met
- [ ] Tested on epix2pro42mm simulator with manual battery level changes
- [ ] No new warnings from monkeyc compile
- [ ] PR linked to this issue

## Labels

`type:fix`, `area:ui`, `area:data`, `priority:p2`, `claude-code-friendly`
```

### Per chore trivial

```markdown
## User story

As Matteo (maintainer)
I want to rename GraphicsWrapper.mc to GraphicsManager.mc
So that the filename matches the module name it contains.

## Context

The file is named Wrapper/GraphicsWrapper.mc but contains a module named GraphicsManager. Aligning names reduces confusion.

## Scope

Rename file and update all references.

## Acceptance criteria

- [ ] File renamed from GraphicsWrapper.mc to GraphicsManager.mc
- [ ] All imports/references updated
- [ ] monkeyc build still succeeds

## Out of scope

None for this ticket.

## Definition of done

- [ ] All AC met
- [ ] Build verified locally
- [ ] PR linked to this issue

## Labels

`type:chore`, `area:ui`, `priority:p3`
```

---

## Regole di compilazione

1. **Titolo del ticket**: inglese, imperativo, ≤80 caratteri, no punto finale. Esempi buoni:
   - "Fix battery color threshold below 20%"
   - "Add weather complication"
   - "Rename GraphicsWrapper.mc to GraphicsManager.mc"

2. **Body**: sempre in inglese, sempre in markdown.

3. **Checkbox AC**: usa sempre `- [ ]` (sintassi GitHub per task list).

4. **Link ticket correlati**: usa `#N` — GitHub auto-linka.

5. **Sezione Related**: metti solo se c'è davvero un collegamento. Non riempire per dovere.
