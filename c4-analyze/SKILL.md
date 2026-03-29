---
name: c4-analyze
description: Analyze a codebase or git repo and generate C4 architecture diagrams (System Context, Container, Component). Use when the user wants to visualize or document the architecture of an existing project.
argument-hint: "[path-or-container-name]"
---

# /c4-analyze — Generate C4 Architecture Diagrams from Code

Analyze the current codebase (or a specified path) and generate C4 model diagrams
following Simon Brown's methodology.

## Arguments

- No argument: analyze the current working directory
- A path (e.g., `./services/api`): analyze that subdirectory
- A container name from a previous analysis (e.g., `api-server`): generate a Level 3 Component diagram for that container

## Step 1: Reconnaissance

Scan the repository to understand its structure. Look for these signals:

### Project boundaries and workspaces
- `pnpm-workspace.yaml`, `lerna.json`, `nx.json`, `turbo.json` → JS/TS monorepo
- `go.work`, multiple `go.mod` files → Go workspace
- `Cargo.toml` with `[workspace]` → Rust workspace
- Multiple `pom.xml` or `settings.gradle` → Java multi-module
- Multiple `pyproject.toml`, `setup.py`, or a `packages/` directory → Python monorepo

### Containers (deployable units)
- `Dockerfile`, `docker-compose.yml`, `docker-compose.yaml` → containerized services
- Kubernetes manifests (`k8s/`, `*.yaml` with `kind: Deployment`) → k8s services
- `serverless.yml`, `sam-template.yaml`, AWS CDK/Terraform with Lambda → serverless functions
- Separate apps with their own entry points (`main.go`, `manage.py`, `index.ts`, `Program.cs`)
- Database migration directories (`migrations/`, `alembic/`, `flyway/`)

### Technology detection
- Package managers: `package.json`, `requirements.txt`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`, `Gemfile`, `mix.exs`
- Frameworks: look at imports/dependencies (Django, Flask, FastAPI, Express, Next.js, Spring Boot, Rails, Phoenix, etc.)
- Databases: connection strings in config, ORM models, migration tools
- Message queues: Kafka, RabbitMQ, Redis, SQS client imports

### External system integrations
- HTTP client calls to external APIs (look for base URLs, API client classes)
- SDK imports (AWS SDK, Stripe, Twilio, SendGrid, etc.)
- OAuth/SAML/SSO integrations
- Third-party service configuration (environment variables referencing external URLs)

### Users/actors
- Authentication providers → user types
- API key/token auth → machine clients
- Admin interfaces → admin users
- Public vs internal endpoints → different user groups

## Step 2: Build the Model

Organize findings into the C4 hierarchy:

```
Software System
├── People (users, roles, external actors)
├── External Systems (third-party services, APIs)
└── Containers (your deployable units)
    ├── Name, technology, description
    ├── Relationships to other containers
    └── Components (for drill-down)
        ├── Name, technology, description
        └── Relationships to other components
