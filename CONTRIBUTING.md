# Contributing to Architect

First off, thank you for considering contributing to Architect\! It’s people like you that make the open-source community such a fantastic place. We welcome any form of contribution, from reporting bugs and suggesting features to writing code and improving documentation.

## Code of Conduct

To ensure a welcoming and friendly environment, we have a [Code of Conduct](https://www.google.com/search?q=CODE_OF_CONDUCT.md) that all contributors are expected to follow. Please take a moment to read it before you participate.

## How Can I Contribute?

### Reporting Bugs

If you encounter a bug, please help us by reporting it. Good bug reports are incredibly helpful.

1.  **Check existing issues:** Before creating a new issue, please check the [Issues tab](https://www.google.com/search?q=https://github.com/mhdgning131/Architect/issues) to see if the bug has already been reported.
2.  **Create a new issue:** If it's a new bug, please provide a detailed report. Include:
      * Your operating system and Python version.
      * A clear, step-by-step description of how to reproduce the bug.
      * The exact error message you received.
      * What you expected to happen vs. what actually happened.

### Suggesting Enhancements

Have an idea for a new feature? We'd love to hear it.

1.  Go to the [Issues tab](https://www.google.com/search?q=https://github.com/mhdgning131/Architect/issues).
2.  Create a new issue, describing the feature you'd like to see, why it would be useful, and how you imagine it working.

## Your First Code Contribution

 Here’s how to set up your local environment and submit a contribution.

### 1\. Fork & Clone the Repository

  * **Fork** the repository by clicking the "Fork" button on the top right of the [main repo page](https://github.com/mhdgning131/Architect).
  * **Clone** your fork to your local machine:
    ```bash
    git clone https://github.com/YOUR-USERNAME/Architect.git 
    cd Architect
    ```

### 2\. Set Up Your Environment

  * It is highly recommended to use a Python virtual environment:
    ```bash
    python -m venv venv
    source venv/bin/activate  # On Windows, use `venv\Scripts\activate`
    ```
  * Install the project in "editable" mode along with its development dependencies:
    ```bash
    # Install the package itself in editable mode
    pip install -e .
    # Install tools needed for testing (e.g., pytest)
    pip install pytest
    ```

### 3\. Create a New Branch

Create a new branch for your changes. Use a descriptive name like `feature/add-xml-support` or `fix/crash-on-empty-file`.

```bash
git checkout -b your-branch-name
```

### 4\. Make Your Changes & Run Tests

  * Write your code and add new tests for your changes.
  * Run the test suite to make sure everything is still working correctly:
    ```bash
    pytest
    ```

### 5\. Submit a Pull Request

  * Once you're happy with your changes, commit them with a clear message:
    ```bash
    git commit -m "feat: Add support for XML output"
    ```
  * Push your branch to your fork on GitHub:
    ```bash
    git push origin your-branch-name
    ```
  * Go to your fork on GitHub. You will see a "Compare & pull request" button. Click it.
  * Write a clear description of what your pull request does and link to any relevant issues.

Thank you again for your contribution. We look forward to seeing your pull request\!
