# Godot Standards

- Prefer composition over inheritance.
- One responsibility per script.
- Prefer Resources for configuration.
- Use Signals instead of tight coupling.
- Avoid magic numbers.
- Prefer exported variables.
- Keep scripts under ~250 lines.
- Comment why, not what.
- Use static typing everywhere possible (`var health: int = 100`, typed function
  signatures).
- Naming: `snake_case` for files, folders, variables, and functions;
  `PascalCase` for `class_name` and node names.
- Organize project folders by feature, not by node type (see
  `game-architecture.md#folder-structure`).
- Treat autoloads as a last resort; default to passing dependencies explicitly.
- Every feature has a spec before implementation; reference the spec ID
  (e.g. `Spec 001`) in commit messages and PR titles.
