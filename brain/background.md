---
slug: background
title: Project background
role: project background
updated: "2026-08-15T02:08:11"
---

# Project background

## Why

Users of navigation apps like Waze want **personalized voice instructions** — their own words, humor, or style — instead of the default navigation voice. The project builds a tool that lets users customize navigation instruction text, synthesize it with TTS, preview it, and record it into Waze.

The immediate blocker is technical: **which local/open-source TTS engine produces high-quality Nepali navigation speech?** A reproducible benchmark must answer this before any product UI is built.

## Goals

- Determine the best open-source/local TTS engine for **Nepali navigation instructions** (quality, pronunciation, clarity, speed, resource use).
- Maintain a standardized navigation phrase corpus that every engine is evaluated against.
- (Later, after engine selection) A workflow: navigation situation → standard instruction → custom instruction → TTS → preview → recording mode → preparation delay → generated voice plays → user manually records into Waze.

## Non-goals (current milestone)

- **No Flutter application yet** — deferred until TTS evaluation provides sufficient evidence.
- **No Waze integration** — no automatic Waze modification; the workflow is manual recording. Deferred until after the MVP/TTS workflow works. Do not assume undocumented Waze APIs or recording capabilities.
- **No production backend** — a future Python/FastAPI TTS service is *possible*, but nothing is built now.
- No Firebase, Supabase, auth, database, or cloud infrastructure at this stage.

## Target user

Waze users who want **personalized navigation voice instructions** — initially evaluated for **Nepali** speech quality. The benchmark itself is used by developers/researchers; the eventual product serves end users.
