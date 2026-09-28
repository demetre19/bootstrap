---
name: debug-deep
description: "Three-level systematic debugging - trace data, check boundaries, prove assumptions. Invoke when 2 fix attempts fail."
---

# /debug - Three-Level Systematic Debugging

**HARD RULE: Do NOT write any fix until you have a proven root cause.**

**BASELINE RULE: Prove the proposed method programmatically before integrating it into UI, backend, frontend, workflow, or production code.** Build the smallest isolated executable proof first: script, unit test, REPL check, fixture, API call, browser-console probe, or temporary harness that exercises the exact API/data shape. Only after that proof passes may you wire the method into the real integration layer.

If a fix does not work, the diagnosis was wrong. Do not retry. Escalate to the next level.

## LEVEL 0: KNOWN-ISSUES CHECK

**Goal:** Before tracing anything, confirm this symptom is not a known issue with a documented fix. Also check how the same principle is handled elsewhere in this codebase before treating the broken function as unique.

### Steps

1. **Search project memories** for prior incidents matching the symptom or the subsystem involved. Use `list_memories` when available or grep the memory directory.

2. **Scan `docs/development-learnings.md`** for numbered patterns that match.

3. **Scan analogous local implementations.** Before tracing the broken function in isolation, grep the codebase for the same principle in other working features:
   - Same lifecycle pattern: create, inject, hydrate, update, destroy.
   - Same message pattern: `chrome.runtime.sendMessage`, `sendResponse`, storage signals, command handlers.
   - Same state pattern: active flag, per-page teardown, persisted status, session ID, stale-state cleanup.
   - Same UI pattern: floating widgets, mouse overlays, extension-page bootstraps, content scripts.
   Record what the working implementation does differently and carry that knowledge into Level 1.

4. **Web search** for the exact API plus symptom when the issue touches a platform API, codec, file format, or library. Prefer official docs, Stack Overflow, and GitHub issue trackers. Prefer recent sources.

5. **If a known issue is found:** cite the source to the user, explain the canonical fix, and apply it. Do not proceed to Level 1 when the root cause is already known.

6. **If nothing matches:** say explicitly that memories, learnings, analogous local implementations, and web sources were checked and no prior incident matched. Then proceed to Level 1.

### When this level fires

- Symptom involves a platform API, codec, file format, or flaky library.
- Error message is generic enough to search for verbatim.
- Anything that should work based on docs but does not.
- A fix has already failed once and the next step depends on proving an assumption.

## LEVEL 1: FLOW TRACE

**Goal:** Map the execution flow as an ASCII diagram before touching code. No guessing, no theorizing. Read the code and draw the path.

### Steps

1. **Identify the entry point.** What triggers the feature? Examples: button click, message listener, page load, storage change.

2. **Trace every step.** Read the code and follow the chain from trigger to final output. For each step record:
   - The file and function name.
   - What it receives.
   - What it does.
   - What it passes to the next step.

3. **Build the function inventory.** Before diagnosing the break, list every function, listener, command, storage listener, tab listener, content script, and cleanup path that can read, write, start, pause, resume, stop, destroy, or rehydrate the same state. Do not say "fixed" until every inventoried function is either updated, proven irrelevant, or documented as intentionally unchanged.

4. **Draw the ASCII flow diagram.** Use this format:

```text
FLOW: [Feature Name] - [What should happen]

Step 1: [TRIGGER]
  File: js/example.js:42
  Fn:   handleButtonClick()
  Does: Reads input value, calls processData()
         |
         v
Step 2: [PROCESS]
  File: js/example.js:87
  Fn:   processData(rawInput)
  Does: Validates input, formats payload
  Sends: chrome.runtime.sendMessage({ type: 'SAVE', data: payload })
         |
         v
Step 3: [SERVICE WORKER]
  File: js/background.js:320
  Fn:   onMessage handler
  Does: Writes to chrome.storage.local
  Returns: { success: true }
         |
         v
Step 4: [RESPONSE]
  File: js/example.js:90
  Fn:   response handler
  Does: Shows success notification

BREAK POINT: [where the chain actually breaks]
```

5. **Mark the break point.** Once the flow is drawn, mark where expected behavior diverges from actual behavior.

6. **Present for analysis.** Show the complete diagram to establish shared understanding before deeper investigation.

### Rules

- Every async boundary gets its own step.
- Every file transition gets its own step.
- Every storage read or write gets its own step.
- If you cannot trace a step by reading code alone, that gap is the first place to investigate.
- Do not skip this level. The diagram is the foundation for everything that follows.

### After the flow trace

- Analyse the diagram in detail.
- Look for missing error handlers, async gaps, destroyed references, race conditions, and shared state mutations.
- Present a comprehensive diagnosis with proposed fix to the user when approval is required.
- Only proceed to implementation after the required approval is clear.

## LEVEL 2: QUICK TRACE

**Goal:** Find the break point by tracing data from source to symptom.

### Steps

