# Contributing to BCML macOS Launcher

Thank you for your interest in contributing to BCML macOS Launcher! This document provides guidelines and instructions for contributing to this project.

## Code of Conduct

Please be respectful and considerate in all interactions. We aim to foster an inclusive, welcoming community for all contributors.

## How to Contribute

There are many ways to contribute to this project:

1. **Reporting Bugs**: If you find a bug, please open an issue with a clear description, steps to reproduce, expected behavior, and actual behavior.

2. **Suggesting Enhancements**: If you have ideas for new features or improvements, open an issue to discuss them.

3. **Code Contributions**: We welcome pull requests for bug fixes, enhancements, and new features.

4. **Documentation**: Help improve or correct the documentation.

5. **Testing**: Try the application on different versions of macOS and report any issues.

## Development Setup

1. Fork the repository on GitHub
2. Clone your fork locally
3. Create a feature branch (`git checkout -b feature/my-new-feature`)
4. Make your changes
5. Run the build script to test your changes (`./scripts/build.sh`)
6. Commit your changes (`git commit -am 'Add some feature'`)
7. Push to the branch (`git push origin feature/my-new-feature`)
8. Create a new Pull Request

## Style Guidelines

### Shell Scripting Style

- Use 2 spaces for indentation
- Add comments to explain complex logic
- Use lowercase for variable names and uppercase for constants
- Include proper error handling

### Git Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Where `type` is one of:

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation changes
- **style**: Changes that don't affect functionality (formatting, etc.)
- **refactor**: Code changes that neither fix bugs nor add features
- **test**: Adding or updating tests
- **chore**: Changes to the build process or auxiliary tools

## Pull Request Process

1. Update the README.md or documentation with details of any changes if applicable
2. Make sure your code passes all existing tests
3. The PR should work for macOS Catalina (10.15) and later
4. A maintainer will review your PR and may request changes before merging

## License

By contributing to this project, you agree that your contributions will be licensed under the project's [MIT License](LICENSE).

## Questions?

If you have any questions about contributing, please open an issue or reach out to the maintainers.

Thank you for your contributions!
