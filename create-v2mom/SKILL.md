---
name: create-v2mom
description: Create a V2MOM (Vision, Values, Methods, Obstacles, Metrics) strategic framework for any project, goal, or domain — personal infrastructure, business strategy, health goals, financial planning, software development, career planning, or life goals. Walks the user through the five sections in order: Vision first (aspirational picture of success), then Values (2-4 principles that guide decisions), Methods (4-7 prioritized approaches with concrete actions), Obstacles (honest personal and external challenges), and Metrics (measurable outcomes, not vanity metrics). Includes an optional task-migration phase that consolidates an existing todo list under the defined Methods. Use when the user asks to create a V2MOM, build a strategic plan, set goals for a significant project, or apply ruthless prioritization without an existing framework. Do NOT use for simple todo lists, single-decision prompts (use /arch-decide), quick task brainstorming (use /brainstorm), or daily/weekly planning of routine tasks. Produces a document that becomes the project's decision-making source of truth.
---

# /create-v2mom — Create a V2MOM Strategic Framework

Transform vague intentions into a concrete action plan using V2MOM: Vision, Values, Methods, Obstacles, Metrics. Originated at Salesforce; works for any domain.

## Problem Solved

Without a strategic framework, projects suffer from:

- **Unclear direction** — "get healthier" / "improve my finances" is too vague to act on; every idea feels equally important; no principled way to say "no."
- **Priority inflation** — everything feels urgent; research/planning without execution; active todo list grows beyond manageability.
- **No decision framework** — debates about A vs B waste time; second-guessing after decisions; perfectionism masquerading as thoroughness.
- **Unmeasurable progress** — can't tell if work is actually making things better; no objective "done" signal; vanity metrics only.

## When to Use

- Starting a significant project (new business, new habit, new system)
- Existing project has accumulated many competing priorities without clear focus
- You find yourself constantly context-switching between ideas
- Someone asks "what are you trying to accomplish?" and the answer is vague
- Annual or quarterly planning for ongoing projects or life goals

Particularly valuable for: personal infrastructure (tooling, systems, workflows), health and fitness, financial planning, software package development, business strategy, career development.

## Exit Criteria

The V2MOM is complete when:

1. **All 5 sections have concrete content:**
   - Vision: Clear, aspirational picture of success
   - Values: 2-4 principles that guide decisions
   - Methods: 4-7 concrete approaches with specific actions
   - Obstacles: Honest personal/technical challenges
   - Metrics: Measurable outcomes (not vanity metrics)
2. **It's useful for decision-making:** can answer "does X fit this V2MOM?" quickly; provides priority clarity (Method 1 > Method 2 > etc.); identifies what NOT to do.
3. **Both parties agree it's ready:** feels complete not rushed; actionable enough to start execution; honest about obstacles (not sugar-coated).

**Validation questions:**
- Can you articulate the vision in one sentence?
- Do the values help you say "no" to things?
- Are methods ordered by priority?
- Can you immediately identify 3-5 tasks from Method 1?
- Do metrics tell you if you're succeeding?

## Instructions

Complete phases in order. Vision informs Values. Values inform Methods. Methods reveal Obstacles. Everything together defines Metrics.

### Phase 1: Ensure shared understanding of the framework

Confirm both parties understand what each section means:

- **Vision:** What you want to achieve (aspirational, clear picture of success)
- **Values:** Principles that guide decisions (2-4 values, defined concretely)
- **Methods:** How you'll achieve the vision (4-7 approaches, ordered by priority)
- **Obstacles:** What's in your way (honest, personal, specific)
- **Metrics:** How you'll measure success (objective, not vanity metrics)

### Phase 2: Create the document structure

1. Create file: `docs/[project-name]-v2mom.org` or appropriate location.
2. Add metadata: `#+TITLE`, `#+AUTHOR`, `#+DATE`, `#+FILETAGS`.
3. Create section headings for all 5 components.
4. Add a "What is V2MOM?" overview section at top.

Save incrementally after each section — V2MOM discussions can run long.

### Phase 3: Define the Vision

**Ask:** "What do you want to achieve? What does success look like?"

**Goal:** Clear, aspirational picture. 1-3 paragraphs describing the end state.

**Your role:**
- Help articulate what's described
- Push for specificity ("works great" → what specifically works?)
- Identify scope (what's included, what's explicitly out)
- Capture concrete examples the user mentions

**Good vision characteristics:**
- Paints a picture you can visualize
- Describes outcomes, not implementation
- Aspirational but grounded in reality
- Specific enough to know what's included

**Examples across domains:**
- Health: "Wake up with energy, complete a 5K without stopping, feel strong in daily activities, stable mood throughout the day."
- Finance: "Six months emergency fund, debt-free except mortgage, automatic retirement savings, financial decisions that don't cause anxiety."
- Software: "A package that integrates seamlessly, has comprehensive documentation, handles edge cases gracefully, that maintainers of other packages want to depend on."

