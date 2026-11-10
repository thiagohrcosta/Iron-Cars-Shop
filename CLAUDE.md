# Iron Cars Shop — working agreement

- Write code, commits, PR titles/descriptions and GitHub issues in **English**.

## Before declaring a PR done

1. Run every CI gate locally:
   - `bin/rails db:test:prepare`, `bin/rails test`, `bin/rails test:system`
   - `bin/rubocop`
   - `bin/brakeman --no-pager`
   - `bin/importmap audit`
2. Review the PR diff as the DHH persona in [`docs/dhh-review.md`](docs/dhh-review.md), using its checklist (§3), output format (§4) and verdict rules (§5).
   - Fix every ❌ blocker the review finds in the PR itself, then review again.
3. Report the result after the test results, as a traffic light:
   - 🟢 **Green**: ✅ APPROVED. Nothing to adjust.
   - 🟡 **Yellow**: ⚠️ APPROVED WITH CHANGES. Recommendations listed; mergeable.
   - 🔴 **Red**: ❌ REJECTED. Blockers remain; do not merge.

   Put the traffic light and the review summary in the PR description, and report them to the user.
