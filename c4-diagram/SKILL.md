---
name: c4-diagram
description: Generate C4 architecture diagrams from a textual description of a software system. Use when the user describes a system they want to diagram, or wants to create architecture diagrams for a planned/proposed system. Dispatched by arch-document for context and container views; usable standalone when the system is described in prose rather than existing code. Part of the architecture suite (arch-design / arch-decide / arch-document / arch-evaluate + c4-analyze / c4-diagram for notation-specific diagramming).
argument-hint: "[description or diagram level]"
---

# /c4-diagram — Generate C4 Architecture Diagrams from Description

Generate C4 model architecture diagrams based on a conversational description of a
software system, following Simon Brown's methodology.

## Arguments

- A description of the system (e.g., `/c4-diagram e-commerce platform with React frontend and Python backend`)
- A diagram level to generate (e.g., `/c4-diagram component api-server` — if a model has already been established in conversation)
- No argument: ask the user to describe their system

## Flow

### Phase 1: Understand the System

If the user provides a brief description, ask clarifying questions to fill gaps.
Ask only what's needed — don't interrogate. Group questions logically.

**Essential questions (ask if not provided):**

1. **What does the system do?** (one-sentence purpose)
2. **Who uses it?** (user types/roles — end users, admins, other systems, scheduled jobs)
3. **What are the major pieces?** (web app, mobile app, API, database, workers, etc.)

**Follow-up questions (ask if relevant, based on what was shared):**

4. **What external systems does it integrate with?** (payment providers, email services, auth providers, third-party APIs)
5. **What are the key technology choices?** (languages, frameworks, databases, message queues)
6. **How do the pieces communicate?** (REST, GraphQL, gRPC, message queues, webhooks)

Don't ask all questions at once. Start with 1-3, then follow up based on the answers.

### Phase 2: Build the Model

Organize the information into the C4 hierarchy:

- **People**: Users, roles, external actors
- **Software System**: The system being described (the thing in scope)
- **External Systems**: Third-party services, legacy systems, partner APIs
- **Containers**: The major deployable/runnable pieces
- **Components**: Internal groupings within containers (only if user wants Level 3)

For each element, define:
- **Name**: Clear and specific
- **Technology**: If known or decided; note "TBD" if still under consideration
- **Description**: One sentence about its responsibility
- **Relationships**: What connects to what, the purpose, and the mechanism

### Phase 3: Generate Diagrams

Generate diagrams as **draw.io XML** (`.drawio` files).

Default behavior: generate Level 1 (System Context) and Level 2 (Container).
Generate Level 3 (Component) only when the user asks to drill into a specific container.

#### draw.io XML format

Use the `<mxfile><diagram><mxGraphModel>` structure with `<mxCell>` elements.

#### C4 color scheme

| Element | Fill Color | Stroke Color | Font Color | Shape |
|---------|-----------|-------------|-----------|-------|
| Person | `#08427B` | `#073B6F` | `#ffffff` | `shape=mxgraph.c4.person2` |
| System (in scope) | `#1168BD` | `#0B4884` | `#ffffff` | `rounded=1;arcSize=10` |
| System (external) | `#999999` | `#8A8A8A` | `#ffffff` | `rounded=1;arcSize=10` |
| Container | `#438DD5` | `#3C7FC0` | `#ffffff` | `rounded=1;arcSize=10` |
| Container (database) | `#438DD5` | `#3C7FC0` | `#ffffff` | `shape=cylinder3` |
| Component | `#85BBF0` | `#78A8D8` | `#000000` | `rounded=1;arcSize=10` |
| Planned/future | `#CCCCCC` | `#AAAAAA` | `#ffffff` | `dashed=1` |
| Boundary | none | `#0B4884` (system) / `#3C7FC0` (container) | match stroke | `swimlane;dashed=1;dashPattern=8 4` |

#### Element label format

Every element label should include (using HTML in the `value` attribute):
- **Bold name**
- Element type in small text: `[Person]`, `[Software System]`, `[Container: Technology]`, `[Component: Technology]`
- Description in normal text

Example: `<b>API Server</b><br><font style="font-size:10px">[Container: Django 6.0, Python 3.12]</font><br><br><font style="font-size:11px">REST API handling mission CRUD and agent orchestration</font>`

#### Diagram structure rules

- **Title**: Text cell at top with `fontSize=18;fontStyle=1`
- **Key/legend**: Small boxes in a corner showing the color scheme
- **Relationships**: `edgeStyle=orthogonalEdgeStyle;rounded=1` with label showing purpose + protocol. Always use proper `source` and `target` attributes referencing element IDs — never use manual `sourcePoint`/`targetPoint` coordinates, which render as floating disconnected lines.
- **Boundaries**: Use `swimlane` style with `container=1;collapsible=0` — child elements use `parent="boundaryId"`
- **Layout**: People at top, system in scope in center, external systems around edges/bottom
- **Canvas size**: `pageWidth="1600" pageHeight="1200"` minimum; increase for complex diagrams

#### Spacing and layout rules (critical)

These rules prevent overlapping text and unreadable diagrams:

- **140px minimum** between context elements (people, external containers) and the boundary top, so edge labels don't overlap the boundary title text.
- **200px minimum** between boundary bottom and external systems below, so edge labels between them are readable and don't overlap the boundary line.
- **150px minimum gap** between sibling elements in the same row (containers, components), so relationship labels between them have room.
- **Center contents inside boundaries**: calculate total content width, subtract from boundary width, divide by 2 for left margin. Do this for each row independently.
- **Use explicit waypoints** (`<Array as="points">`) to route edges around obstacles. Waypoints should run through the gap between the boundary edge and external systems.

#### Edge routing rules