**Time estimate:** 15-30 minutes if mostly clear; 45-60 minutes if it needs exploration.

### Phase 4: Define the Values

**Ask:** "What principles guide your decisions? When faced with A vs B, what values help you decide?"

**Goal:** 2-4 values with concrete definitions and examples.

**Your role:**
- Suggest values based on vision discussion
- Push for concrete definitions (not just the word, but what it MEANS)
- Help distinguish between overlapping values
- Identify when examples contradict stated values

**Common pitfall:** Listing generic words without defining them.
- Bad: "Quality, Speed, Innovation"
- Good: "Sustainable means can maintain this for 10+ years without burning out. No crash diets, no 80-hour weeks, no technical debt I can't service."

**For each value, capture:**
1. The value name (1-2 words)
2. Definition (what it means in context of this project)
3. Concrete examples (how it manifests)
4. What breaks this value (anti-patterns)

**Method:** Start with 3-5 candidates. For each, ask "what does [value] mean to you in this context?" Discuss until the definition is concrete. Refine, merge, remove until 2-4 remain.

**Examples:**
- Health: "Sustainable: Can do this at 80 years old. No extreme diets. Focus on habits that compound over decades."
- Finance: "Automatic: Set up once, runs forever. Don't rely on willpower for recurring decisions."
- Software: "Boring: Use proven patterns. No clever code. Maintainable by intermediate developers. Boring is reliable."

**Time estimate:** 30-45 minutes.

### Phase 5: Define the Methods

**Ask:** "How will you achieve the vision? What approaches will you take?"

**Goal:** 4-7 methods (concrete approaches) ordered by priority.

**Your role:**
- Extract methods from vision and values discussion
- Help order by priority (what must happen first?)
- Ensure methods are actionable (not just categories)
- Push for concrete actions under each method
- Watch for method ordering that creates dependencies

**Structure for each method:**
1. Method name (verb phrase: "Build X", "Eliminate Y", "Establish Z")
2. Aspirational description (1-2 sentences: why this matters)

**Method ordering matters:**
- Method 1 should be highest priority (blocking everything else)
- Lower-numbered methods should enable higher-numbered ones
- Common ordering patterns:
  - Fix → Stabilize → Build → Enhance → Sustain
  - Eliminate → Replace → Optimize → Automate → Maintain
  - Learn → Practice → Apply → Teach → Systematize

**Examples:**

Health:
- Method 1: Eliminate Daily Energy Drains (fix sleep, reduce inflammatory foods, address deficiencies)
- Method 2: Build Baseline Strength (3x/week resistance, progressive overload, compound movements)
- Method 3: Establish Sustainable Nutrition (meal prep, protein targets, vegetable servings)

Finance:
- Method 1: Stop the Bleeding (eliminate wasteful subscriptions, high-interest debt, impulse purchases)
- Method 2: Build the Safety Net (automate savings, reach $1000 fund, then 3 months expenses)
- Method 3: Invest for the Future (max 401k match, open IRA, automatic contributions)

Software Package:
- Method 1: Nail the Core Use Case (solve one problem extremely well, clear docs, handle errors gracefully)
- Method 2: Ensure Quality and Stability (comprehensive tests, CI/CD, semantic versioning)
- Method 3: Build Community and Documentation (contribution guide, examples, responsive to issues)

**Ordering is flexible until it isn't:** After defining all methods, you may realize the ordering is wrong. Swap them. The order represents priority — getting it right matters more than preserving the initial draft.

**Time estimate:** 45-90 minutes (longest section).

### Phase 5.5: Brainstorm tasks for each method

For each method, brainstorm what's missing to achieve it.

**Ask:** "What else would help achieve this method's goal?"

