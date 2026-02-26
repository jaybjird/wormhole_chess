# pubspec.yaml Formatting Rules

## Version Number Formatting

- **Never use double quotes for version numbers** in pubspec.yaml files
- Use single quotes for complex version numbers (ranges, inequalities, multiple constraints)
- Use no quotes for simple version numbers
- Examples of complex versions that need single quotes:
  - `sdk: '>=3.2.3 <4.0.0'`
  - `publish_to: 'none'`
  - `version: '>=1.0.0 <2.0.0'`

## Simple Version Formatting

- Use no quotes for simple version constraints
- Examples of simple versions:
  - `version: 1.0.0`
  - `version: 1.2.3+4`

## Examples

### Correct Usage
```yaml
environment:
  sdk: '>=3.2.3 <4.0.0'

publish_to: 'none'

version: 1.0.0+1
```

### Incorrect Usage
```yaml
environment:
  sdk: '>=3.2.3 <4.0.0'  # Wrong - should be single quotes

publish_to: "none"  # Wrong - should be single quotes

version: "1.0.0+1"  # Wrong - should be no quotes
```

## Enforcement

- During code reviews, check all pubspec.yaml files for proper quote usage
- Ensure consistency across all packages in the monorepo
- Pay special attention to `sdk`, `publish_to`, and complex version constraints
- Note: VS Code auto-formatting is disabled for YAML files to prevent quote overrides
- Manual formatting should be used to maintain quote consistency
