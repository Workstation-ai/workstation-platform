# Project Name

One-sentence description of what this project is.

## Setup Commands

```bash
# Install dependencies
<exact command, e.g.: npm install / pip install -e . / go mod download>

# Start dev server (if applicable)
<exact command, e.g.: npm run dev / python manage.py runserver>

# Environment setup (if needed)
<exact command, e.g.: cp .env.example .env>
```

## Build Commands

```bash
# Build the project
<exact command>

# Build for production
<exact command>
```

## Test Commands

```bash
# Run all tests
<exact command, e.g.: npm test / pytest / go test ./...>

# Run specific test
<exact command>

# Run linter
<exact command, e.g.: npm run lint / ruff check . / golangci-lint run>

# Run type checker (if applicable)
<exact command, e.g.: tsc --noEmit / mypy .>
```

## Code Style

<!-- Include only project-specific conventions. Skip what the agent already knows. -->

- Language: <e.g., TypeScript strict mode>
- Formatter: <e.g., Prettier, gofmt, ruff format>
- Linter: <e.g., ESLint, golangci-lint>
- Naming: <e.g., camelCase for variables, PascalCase for components>
- Imports: <e.g., absolute imports from src/>

## Project Structure

<!-- Include only for monorepos or complex layouts. Skip for simple projects. -->

```
src/
├── components/    # UI components
├── services/      # Business logic
├── utils/         # Shared utilities
└── index.ts       # Entry point
```

## Architecture

<!-- Include for multi-service or complex systems. Skip for single-purpose projects. -->

```
<component diagram>
```

- **Service A**: Description and port
- **Service B**: Description and port

## Key Configuration

<!-- Include only non-obvious config. Skip defaults. -->

| Variable/Flag | Default | Description |
|---------------|---------|-------------|
| `DATABASE_URL` | — | Required. Postgres connection string |
| `--port` | 3000 | Server port |

## Skills Reference

<!-- Include only if skills/ directory exists. Skip if no skills. -->

| Skill | Trigger | Covers |
|-------|---------|--------|
| [skill-name](skills/skill-name/SKILL.md) | keyword, trigger | Brief description |

## Security Considerations

<!-- Include only if there are auth, secrets, or sensitive data. Skip for public repos with no secrets. -->

- Secrets in `<location>`, never commit
- Auth via `<mechanism>`
- Sensitive paths: `<paths>`

## Gotchas

<!-- The most valuable section. Include non-obvious behaviors agents will hit. -->

- **Gotcha 1**: What happens and why
- **Gotcha 2**: What happens and why
- **Gotcha 3**: What happens and why

## Git Conventions

- Commit format: `<type>: <description>` (conventional commits)
- Branch naming: `<type>/<ticket>-<description>`
- PR requirements: <e.g., tests pass, lint clean, one approval>
