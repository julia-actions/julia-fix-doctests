# julia-fix-doctests

This repository provides the `julia-fix-doctests` workflow which runs `doctest(MyPackage; fix=true)` to fix your doctests using Documenter.jl's tools.

Settings:
```yaml
inputs:
  package_path:
    description: 'Path to the directory of the package. Only required for subdirectory packages.'
    default: ''
    required: false
  project:
    description: 'Value passed to the --project flag. The default value is "docs"'
    default: 'docs'
    required: false
```

## Example workflow

The following provides an example workflow that uses the `julia-fix-doctests` workflow
in order to push a commit fixing doctests when a label is applied to a PR.

```yaml
# This workflow automatically fixes doctests on PRs when the label `fix doctests`
# is applied. It removes the label upon successful completion.
name: fix-doctests
on:
  pull_request:
    types: [ labeled ]
jobs:
  build:
    # if you want to choose a different label to trigger fixing the doctests, change it here and in the last step
    if: ${{ github.event.label.name == 'fix doctests' }}
    runs-on: ubuntu-latest
    steps:
    # Install the right version of Julia for your doctests
    - uses: julia-actions/setup-julia@latest
      with:
        version: 1.6.2
    
    # Check out the code
    - uses: actions/checkout@v2
      with:
      # needs a deploy key, but not a base64-encoded one like Documenter's keys usually are.
      # Note: this is only needed if you want the commit pushed by fixing the doctests to
      # itself trigger github workflows (such as your doctests or CI).
       ssh-key: ${{ secrets.DOCTEST_KEY }}
    
    # Now we fix the doctests in the code we just checked out.
    - uses: julia-actions/julia-fix-doctests@v0.1.0
    
    # Push the changes back
    - uses: stefanzweifel/git-auto-commit-action@v4
      with:
        commit_message: Fix doctests
      
    # Remove the label
    - uses: actions-ecosystem/action-remove-labels@v1
      with:
        labels: 'fix doctests'
        github_token: ${{ secrets.GITHUB_TOKEN }} # needed to remove the label
```