1. **Extract the delta.** From the report, identify what works, what does not, and what differs between the working and broken states.

2. **Read the code path.** Follow the feature code from trigger to output. Note every async boundary.

3. **Check for missing logs.** If async operation X should log on success and on error, and neither log appears, the operation is hanging.

4. **Verify data exists at each step.** Use DevTools MCP when available, or add temporary logs at each point in the chain.

### Escalate to Level 3 when

- The code path looks correct but the feature still fails.
- The bug involves multiple files, tabs, or processes.
- You cannot find where the chain breaks by reading the code.

## LEVEL 3: BOUNDARY ANALYSIS

**Goal:** Find external factors that break the feature across component boundaries.

### Steps

1. **Map the full data lifecycle:**
   - Created in which file, function, tab, or process?
   - Transferred how?
   - Consumed by which function?
   - Source destroyed when?

2. **Search for external state changes.** Grep the entire codebase for:
   - The data variable name or storage key.
   - `chrome.tabs.remove`, `URL.revokeObjectURL`, `.close()`, and cleanup functions.
   - Any code that runs between creation and consumption.

3. **Check these boundary killers:**
   - `chrome.tabs.remove()` closing a tab whose blob or data is still needed.
   - Background tab throttling.
   - `blob.arrayBuffer()` on a blob whose source tab was closed.
   - `window.open()` property assignment lost during page navigation.
   - Promise chain with no `.catch()`.
   - Service worker going idle mid-operation.

4. **Compare the working path vs broken path** at the data level. What object provides the data in each case? Are they truly the same?

### Escalate to Level 4 when

- You have tried 2 or more fixes that did not work.
- You found the boundary but cannot explain why it breaks.
- The feature involves Chrome-specific behaviors.

## LEVEL 4: NUCLEAR DEBUG

**Goal:** Throw away assumptions. Prove every step with evidence.

### Steps

1. **List every assumption you have made.** Write them down explicitly.

2. **Test each assumption independently.** For each assumption:
   - Add a log or DevTools check that proves or disproves it.
   - Do not test multiple assumptions at once.

3. **Find the wrong assumption.** One of them will be wrong. That is the root cause.

4. **Design the fix based on the actual constraint.** Fix the boundary, transfer, lifecycle, or state owner that actually failed.

### Nuclear Debug Checklist

```text
[ ] Is the async operation completing?
[ ] Is the data arriving?
[ ] Is the right function being called?
[ ] Is it the right element, canvas, or container?
[ ] Does anything else modify the same state?
[ ] Does anything destroy the source?
[ ] Is there a process boundary?
[ ] Does the browser throttle this operation?
[ ] Did analogous local implementations handle this differently?
[ ] Has every function in the inventory been accounted for?
```

## FIX

Only write the fix after root cause is proven and the proposed method has passed an isolated programmatic proof.

1. **Prove the method before integration.** Before adding code to UI, backend, frontend, workflow, extension, or production paths, run the smallest programmatic proof that exercises the exact method with representative inputs and boundary cases. Acceptable proofs include a script, unit test, REPL check, fixture-driven function call, API call, DevTools/browser-console probe, or temporary harness.
2. **Do not treat visual/manual success as proof.** Clicking through a UI can verify integration after implementation, but it cannot replace the pre-integration programmatic proof.
3. **Fix at the right layer.** Data transfer broken? Fix the transfer. Do not add workarounds downstream.
4. **One root cause, one fix.** No polling, fallback chains, or retry loops without a proven reason.
5. **Integrate only after proof passes.** Once the isolated proof passes, wire the method into the real UI/backend/frontend path with the minimum necessary change.
6. **Verify both paths.** The fix must work for the broken path and the previously working path.
7. **Clean up after yourself.** Remove temporary logs, debug variables, and test scaffolding.
8. **Account for every function in the inventory.** Before declaring completion, revisit the Level 1 inventory and mark each related entry point as changed, verified unaffected, or intentionally unchanged with a reason.

## Pattern Library

| Symptom | Likely Root Cause | Quick Check |
|---------|-------------------|-------------|
| Async never completes | Source destroyed | Grep for `chrome.tabs.remove`, `.close()` |
| Works on refresh, not first load | Data transfer broken | Compare data source |
| Timer fires fewer times than expected | Background tab throttling | Use an unthrottled data source |
| Canvas or DOM does not update | Data never arrived | Log the data before render |
| Feature X breaks feature Y | Shared mutable state | Grep for globals and storage keys |
| Random intermittent failures | Race condition | Map operation timing |
| Works in DevTools but not production | Different scope or timing | Test the actual code path |

## Anti-Patterns

If you catch yourself doing any of these, stop and escalate:

- Adding `setTimeout(fn, 500)` hoping timing fixes it.
- Adding a polling loop to wait for data.
- Adding a retry mechanism without knowing why the first attempt fails.
- Adding `requestAnimationFrame` to force a repaint.
- Adding a fallback path before understanding why the primary path fails.
- Theorizing for more than 3 minutes without checking evidence.
