---
id: git-workflow
title: "Git rules: feature branches, no artifacts, no history rewrites"
category: decision
status: active
created: "2026-08-15T02:17:00"
updated: "2026-08-15T02:17:00"
---

<!-- compiled_truth -->
# Git workflow rules

**Decision: follow strict git rules from this point forward:**

- **Do not push directly to main for feature work** — create feature branches for implementation work.
- Keep commits focused and meaningful.
- **Do not commit**: `.venv`, generated WAV files, downloaded TTS models, model caches, secrets/API keys, local environment files containing secrets.
- Maintain an appropriate `.gitignore` (already in place).
- **Do not rewrite history. Do not force-push. Do not modify the remote.**
- Initial repo setup used `main`; future development uses feature branches.

Related: [[command-code-role]].


## Timeline

- time: 2026-08-15T02:17:00
  kind: decision
  summary: "Created this page: Git rules: feature branches, no artifacts, no history rewrites"
  source: project brief
  affects: [git-workflow]

- time: 2026-08-15T02:17:00
  kind: decision
  summary: captured git rules
  source: project brief
  affects: [git-workflow]