```

For each element, capture:
- **Name**: Clear, specific (not "business logic" or "backend")
- **Technology**: The actual framework/language/platform
- **Description**: One sentence about its responsibility
- **Relationships**: What it talks to, how (protocol), and why (purpose)

## Step 3: Generate Diagrams

Generate diagrams as **draw.io XML** (`.drawio` files). Always generate Level 1 and Level 2.

### draw.io XML format

Use the `<mxfile><diagram><mxGraphModel>` structure with `<mxCell>` elements.

### C4 color scheme

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

### Element label format

Every element label should include (using HTML in the `value` attribute):
- **Bold name**
- Element type in small text: `[Person]`, `[Software System]`, `[Container: Technology]`, `[Component: Technology]`
- Description in normal text

Example: `<b>API Server</b><br><font style="font-size:10px">[Container: Django 6.0, Python 3.12]</font><br><br><font style="font-size:11px">REST API handling mission CRUD and agent orchestration</font>`

### Diagram structure rules

- **Title**: Text cell at the top with `fontSize=18;fontStyle=1`
- **Key/legend**: Small boxes in a corner showing the color scheme
- **Relationships**: `edgeStyle=orthogonalEdgeStyle;rounded=1` with label showing purpose + protocol. Always use proper `source` and `target` attributes referencing element IDs — never use manual `sourcePoint`/`targetPoint` coordinates, which render as floating disconnected lines.
- **Boundaries**: Use `swimlane` style with `container=1;collapsible=0` — child elements use `parent="boundaryId"`
- **Layout**: People at top, system in scope in center, external systems around the edges or bottom. Most important element centered.
- **Canvas size**: `pageWidth="1600" pageHeight="1200"` minimum; increase for complex diagrams

### Spacing and layout rules (critical)

These rules prevent overlapping text and unreadable diagrams:

- **140px minimum** between context elements (people, external containers) and the boundary top, so edge labels don't overlap the boundary title text.
- **200px minimum** between boundary bottom and external systems below, so edge labels between them are readable and don't overlap the boundary line.
- **150px minimum gap** between sibling elements in the same row (containers, components), so relationship labels between them have room.
- **Center contents inside boundaries**: calculate total content width, subtract from boundary width, divide by 2 for left margin. Do this for each row independently.
- **Use explicit waypoints** (`<Array as="points">`) to route edges around obstacles. Waypoints should run through the gap between the boundary edge and external systems.

### Edge routing rules

- **Never route an edge through a component or container.** If an edge would cross an element, spread elements apart to create a clear lane, or reroute the edge with waypoints.
- **Edges that skip rows must route around, not through.** If a service in row 2 connects to an external system below the boundary, and row 3 (data stores) is in between, the edge must route along the left or right margin of the boundary and exit from the bottom — never vertically through row 3. Use waypoints to hug the boundary edge.
- **Cross-row edges** (e.g., connecting elements that aren't adjacent) must route above or below the intervening row using waypoints, not through it.
- **Edges exiting a boundary** to reach external systems should use waypoints at intermediate Y positions between the boundary bottom and the external system top, with each edge at a different Y to avoid overlapping.
- **All edges must use proper `source` and `target` attributes** referencing element IDs. Never use `sourcePoint`/`targetPoint` manual coordinates — these create disconnected lines and make the audit untraceable.

### Level 1: System Context

Show the software system as a single box, surrounded by users and external systems.

### Level 2: Container

Zoom into the system boundary (drawn as a dashed swimlane) to show containers with technology choices. Include people and external systems outside the boundary for context.

### Level 3: Component (on request or when drilling into a container)

Zoom into a single container (drawn as a dashed swimlane) to show its components. Include surrounding containers and external systems for context.

## Step 4: Layout Audit (mandatory — do this before saving)

After generating the initial diagram XML, perform this audit. If any check fails, adjust the layout and re-check. Repeat until all checks pass.

### 4a. Trace every edge path

For each edge, compute the full path by listing the absolute coordinates of every point: source exit point → each waypoint → target entry point. Each pair of consecutive points forms a segment. For each segment, check if the line intersects the bounding box (x, y, width, height) of every element in the diagram. If any segment crosses through any element:
- Route the edge around the element using waypoints along the boundary margin, OR
- Spread elements apart to create a clear lane

Special attention: edges connecting to external systems below the boundary often have a long vertical segment dropping through lower rows. These MUST route along the left or right margin first, then drop below the boundary, then turn horizontally to reach the target.

### 4b. Check edge label positions for overlaps

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

### 4c. Check parallel and bundled edges

**No two edges may share the same waypoint Y or X value.** When edges share a coordinate, draw.io renders them on top of each other, making it impossible to trace which line goes where. For every pair of edges:
- Each edge must use a **unique waypoint Y** (for horizontal runs) or **unique waypoint X** (for vertical runs), separated by at least **30px**.
- Source exit points from the same element must be spread across different positions (e.g., exitX=0.2 vs exitX=0.5 vs exitX=0.8). Never use the same exit point for two edges.
- Target entry points on the same element must also be spread (e.g., entryX=0.3 vs entryX=0.7).
- If two edges run parallel for any segment, offset one of them by at least 30px using additional waypoints.

Labels on parallel edges will also overlap if the edges are close. Since labels are centered on the longest segment, ensure the longest segments of nearby edges are in **different spatial areas** — either at different Y levels or with enough horizontal separation (at least 200px between label centers).

### 4d. Verify boundary title clearance

Check that no edge or edge label passes through or overlaps the boundary's swimlane header (the `startSize` area, typically 30px tall at the top of the boundary). If edges enter the boundary from above, they should connect at the boundary top edge, not route through the title.

## Step 5: Output

1. **Save the draw.io XML** to the project root:
   - Filenames: `system-context.drawio`, `containers.drawio`, `components-[container-name].drawio`

2. **Export to PNG** by running `drawio --export --format png --output <name>.png <name>.drawio` via Bash.

3. **Open in draw.io desktop** by running `drawio <filepath>` via Bash.

4. **Print a summary** of what was discovered:
   - Number of containers, components, external systems, and user types identified
   - Key technology choices detected
   - Any ambiguities or areas where manual refinement is recommended

## Guidelines

- **Be specific, not generic.** "FastAPI REST server handling order management" beats "API server."
- **Include technology choices.** The actual framework, database, protocol — not just "web app" or "database."
- **Annotate every relationship** with its purpose and protocol/mechanism.
- **Don't mix abstraction levels.** A container diagram shows containers, not classes.
- **For monorepos:** Start with the top-level scan to show all services as containers. Offer to drill into specific services for components.
- **When uncertain:** Note the ambiguity in the summary rather than guessing. Flag it for the user to clarify.
- **Omit infrastructure cross-cutting concerns** (logging, monitoring) from component diagrams unless they are architecturally significant.
- **Relationships should use prepositions** that match arrow direction: "reads from," "sends to," "makes API calls to."
