# Extension Proposal: Automated Semantic Versioning

## Identified Shortcoming

Our current release process relies on **manual version tagging** and **ad-hoc changelog updates**. This introduces inconsistencies, increases the risk of human error and creates friction in delivering new features or bug fixes.

### Current Pain Points

- **Manual tagging** leads to versioning mistakes or skipped tags.  
- **Inconsistent changelogs** reduce traceability and transparency.  

## Proposed Extension

Adopt a **semantic-release workflow** to automate version management and changelog maintenance across all services:

1. **Commit Convention Enforcement**  
   Standardize commit messages using prefixes (e.g., `feat:`, `fix:`, `chore:`) to clearly indicate the type of change.

2. **Automated Version Bumping**  
   Integrate a semantic-release tool that:
   - Analyzes commit history since the last release.  
   - Determines the appropriate version bump (`major`, `minor`, or `patch`).  
   - Updates the project’s version metadata automatically.

3. **Changelog Generation**  
   Configure the release workflow to:
   - Generate human-readable changelog entries based on commit messages.  
   - Append entries to a central `CHANGELOG.md` with proper date and version headings.

4. **CI Pipeline Integration**  
   Add a dedicated release job in the CI pipeline that:
   - Runs on each merge to the main branch.  
   - Fetches full commit history.  
   - Executes the semantic-release tool to update version metadata and changelog.  
   - Creates a new Git tag and publishes a formal release artifact.

## Benefits

- **Frictionless releases**—no manual steps for versioning or changelog updates.  
- **Consistent metadata**—tags, versions, and changelogs are always aligned.  
- **Enhanced visibility**—releases are accompanied by clear, automatic release notes.  
- **Reduced errors**—semantic rules prevent mislabeling and skipped versions.  
- **Improved onboarding**—contributors follow a simple commit convention.  

## Evaluation Plan

To assess the impact of this extension, we will compare the manual and automated release processes using metrics such as:

| Metric                         | Manual Process | Automated Process |
|--------------------------------|----------------|-------------------|
| Average time to release        | X minutes      | Y minutes         |
| Changelog completeness         | Variable       | Always generated  |
| Release errors (tag mismatch)  | Occasional     | None expected     |
| Release frequency              | Lower          | Higher            |

A significant reduction in manual steps and errors, along with increased release cadence, will validate the success of this improvement.

## Related Tools and Industry Practice

- [Conventional Commits](https://www.conventionalcommits.org/)  
- [Python Semantic Release](https://python-semantic-release.readthedocs.io/)  

## Limitations

- Requires discipline in commit messaging.  
- May need an initial cleanup of historical releases.  

---

Implementing this semantic-release extension will streamline our workflow, improve reliability and support rapid and reproducible deployments.
