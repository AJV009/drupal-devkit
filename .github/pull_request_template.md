<!-- Select the type of contribution by keeping the relevant section and deleting the others -->

## Community Plugin Submission

**Plugin name:** `your-plugin-name`
**Repository:** https://github.com/your-user/your-repo

### Checklist

- [ ] My plugin repo has `.claude-plugin/plugin.json` with a `name` field
- [ ] My plugin has at least one of: `skills/`, `agents/`, `commands/`, or `hooks/`
- [ ] My plugin has a `LICENSE` file or a `license` field in `plugin.json`
- [ ] All `SKILL.md` files have valid YAML frontmatter
- [ ] I added only my entry to `community-registry.json` (no other file changes)
- [ ] The `name` is kebab-case, max 64 characters, and doesn't collide with existing plugins

### About the Plugin

<!-- Brief description of what your plugin does and who it's for -->

---

## Skill Contribution

**Skill name:** `your-skill-name`
**Target plugin:** `drupal-core` / `drupal-canvas` / other

### Checklist

- [ ] `SKILL.md` follows the [agentskills.io specification](https://agentskills.io/specification)
- [ ] Skill is platform-agnostic (no references to specific AI tools)
- [ ] Skill is standalone (works without project-specific context)
- [ ] Attribution added to `ATTRIBUTION.md` (if derived from other work)

### What This Skill Does

<!-- Brief description -->

---

## Bug Fix / Other

### What Changed

<!-- Description of the change -->

### Why

<!-- Motivation -->