- **Never route an edge through a component or container.** If an edge would cross an element, spread elements apart to create a clear lane, or reroute the edge with waypoints.
- **Edges that skip rows must route around, not through.** If a service in row 2 connects to an external system below the boundary, and row 3 (data stores) is in between, the edge must route along the left or right margin of the boundary and exit from the bottom — never vertically through row 3. Use waypoints to hug the boundary edge.
- **Cross-row edges** (e.g., connecting elements that aren't adjacent) must route above or below the intervening row using waypoints, not through it.
- **Edges exiting a boundary** to reach external systems should use waypoints at intermediate Y positions between the boundary bottom and the external system top, with each edge at a different Y to avoid overlapping.
- **All edges must use proper `source` and `target` attributes** referencing element IDs. Never use `sourcePoint`/`targetPoint` manual coordinates — these create disconnected lines and make the audit untraceable.

#### Level 1: System Context

Show the software system as a single box, surrounded by users and external systems.

#### Level 2: Container

Zoom into the system boundary (dashed swimlane) to show containers with technology choices. Include people and external systems outside the boundary for context.

#### Level 3: Component

Zoom into a single container (dashed swimlane) to show its components. Include surrounding containers and external systems for context.

#### Deployment Diagram (if the user asks about infrastructure)

Show deployment nodes (nested boxes) containing containers, mapped to infrastructure.

### Phase 4: Layout Audit (mandatory — do this before saving)

After generating the initial diagram XML, perform this audit. If any check fails, adjust the layout and re-check. Repeat until all checks pass.

#### 4a. Trace every edge path

For each edge, compute the full path by listing the absolute coordinates of every point: source exit point → each waypoint → target entry point. Each pair of consecutive points forms a segment. For each segment, check if the line intersects the bounding box (x, y, width, height) of every element in the diagram. If any segment crosses through any element:
- Route the edge around the element using waypoints along the boundary margin, OR
- Spread elements apart to create a clear lane

Special attention: edges connecting to external systems below the boundary often have a long vertical segment dropping through lower rows. These MUST route along the left or right margin first, then drop below the boundary, then turn horizontally to reach the target.

#### 4b. Check edge label positions for overlaps

draw.io places edge labels at the midpoint of the longest segment of an orthogonal edge. For each edge label:
1. Identify the longest segment of the edge path (the segment with the greatest length).
2. The label will be centered on this segment's midpoint.
3. Estimate the label's bounding box conservatively: use **12px per character width** and **20px per line height**, centered on the midpoint. Over-estimating is better than under-estimating — a little extra spacing is preferable to overlapping text.
4. Check if this bounding box overlaps with:
   - Any element (container, component, person, external system)
   - The boundary title text (the swimlane header area)
   - Any other edge label's estimated bounding box

**Critical:** If the longest segment is a vertical drop adjacent to a container (e.g., the last segment before the target), the label will render on top of that neighboring container. To fix this, add waypoints so that the longest segment is in open space — typically a horizontal run through a clear gap between rows.

If an overlap is found:
- Add waypoints to change which segment is longest, moving where the label lands, OR
- Shift the edge's exit/entry points to move the longest segment to a clear area, OR
- Increase spacing between the elements the edge connects

#### 4c. Check parallel and bundled edges

**No two edges may share the same waypoint Y or X value.** When edges share a coordinate, draw.io renders them on top of each other, making it impossible to trace which line goes where. For every pair of edges:
- Each edge must use a **unique waypoint Y** (for horizontal runs) or **unique waypoint X** (for vertical runs), separated by at least **30px**.
- Source exit points from the same element must be spread across different positions (e.g., exitX=0.2 vs exitX=0.5 vs exitX=0.8). Never use the same exit point for two edges.
- Target entry points on the same element must also be spread (e.g., entryX=0.3 vs entryX=0.7).
- If two edges run parallel for any segment, offset one of them by at least 30px using additional waypoints.

Labels on parallel edges will also overlap if the edges are close. Since labels are centered on the longest segment, ensure the longest segments of nearby edges are in **different spatial areas** — either at different Y levels or with enough horizontal separation (at least 200px between label centers).

#### 4d. Verify boundary title clearance

Check that no edge or edge label passes through or overlaps the boundary's swimlane header (the `startSize` area, typically 30px tall at the top of the boundary). If edges enter the boundary from above, they should connect at the boundary top edge, not route through the title.

### Phase 5: Output

1. **Save the draw.io XML** to the project root (or current directory):
   - Filenames: `system-context.drawio`, `containers.drawio`, `components-[name].drawio`

2. **Export to PNG** by running `drawio --export --format png --output <name>.png <name>.drawio` via Bash.

3. **Open in draw.io desktop** by running `drawio <filepath>` via Bash.

4. **Offer next steps:**
   - "Want me to zoom into any container for a component diagram?"
   - "Want to add a deployment diagram?"
   - "Anything to adjust?"

## Guidelines

- **Be conversational, not bureaucratic.** Don't force the user through a rigid questionnaire. Adapt based on what they share.
- **Infer where reasonable.** If the user says "React frontend with a Node API and Postgres," you don't need to ask what the database technology is.
- **Be specific in element descriptions.** "Provides product search, cart management, and checkout" beats "Handles business logic."
- **Include technology choices** even during upfront design. If the user hasn't decided, note options: "Database [PostgreSQL or MySQL — TBD]".
- **Annotate every relationship** with purpose and protocol/mechanism.
- **Don't mix abstraction levels.** Keep each diagram at one level of the C4 hierarchy.
- **Use prepositions in relationship labels** that match arrow direction: "reads from," "sends to," "makes API calls to."
- **For large systems:** Start with System Context, then Container. Offer Component diagrams for the most interesting containers rather than trying to diagram everything.
- **Iterate.** After generating a diagram, ask if it looks right. The user often has corrections or additions after seeing the first version.