**Your role:**
- Suggest additional tasks based on the method's aspirational description
- Consider edge cases and error scenarios
- Identify automation opportunities
- Propose monitoring/visibility improvements
- Challenge if the list feels incomplete (can't reach the goal)
- Challenge if the list feels bloated (items don't contribute to the goal)
- Create sub-tasks for items with multiple steps
- Ensure priorities reflect contribution to the method's goal

**For each brainstormed task:**
- Describe what it does and why it matters
- Assign priority based on contribution to the method
- Add technical details if known
- Get user agreement before adding

**Priority system (org-mode):**
- `[#A]` Critical blockers — must be done first, blocks everything else
- `[#B]` High-impact reliability — directly enables the method goal
- `[#C]` Quality improvements — valuable but not blocking
- `[#D]` Nice-to-have — low priority, can defer

**Time estimate:** 10-15 minutes per method (~50-75 min for 5 methods).

### Phase 6: Identify the Obstacles

**Ask:** "What's in your way? What makes this hard?"

**Goal:** Honest, specific obstacles — both personal and technical/external.

**Your role:**
- Encourage honesty (obstacles are reality, not failures)
- Help distinguish symptoms from root causes
- Identify patterns in behavior that create obstacles
- Acknowledge challenges without judgment

**Good obstacle characteristics:**
- Honest about personal patterns
- Specific, not generic
- Acknowledges both internal and external obstacles
- States real stakes (not just "might happen")

**Common obstacle categories:**
- Personal: perfectionism, hard to say no, gets bored, procrastinates
- Knowledge: missing skills, unclear how to proceed, need to learn
- External: limited time, limited budget, competing priorities
- Systemic: environmental constraints, missing tools, dependencies on others

**For each obstacle:** name it clearly, describe how it manifests in this project, acknowledge the stakes (what happens because of it).

**Examples:**

Health:
- "I get excited about new workout programs and switch before seeing results (pattern: 6 weeks into a program)"
- "Social events involve food and alcohol — saying no feels awkward and isolating"
- "When stressed at work, I skip workouts and eat convenient junk food"

Finance:
- "Viewing budget as restriction rather than freedom — triggers rebellion spending"
- "FOMO on lifestyle experiences my peers have"
- "Limited financial literacy — don't understand investing beyond 'put money in account'"

Software:
- "Perfectionism delays releases — always 'one more feature' before v1.0"
- "Maintaining documentation feels boring compared to writing features"
- "Limited time (2-4 hours/week) and competing projects"

**Time estimate:** 15-30 minutes.

### Phase 7: Define the Metrics

**Ask:** "How will you measure success? What numbers tell you if this is working?"

**Goal:** 5-10 metrics — objective, measurable, aligned with vision/values/methods.

**Your role:**
- Suggest metrics based on vision, values, methods
- Push for measurable numbers (not "better" — concrete targets)
- Identify vanity metrics (look good but don't measure real progress)
- Ensure metrics align with values and methods

**Metric categories:**
- **Performance** — measurable outcomes of the work
- **Discipline** — process adherence, consistency, focus
- **Quality** — standards maintained, sustainability indicators

**Good metric characteristics:**
- Objective (not subjective opinion)
- Measurable (can actually collect the data)
- Actionable (can change behavior to improve it)
- Aligned with values and methods

**For each metric, capture:** name, current state (if known), target state, how to measure, measurement frequency.

**Examples:**

Health:
- Resting heart rate: 70 bpm → 60 bpm (daily via fitness tracker)
- Workout consistency: 3x/week strength training for 12 consecutive weeks
- Sleep quality: 7+ hours per night 6+ nights per week (sleep tracker)
- Energy rating: subjective 1-10 scale, target 7+ weekly average

Finance:
- Emergency fund: $0 → $6000 (monthly)
- High-interest debt: $8000 → $0 (monthly)
- Savings rate: 5% → 20% of gross income (monthly)
- Financial anxiety: weekly check-in, target "comfortable with financial decisions"

Software:
- Test coverage: 0% → 80% (coverage tool)
- Issue response time: median < 48 hours (GitHub stats)
- Documentation completeness: all public APIs documented with examples
- Adoption: 10+ GitHub stars, 3+ projects depending on it

**Time estimate:** 20-30 minutes.

### Phase 8 (optional): Migrate existing tasks

If there's an existing `TODO.org` or task list, migrate it under the V2MOM methods.

**Goal:** Consolidate all project tasks under V2MOM methods, eliminate duplicates, move non-fitting items to someday-maybe.

**Process:**

1. **Identify duplicates** — read existing TODO, find tasks already in V2MOM methods, check if V2MOM task has all technical details from the TODO version, enhance if needed, mark original for deletion.
2. **Map tasks to methods** — for each remaining task, ask "which method does this serve?" Add under appropriate method with priority. Preserve task state (DOING, VERIFY, etc.).
3. **Review someday-maybe candidates one-by-one** — for each task that doesn't fit methods, ask: keep in V2MOM (which method)? Move to someday-maybe? Delete?
4. **Final steps** — append someday-maybe items to `docs/someday-maybe.org`; copy completed V2MOM to TODO.org (overwriting). V2MOM becomes the single source of truth.

**Keep in V2MOM:** DOING tasks (work in progress), VERIFY tasks (need testing/verification), tasks that enable method goals.

**Move to someday-maybe:** Doesn't directly serve a method's goal; nice-to-have without clear benefit; research task without actionable outcome; architectural change decided not to pursue; unrelated personal task.

**Delete entirely:** Obsolete tasks (feature removed, problem solved elsewhere); duplicate of something done; task that no longer makes sense.

**Review one task at a time** — don't batch. Capture reasoning.

**Time estimate:** Variable — small (~20 tasks) 30-45 min; medium (~50) 60-90 min; large (100+) 2-3 hours.

This phase is optional — only needed if an existing todo list has substantial content.

### Phase 9: Review and refine

Once all sections are complete, review the whole V2MOM together:

1. **Does the vision excite you?** (If not, why not? What's missing?)
2. **Do the values guide decisions?** (Can you use them to say no to things?)
3. **Are the methods ordered by priority?** (Is Method 1 truly most important?)
4. **Are the obstacles honest?** (Or are you sugar-coating?)
5. **Will the metrics tell you if you're succeeding?** (Or are they vanity metrics?)
6. **Does this V2MOM make you want to DO THE WORK?** (If not, something is wrong.)

**Refinement:** merge overlapping methods; reorder methods if priorities are wrong; add missing concrete actions; strengthen weak definitions; remove fluff.

**Red flags:**
- Vision doesn't excite you → Need to dig deeper into what you really want
- Values are generic → Need concrete definitions and examples
- Methods have no concrete actions → Too vague, need specifics
- Obstacles are all external → Need honesty about personal patterns
- Metrics are subjective → Need objective measurements

### Phase 10: Commit and use

1. Save the document in its appropriate location.
2. Share with stakeholders (if applicable).
3. Use it immediately — start Method 1 execution or the first triage.
4. Schedule first review (1 week out): is this working?

Use immediately to validate the V2MOM is practical, not theoretical. Execution reveals gaps that discussion misses.

## Principles

### Honesty over aspiration

V2MOM requires brutal honesty, especially in Obstacles.

- "I get bored after 6 weeks" (honest) vs "Maintaining focus is challenging" (bland)
- "I have 3 hours per week max" (honest) vs "Time is limited" (vague)
- "I impulse-spend when stressed" (honest) vs "Budget adherence needs work" (passive)

**Honesty enables solutions.** If you can't name the obstacle, you can't overcome it.

### Concrete over abstract

Every section should have concrete examples and definitions.

**Bad:** Vision "be successful" · Values "Quality, Speed, Innovation" · Methods "improve things" · Metrics "do better"

**Good:** Vision "Complete a 5K in under 30 min, have energy to play with kids after work, sleep 7+ hours consistently" · Values "Sustainable: can maintain for 10+ years, no crash diets, no injury-risking overtraining" · Methods "Method 1: Fix sleep quality (blackout curtains, consistent bedtime, no screens 1hr before bed)" · Metrics "5K time: current 38 min → target 29 min (measure: monthly timed run)"

### Priority ordering is strategic

Method ordering determines what happens first. Get it wrong and you'll waste effort.

Common patterns:
- **Fix → Build → Enhance → Sustain** (eliminate problems before building)
- **Eliminate → Replace → Optimize** (stop damage before improving)
- **Learn → Practice → Apply → Teach** (build skill progressively)

Method 1 must address the real blocker — if the foundation is broken, nothing built on it will hold; high-impact quick wins build momentum; must stop the bleeding before rehab.

### Methods need concrete actions

If you can't list 3-8 concrete actions for a method, it's too vague.

**Test:** Can you start working on Method 1 immediately after completing the V2MOM? If the answer is "I need to think about what to do first," the method needs more concrete actions.

- Too vague: "Method 1: Improve health"
- Concrete: "Method 1: Fix sleep quality → blackout curtains, consistent 10pm bedtime, no screens after 9pm, magnesium supplement, sleep tracking"

### Metrics must be measurable

"Better" is not a metric. "Bench press 135 lbs" is a metric.

For each metric, you must be able to answer:
1. How do I measure this? (exact method or tool)
2. What's the current state?
3. What's the target state?
4. How often do I measure it?
5. What does this metric actually tell me?

If you can't answer these, it's not a metric yet.

### V2MOM is a living document

Not set in stone. As you execute, expect: method reordering (new info reveals priorities), metric adjustments (too aggressive or too conservative), new obstacles emerging, refined value definitions.

**Update when:** major priority shift occurs; new obstacle emerges that changes approach; metric targets prove unrealistic or too easy; method completion opens new possibilities; quarterly review reveals misalignment.

**But not frivolously:** Changing the V2MOM every week defeats the purpose. Update on major shifts, not minor tactics.

### Use it or lose it

V2MOM only works if you use it for decisions.

Use it for:
- Weekly reviews (am I working on the right things?)
- Priority decisions (which method does this serve?)
- Saying no to distractions (not in the methods)
- Celebrating wins (shipped Method 1 items)
- Identifying blockers (obstacles getting worse?)

If 2 weeks pass without referencing the V2MOM, something is wrong — either the V2MOM isn't serving you, or you're not using it.

## Closing Test

Can you say "no" to something you would have said "yes" to before? If so, the V2MOM is working.
