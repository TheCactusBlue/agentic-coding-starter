---
name: "domain:typescript"
description: "Loaded automatically when working with TypeScript code. Defines project conventions for type safety, testing, error handling, and preferred dependencies."
---

# TypeScript Conventions

## Idioms

- Enable strict mode in `tsconfig.json` — no exceptions
- Prefer `const` over `let`; never use `var`
- Use discriminated unions for state modeling over class hierarchies
- Prefer `unknown` over `any` — narrow types explicitly
- Use `readonly` on properties and arrays that should not be mutated
- Prefer `interface` for object shapes, `type` for unions and intersections
- Use template literal types for string patterns where useful
- Prefer `satisfies` operator to validate types without widening

## Project Structure

- Source code in `src/` with a clear module structure
- Use path aliases (`@/` or `~/`) configured in tsconfig for deep imports
- Barrel exports (`index.ts`) only at package boundaries — avoid within a package
- Colocate related files: components with their tests, types, and styles
- Configuration files at project root: `tsconfig.json`, `package.json`

## Testing

- Use vitest as the test framework
- Colocate test files next to source: `thing.ts` and `thing.test.ts`
- Use `describe`/`it` blocks with clear, behavior-focused descriptions
- Prefer `expect(...).toBe()` for primitives, `toEqual()` for objects
- Mock external dependencies at module boundaries, not internal functions
- Use `vi.fn()` for spies and `vi.mock()` for module mocks

## Error Handling

- Define typed error classes extending `Error` with a `code` property
- Use a Result pattern (`{ ok: true, data } | { ok: false, error }`) for expected failures
- Reserve `try/catch` for unexpected errors at system boundaries
- Never swallow errors silently — log or rethrow
- Validate external input at boundaries with zod; trust internal types

## Dependencies

- **Validation:** zod for runtime schema validation
- **Dates:** date-fns (tree-shakeable, functional)
- **HTTP client:** native fetch, or ofetch for convenience
- **Linting/formatting:** eslint + prettier, or biome
- **Build:** tsup for libraries, vite for applications

## Anti-patterns

- Using `any` to bypass type checking — use `unknown` and narrow
- Overusing `enum` — prefer `as const` objects or union types
- Barrel files (`index.ts`) deep within packages — causes bundling and circular import issues
- Mutation of shared state — prefer immutable patterns and pure functions
- Non-null assertion (`!`) as a habit — narrow types properly instead
- Ignoring `Promise` return values — always `await` or explicitly `void`
