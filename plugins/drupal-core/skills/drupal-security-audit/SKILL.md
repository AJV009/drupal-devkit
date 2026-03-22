---
name: drupal-security-audit
description: Comprehensive security auditing workflow for Drupal sites. Covers user accounts, role permissions, module inventory, site configuration, text formats, views access, file exposure, content injection scanning, and integration with the security_review contrib module. Use when performing security assessments, hardening a Drupal site, or investigating potential vulnerabilities.
version: 1.0.0
source:
  module: ai_agents_security_review
  agent: security_reviewer
  repository: ai_agents_experimental_collection
---

# Drupal Security Audit

Perform comprehensive, read-only security assessments of a Drupal site. Produce a clear, actionable report organized by severity. Never make changes to the site during an audit.

## Audit Workflow

A complete security audit follows five phases. Each phase can also be run independently for targeted reviews.

### Phase 1: Security Review Module

The `security_review` contrib module provides a suite of automated checks. When it is available:

1. **List available checks** to see every registered check with its ID, title, skip status, and last result.
2. **Run all checks** (or a subset by ID) to get a pass/fail/warn summary.
3. **Get detailed findings** for any check that returned FAIL or WARN, including remediation advice.

If the module is not installed, skip to Phase 2 -- all custom audits work independently.

### Phase 2: User and Permission Audit

Audit user accounts and role permissions for common misconfigurations:

- **UID 1 (super-admin)**: Verify the account is blocked or has a non-default username. An active uid 1 with the name "admin" is a predictable target.
- **Privileged users**: Identify every account holding an administrator role. Flag active admins that have never logged in and recently created accounts with admin roles.
- **Recent accounts**: Review accounts created in the last 30 days. New accounts with elevated roles warrant immediate investigation.
- **Blocked accounts**: Review the blocked-user list for patterns (e.g., compromised accounts that were disabled).
- **Role permissions**: Scan every role for dangerous permissions (`administer modules`, `bypass node access`, `use PHP for settings`, `synchronize configuration`, etc.). Permissions on the `anonymous` and `authenticated` roles are especially critical.

#### Dangerous Permissions Reference

| Severity | Permissions |
|----------|-------------|
| **Critical** | `use PHP for settings`, `administer modules`, `administer software updates`, `administer site configuration`, `administer permissions`, `administer users`, `bypass node access`, `synchronize configuration`, `import configuration`, `administer filters` |
| **Warning** | `administer content types`, `administer taxonomy`, `administer views`, `administer blocks`, `access site reports`, `administer menu`, `administer nodes`, `use text format full_html`, `access all views`, `administer search` |

Any `administer *` permission on anonymous or authenticated roles is a critical finding.

### Phase 3: Configuration and Module Audit

Review site-level settings and the module landscape:

- **Site configuration**: Check error-reporting level (should be hidden from visitors), trusted-host patterns (must be set), cron last-run time, private file path configuration, and PHP `display_errors` / `expose_php` settings.
- **Input formats (text formats)**: Audit every text format for missing HTML sanitization, the PHP code filter, dangerous allowed tags, and which roles have access.
- **Views access**: Find enabled Views displays with no access plugin configured (access set to `none`). These are publicly reachable without restriction.
- **Enabled modules**: Flag development modules (`devel`, `kint`, `webprofiler`, `field_ui`, `views_ui`, `dblog` in production) and unsupported / dev-version modules.
- **Security updates**: Query Update Manager data for modules and core with known security advisories. Report current version vs. recommended version.
- **Dangerous files**: Scan the webroot for exposed sensitive files (`.git/`, `.env`, `phpinfo.php`, SQL dumps, backup archives, `CHANGELOG.txt`, `INSTALL.txt`).

### Phase 4: Content Scanning

Scan content entities for potential stored XSS or PHP injection:

- Search text fields for patterns: `<script`, `<?php`, `<iframe`, `javascript:`, `eval(`.
- Default scope is nodes, but any fieldable entity type can be scanned.
- Limit the scan size (default 100 entities) to avoid performance impact.

### Phase 5: Compile the Report

Organize all findings into a severity-ranked report:

| Section | Contents |
|---------|----------|
| **Executive Summary** | Overall security posture with Critical / Warning / Info counts |
| **Critical Issues** | Must-fix immediately -- data exposure, code execution risks |
| **Warnings** | Should be addressed soon -- information disclosure, best-practice violations |
| **Informational** | Nice-to-have improvements |
| **Recommendations** | Prioritized action items with specific remediation steps |

For every finding, explain **why** it is a security concern, not just what was found.

## Tool Inventory

The audit relies on 12 dedicated read-only tools plus 2 module-management helpers:

