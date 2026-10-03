---
name: release
description: Use when publishing a new Presswerk version or asked to cut a patch, minor, or major release. Guides the version choice, updates CHANGELOG.md from commits since the last tag, runs the mise release task, pushes commits and the tag, and publishes a GitHub release. Do not use for retrospective releases of existing tags.
---

# Release Presswerk

Use this workflow only in the Presswerk repository for a **new** release. A GitHub release for an existing tag is a different task: do not run `mise run release` for it.

1. **Ask first:** Ask the user to choose `patch`, `minor`, or `major`, even if a version number was suggested. Do not edit, commit, or publish until they choose. Read `mix.exs` and `scripts/release.exs` to calculate and show the resulting version. For a current `X.Y.Z-dev`, `patch` releases `X.Y.Z`; `minor` releases `X.(Y+1).0`; `major` releases `(X+1).0.0`.

2. **Prepare the contents:** Identify the most recent release tag reachable from the current branch (`git describe --tags --abbrev=0`). Read `git log --oneline <last-tag>..HEAD` and the relevant diff/code to determine what actually changed. Review `CHANGELOG.md` and existing GitHub release notes for style. Write a concise, technical English changelog section headed `## [X.Y.Z](https://github.com/pklink/presswerk/releases/tag/vX.Y.Z) - YYYY-MM-DD` at the top of `CHANGELOG.md`; derive its entries from the commits since that tag, not from guesses or the version number. Draft separate, user-facing English GitHub release notes from the same changes, including upgrade instructions only if needed. Mention the pinned image `ghcr.io/pklink/presswerk:vX.Y.Z` when relevant; do not advise using `latest` for a historical release.

3. **Show and confirm:** Display the proposed version, changelog entry, complete GitHub notes, current `git status`, and any commits already ahead of the upstream (`git log --oneline @{upstream}..HEAD`). Explicitly mention that these existing commits will be pushed too. Ask for approval of the draft **before** any release commits, pushes, or publishing. Incorporate corrections first.

4. **Prepare the clean tree:** Confirm the branch is `main`, the upstream/remote points to `pklink/presswerk`, the chosen tag does not already exist locally or on GitHub, and the remote branch has not moved unexpectedly. Do not sweep unrelated local changes into the release: resolve them with the user if present. Commit only the approved `CHANGELOG.md` update with a Conventional Commit message such as `docs: update changelog for vX.Y.Z`. This makes the tree clean for `scripts/release.exs`. Run `mix precommit` (also required before finishing) and stop if checks fail.

5. **Release locally:** Run `mise run release -- <patch|minor|major>` with the chosen part. The task runs `mix precommit`, commits the release version in `mix.exs`, creates an annotated `vX.Y.Z` tag, and commits the next `-dev` version. Verify the tag points at the release commit and that the tree is clean. Do not duplicate these commits or recreate the tag manually.

6. **Publish in order:** Push `main` with its existing and new commits using a normal `git push origin main`, then push the new tag with `git push origin vX.Y.Z`. If either push fails, stop and report the actual state; do not force-push. Create the GitHub release from the **existing remote tag** using `gh release create vX.Y.Z --repo pklink/presswerk --verify-tag --title vX.Y.Z --notes '...'`; pass `--latest` if it is the newest version, otherwise `--latest=false`. Verify it with `gh release view` and report its URL. Check the tag's GitHub Actions image build; if still running or failing, report that separately rather than claiming the image is ready.

If anything fails after a commit or push, inspect the actual local and remote state and resume only the missing step. Never rerun the version bump or create duplicate tags/releases blindly.
