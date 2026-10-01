-- Custom environment variables. Loaded after hyprland/env.lua, so anything
-- set here wins.
--
-- Currently empty — kept as the designated place for machine-specific env
-- overrides. hyprland/services/create_custom_config.lua recreates this file
-- if it is ever deleted.

-- glibc gives each qs thread its own malloc arena and rarely returns freed
-- memory; capping arenas took qs from ~1.35 GB to ~630 MB (2026-10-01).
hl.env("MALLOC_ARENA_MAX", "2")
