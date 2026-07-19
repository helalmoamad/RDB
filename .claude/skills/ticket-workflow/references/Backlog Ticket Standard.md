# RDB Backlog Ticket Standard

> **Purpose:** This is the official reference for writing tickets (User Stories / Work
> Items) in Ramaaz Digital Bank (RDB). Every team member must follow it. Any ticket that
> does not follow this standard is sent back to its author to be rewritten.

## Required metadata (ClickUp Custom Fields)

Every one of these fields must be filled at the top of the ticket:

| Property | Type | Required | Description |
|---|---|---|---|
| **Title** | Text | ✔️ | Short title in the form: Verb + Object (e.g. "Create Wallet") |
| **ID** | Auto | ✔️ | Generated automatically |
| **Status** | Status | ✔️ | Official workflow (below) |
| **Backbone** | Select | ✔️ | The module (Authentication, Onboarding/Registration, Passcode, Biometric/Face, Wallet, KYC, Transfers/Payments, Security, Notifications (FCM), Profile, Localization…) |
| **Actor** | Multi-select | ✔️ | Normal User, System Admin, System |
| **Assignee** | Person | ✔️ | The responsible person |
| **Time Estimate (h)** | Number | ✔️ | Estimate in hours |
| **Sprint** | Relation | ⬜ | Linked sprint |
| **User Story Relation** | Relation | ⬜ | Link to the Epic |
| **Estimation per User Story** | Relation | ⬜ | Extra estimates (optional) |

### Status workflow

`Backlog` → `Planned` → `TODO` → `In progress` → `Ready For Developer Review` →
`Ready For EM Review` → `EM Testing (DEV ENV)` → `Ready For Release` →
`In Release (MAIN)` → `Released To PROD`

## Body — exactly 3 sections, in this order

Copy this template as-is into the Description.

```markdown
## User Story

As **a [Actor / role]**,
I want to be able to **[action / capability]**,
so that **[business value / benefit]**.

[One short paragraph: scope, key constraints, what is in/out of scope,
references to related stories by ID.]

---

# Acceptance Criteria

## Session & Security Safety
1. [Atomic, testable statement — user accesses only their own account/session.]
2. [Atomic, testable statement — tokens/passcodes/biometric state never leaked or cross-used.]

## Authorization
1. [Who may perform the action.]
2. Unauthorized attempts return 401/403 (API) / hide the control (UI).

## General Behavior
1. [What the feature does in general.]

## Form Fields

### Required Fields
1. **Field A**
2. **Field B**

Rules:
1. All required fields are validated before saving.

### Optional Fields
1. Field C
2. Field D

## Behavior After Saving
1. [What happens after a successful save.]

## Validation & Constraints
1. [Patterns, formats, mandatory-field enforcement.]

## UI & API Consistency
1. UI and API enforce identical rules.
2. Errors are returned in a structured format and surfaced in the UI.

## Audit & Logging
1. [What is logged on success.]
2. [What is logged on failure.]

---

# Test Cases

## Happy Path — [Descriptive scenario name]
**Given** [precondition]
**And** [extra precondition]
**When** [action]
**Then**
- [Expected, observable result]
- [Expected, observable result]

---

## Validation Error — [Descriptive scenario name]
**Given** [precondition]
**When** [invalid action / invalid input]
**Then**
- [Validation error is shown]
- [No data is saved]

---

## Authorization Failure — [Descriptive scenario name]
**Given** [unauthorized user / role]
**When** [they attempt the action]
**Then**
- [UI hides the control]
- [API returns 401/403]
```

> The **Ticket Quality Checklist** is added inside each Backlog ticket: Task → Add
> Checklist → Paste.

## Ticket Quality Checklist

- [ ] Title is short and action-oriented (verb + object)
- [ ] Status, Backbone, Actor, Assignee, Time Estimate are filled
- [ ] Body contains all 3 sections: User Story, Acceptance Criteria, Test Cases
- [ ] User Story uses As / I want / so that format with a real benefit
- [ ] Summary paragraph includes scope, constraints, in/out of scope
- [ ] Acceptance Criteria are grouped into named sub-sections
- [ ] Every criterion is atomic and testable (yes/no)
- [ ] Session & Security safety is explicitly addressed
- [ ] Authorization rules are clearly defined
- [ ] Validation rules are clearly defined
- [ ] Behavior After Saving is defined
- [ ] UI & API consistency is defined
- [ ] Audit & Logging rules are included
- [ ] Test Cases cover: Happy Path, Validation Error, Authorization Failure
- [ ] No ambiguous words ("maybe", "etc.", "should probably")
- [ ] Related tickets referenced by ID (if applicable)

> This checklist lives in ClickUp Docs or Notion — not inside the ticket.

# Common Mistakes to Avoid When Writing Tickets

## 1. Bad Titles
- ❌ Using vague nouns like "Tickets", "Users", "Orders"
- ✔ Use action-oriented titles: "Create Wallet", "Edit Profile", "Verify KYC"

## 2. Incorrect User Story Format
- ❌ Missing "so that…"
- ❌ Repeating the action instead of stating the benefit
- ✔ Must follow: As a…, I want…, so that…

## 3. Acceptance Criteria Problems
- ❌ Writing AC as one long paragraph
- ❌ No numbered lists
- ❌ No sub-sections
- ❌ Missing validation rules
- ❌ Missing authorization rules
- ✔ AC must be atomic, testable, grouped into sections

## 4. Missing Error/Validation Behavior
- ❌ Only describing the happy path
- ✔ Must include validation errors and authorization failures

## 5. Missing Test Cases
- ❌ No test cases at all
- ❌ Test cases not in Given/When/Then format
- ✔ Must include: Happy Path, Validation Error, Authorization Failure

## 6. Missing Required Metadata
- ❌ No Assignee
- ❌ No Time Estimate
- ❌ No Actor
- ❌ No Backbone
- ✔ All metadata must be filled before the ticket is accepted

## 7. Ambiguous Wording
- ❌ Using "maybe", "etc.", "should probably"
- ✔ Replace with explicit, testable statements

## 8. No Reference to Related Tickets
- ❌ Not linking to parent Epic or related stories
- ✔ Always reference related tickets by ID
