commons
=======

Common scripts... used by MonTransit projects.

## Automatic pull request merging

`shared-overwrite-all-repositories/.github/workflows/mt-auto-merge.yml` is deployed
to all managed repositories, including submodules. It squash-merges non-draft
pull requests opened by `montransit`, Copilot, or `dependabot[bot]` after approval
and once every reported check has passed (neutral/skipped checks are allowed).
Failed, cancelled, pending, or missing checks block merging, including checks
that are not required by branch protection.

Each target repository must allow squash merging and grant GitHub Actions
write access to contents and pull requests. Configure the target branch with
either classic branch protection or an active ruleset requiring CODEOWNER
approval, with a valid `CODEOWNERS` file. Require the relevant CI checks in those
rules as well, so GitHub enforces them atomically when merging. The workflow
refuses to merge without enforced CODEOWNER approval and an approved, clean
merge state; it does not change repository settings or bypass protections.

PR updates, reviews, completed workflows/checks, and commit statuses trigger
reevaluation; it can also be run manually. The companion
`mt-auto-merge-review.yml` signals review changes without write permissions;
its completion triggers the privileged workflow from the default branch.
Both workflow files must be deployed. The merger uses `GITHUB_TOKEN` without
checking out PR code or using a personal access token. Consequently, its merges
do not trigger other GitHub Actions workflows listening for `push` events.
