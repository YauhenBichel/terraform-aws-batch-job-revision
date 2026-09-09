#!/usr/bin/env python3
"""The usage example in the README has to actually apply.

A module's README is the only thing most people read before pasting. This one
told you to set nine inputs and the module required eleven, so a copy-paste
ended at "No value for required variable" twice over. Nothing caught it,
because `terraform validate` never looks at the README and the terratest that
would have needed those variables is not wired to any workflow.

This compares the two directly: every variable in variables.tf with no default
must appear in the README's first HCL block.

    python3 scripts/check_readme_example.py
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# variable "name" { ... } up to the closing brace in column 0.
_VARIABLE = re.compile(r'^variable\s+"([^"]+)"\s*\{(.*?)^\}', re.S | re.M)
# A default anywhere in the block body, at any indent.
_DEFAULT = re.compile(r"^\s*default\s*=", re.M)
# The first fenced hcl block in the README is the usage example.
_HCL = re.compile(r"```hcl\n(.*?)```", re.S)


def required_variables(text: str) -> list[str]:
    return [
        name
        for name, body in _VARIABLE.findall(text)
        if not _DEFAULT.search(body)
    ]


def assigned_in(block: str) -> set[str]:
    return set(re.findall(r"^\s*([a-z_][a-z0-9_]*)\s*=", block, re.M))


def main() -> int:
    variables = (ROOT / "variables.tf").read_text(encoding="utf-8", errors="replace")
    readme = (ROOT / "README.md").read_text(encoding="utf-8", errors="replace")

    example = _HCL.search(readme)
    if not example:
        print("No ```hcl block in README.md; the usage example is missing.")
        return 1

    required = required_variables(variables)
    if not required:
        print("No required variables found in variables.tf; check the parser.")
        return 1

    missing = [name for name in required if name not in assigned_in(example.group(1))]

    if missing:
        print("The README usage example does not set every required variable.")
        print("Copying it produces 'No value for required variable' for:")
        for name in missing:
            print(f"    {name}")
        print("\nEither set it in the example, or give it a default in variables.tf.")
        return 1

    print(f"README example sets all {len(required)} required variables.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