| # | Tool | Operation | Description | Key Parameters |
|---|------|-----------|-------------|----------------|
| 1 | `list_security_checks` | Read | Lists all `security_review` checks with ID, title, skip status, and last result | -- |
| 2 | `run_security_review` | Read | Runs all or specific `security_review` checks; returns pass/fail/warn/info summary | `checks`: `"all"` or JSON array of check IDs |
| 3 | `get_check_details` | Read | Gets detailed findings and remediation help for a single check | `check_id` (required): plugin ID, e.g. `"admin_user"` |
| 4 | `audit_users` | Read | Audits user accounts: uid 1 status, privileged users, recent accounts, blocked accounts | `audit_type`: `"all"`, `"uid1"`, `"privileged"`, `"recent"`, `"blocked"` |
| 5 | `audit_role_permissions` | Read | Scans roles for dangerous permissions; flags anonymous/authenticated escalations | `role`: machine name or `"all"` |
| 6 | `check_site_configuration` | Read | Checks error reporting, trusted hosts, cron, private files, PHP settings | -- |
| 7 | `check_input_formats` | Read | Audits text formats for missing HTML filtering, PHP code filter, dangerous tags | -- |
| 8 | `check_views_access` | Read | Finds Views displays with no access control | -- |
| 9 | `audit_enabled_modules` | Read | Flags development and risky modules in production | -- |
| 10 | `check_security_updates` | Read | Reports modules/core with known security vulnerabilities via Update Manager | -- |
| 11 | `check_dangerous_files` | Read | Scans webroot for `.git/`, `.env`, `phpinfo.php`, SQL dumps, backups, info files | -- |
| 12 | `scan_content_for_injections` | Read | Scans entity text fields for `<script`, `<?php`, `<iframe`, `javascript:`, `eval(` | `entity_type`: defaults to `"node"`; `limit`: defaults to `"100"` |
| 13 | `enable_module` | Write | Enables a Drupal module (from `ai_agents_module_manager`) | module name |
| 14 | `disable_module` | Write | Disables a Drupal module (from `ai_agents_module_manager`) | module name |

Tools 1-3 require the `security_review` contrib module to be enabled. Tools 4-12 work without any contrib dependencies. Tools 13-14 are used only for temporarily enabling/disabling `security_review` when needed.

## Example Workflows

### Full Site Audit

> "Run a complete security audit of the site"

Execute all five phases in order. If `security_review` is not already enabled, enable it for the audit and disable it when finished. Compile a full severity-ranked report.

### User Account Investigation

> "Audit all user accounts for suspicious activity"

Use `audit_users` with `audit_type="all"` to check uid 1 status, list all privileged users, review recently created accounts, and inspect blocked accounts. Follow up with `audit_role_permissions` to check what each role can do.

### Permission Hardening

> "Check the permissions assigned to each role for dangerous access"

Run `audit_role_permissions` with `role="all"`. Focus on anonymous and authenticated roles first. Any `administer *` permission on these roles is a critical finding. Provide specific remediation: which permissions to revoke and why.

### Module Security Check

> "Check if there are any security updates available"

Run `check_security_updates` to query Update Manager data. For each finding, report the project name, current version, and recommended security release. Also run `audit_enabled_modules` to flag dev-version or unsupported modules.

### Configuration Review

> "Check the site configuration for security issues"

Run `check_site_configuration`, `check_input_formats`, and `check_views_access` together. Look for error messages exposed to visitors, missing trusted-host patterns, text formats with the PHP code filter, and Views with no access restrictions.

### Content Injection Scan

> "Scan the content for potential XSS or injection attacks"

Run `scan_content_for_injections` with default parameters to scan up to 100 nodes. For larger sites, increase the `limit` or target specific entity types. Report any entities containing suspicious patterns with their entity ID and field name.

### Webroot File Exposure

> "Are there any dangerous files in the web root?"

Run `check_dangerous_files` to scan for `.git/`, `.env`, `phpinfo.php`, SQL dumps, backup archives, and Drupal info files that should not be publicly accessible. Each finding includes the file path and the security risk it poses.

## Guidelines

- **Read-only**: Never modify site state during an audit (except temporarily enabling/disabling `security_review` when needed).
- **Explain the risk**: For every finding, explain the attack vector and potential impact, not just the misconfiguration.
- **Provide remediation**: Include specific, actionable steps to resolve each issue.
- **Prioritize by risk**: Rank findings by actual exploitability, not just severity labels.
- **Continue on failure**: If a tool fails or a module is missing, note it in the report and proceed with the remaining checks.
- **Clean up**: If `security_review` was enabled for the audit, disable it afterward to leave the site in its original state.
