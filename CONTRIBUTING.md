# Contributing to Aurora Health

We're excited that you're interested in contributing to Aurora Health! To maintain the high quality of this project, we follow a set of guidelines and standards.

## Code of Conduct
Please be respectful and professional in all interactions within the community.

## Development Workflow

1. **Fork & Clone**: Fork the repository and clone it locally.
2. **Feature Branch**: Create a descriptive branch name (e.g., `feat/add-heart-rate-chart`).
3. **Write Code**: Implement your changes while following our coding standards.
4. **Test**: Ensure that your changes don't break existing functionality.
5. **Pull Request**: Submit a PR with a clear description of the changes and why they are needed.

## Coding Standards

### Dart & Flutter
- **Follow Effective Dart**: Adhere to the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).
- **Linting**: Run `flutter analyze` before committing.
- **Documentation**: Provide clear comments for complex logic and public APIs.
- **Naming Conventions**:
  - Files: `snake_case.dart`
  - Classes: `UpperCamelCase`
  - Variables/Functions: `lowerCamelCase`

### State Management
- Use **Riverpod** for all state management.
- Avoid using `setState` in complex widgets; prefer `ConsumerWidget` or `ConsumerStatefulWidget`.
- Define providers in a separate `providers` directory within each feature.

## Design Principles (Aurora UI)

Aurora Health is a premium application. All UI changes must adhere to the **Aurora UI** design system:
- **Aesthetics**: Use premium colors, smooth gradients, and subtle micro-animations.
- **Accessibility**: Ensure high contrast ratios and proper touch target sizes (min 44x44px).
- **Consistency**: Use the spacing tokens and shadows defined in `MASTER.md`.
- **Icons**: Only use `FeatherIcons` or approved SVGs. **No emojis as icons.**

## Commit Messages
We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:
- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `refactor:` for code changes that neither fix a bug nor add a feature
- `style:` for changes that do not affect the meaning of the code (white-space, formatting, etc.)

## Pull Request Guidelines
- Keep PRs focused on a single change.
- Include screenshots or screen recordings for UI-related changes.
- Ensure the build passes and there are no linting errors.

---

Thank you for helping us build the future of medical follow-ups!
