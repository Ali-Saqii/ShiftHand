# ShiftHand: Agent Operating Guidelines

These rules apply to any AI coding assistant or engineer working in this repository. Read and follow without exception.

---

## 1. Scope & Product Surface
- **iOS App is STAFF ONLY:** The users are **Organisation Owners**, **Coordinators**, and **Shift Leads**.
- **No Volunteer Mode:** Volunteers NEVER have accounts, passwords, or an app. Volunteers use server-rendered mobile web pages via emailed magic links (`/e/:slug`, `/v/:token`, `/v`).
- **Do NOT Build CUT Features:** The following are CUT from the 30-day MVP and must **NEVER** appear in code, UI, navigation, or as disabled buttons:
  - QR Code Scanner (`VisionKit`), scan overlay, camera permissions, or scan result sheets.
  - Waitlist queues, timed waitlist offers, or waitlist promotion.
  - Volunteer sign-up approval flow (approve/reject buttons, pending state).
  - Hours ledger, minutes calculation, grace periods, adjustments, or hours review.
  - Messages tab, broadcast composer, delivery logs.
  - Reports tab, charts, CSV/PDF exports.
  - Volunteer CSV import.
  - Walk-in volunteer creation on-site.
  - Offline sync engine, local queue outbox, or SwiftData persistence.
  - Push notifications (`UserNotifications`, APNs, device tokens).
  - Forgot password flow on login screen (no backend endpoint).

---

## 2. Roles & Navigation Architecture
- **Server Decides the Role:** Roles are per-organisation memberships (`owner`, `coordinator`, `shift_lead`). The app fetches them from `/me` and builds navigation. UI hiding is for ergonomics; the server enforces every authorization check.
- **Owner and Coordinator:** See a fixed **3-tab TabView** in this exact order:
  1. **Events** (List, Detail, Shift Editor, Shift Roster)
  2. **Live** (Today's shifts, Live Roster, Manual Check-in Sheet)
  3. **Volunteers** (Volunteer directory, Volunteer Detail)
  - **Settings:** Opened from the profile avatar button on the Events screen (top-right), NOT from a tab.
- **Shift Lead:** **NEVER sees a tab bar** and never sees Events or Volunteers tabs.
  - Launches directly into **Shift Lead Home** (`shifthand/Features/Live/Views/ShiftLeadHomeView.swift`).
  - Displays today's shifts where `lead_user_id == current_user.id`.
  - Shift Lead Home has an avatar/menu at the top for **Sign out** and **Delete account** (App Store requirement).
  - If the lead has no shifts today, display the empty state: *\"No shifts assigned to you today\"*.
  - A `403 Forbidden` from the server indicates revoked access or demotion, NOT the empty state.
- **Onboarding & Switcher:**
  - 0 memberships -> Route to `OnboardingView` (Create Organisation or Join with Invite Code).
  - 2+ memberships -> Present `OrgPickerView` at launch and from Settings.

---

## 3. Architecture & Code Guidelines
- **Target Folder:** All iOS code lives in `shifthand/`.
- **Frameworks:** SwiftUI (iOS 17+), Observation framework (`@Observable`, `@MainActor`), structured concurrency (`async/await`).
- **NO SwiftData:** SwiftData is completely CUT. Do NOT import SwiftData or use `ModelContainer` / `@Model` / `@Query`. Domain models are immutable `Codable` / `Sendable` structs.
- **State Management:** Every ViewModel exposes an explicit `ViewState<T>`:
  ```swift
  enum ViewState<T> {
      case idle
      case loading
      case loaded(T)
      case failed(AppError)
  }
  ```
  Every screen handles all 5 states: `loading`, `loaded`, `empty`, `error`, `offline`.
- **Networking Layers:**
  `View -> ViewModel (@Observable) -> Repository Protocol (Mock / Live) -> APIClient (actor)`
- **Token Handling:**
  - Short-lived JWT access token stored in memory.
  - Rotating refresh token stored in `KeychainStore` only (never `UserDefaults`).
  - `AuthSession` actor ensures that concurrent 401 responses trigger exactly ONE in-flight `/auth/refresh` request; all callers suspend and await the result.
- **Configuration:** No hard-coded base URLs. All configuration is loaded from `.xcconfig` (e.g., `Debug.xcconfig`, `Staging.xcconfig`, `Release.xcconfig`) via `Bundle.main`.
- **Organisation Header (`X-Org-Id`):** All staff requests to organisation-scoped endpoints must pass the active organisation UUID in the `X-Org-Id` header (non-members receive `404 Not Found`).
- **Staff Invites & Join:** Invite codes are 8 uppercase alphanumeric characters, stored hashed (SHA-256), 48-hour single-use expiry. Joining is rate limited.
- **Authoritative Server Time:** Check-in time is determined on the server (`server time`). The app never sends device timestamps for check-in. \"Today's shifts\" is calculated by the server using the organisation's timezone.
- **Check-in 409 Handling:** A `409 ALREADY_CHECKED_IN` response is rendered as **informational success** (e.g. *\"Already here since 09:14\"*) and updates local state; it must NOT trigger an error banner.

---

## 4. UI & Design System Rules
- **Design Tokens:** Strict adherence to `Docs/UI_STANDARDS.md`. No raw hex codes or custom colors outside `shifthand/SharedUI/DesignTokens.swift`.
  - Primary Teal: `#0E7C86`
  - Dark Teal: `#0A5961`
  - Accent Amber: `#F59E0B`
  - Background: `#F6F8FA`
  - Cards: White (`#FFFFFF`)
  - Border: `#E2E8F0`
  - Text Primary: `#0F172A`
  - Text Secondary: `#475569`
  - Dark mode tokens: programmatically derived and marked *\"derived, not from Guide\"*.
- **Status Chips:** MUST always include **Icon + Text + Colour** (never colour alone).
- **Accessibility:**
  - Minimum **44 pt touch targets** on all interactive elements.
  - VoiceOver accessibility labels on all counters (e.g., *\"Arrived 7 of 12 volunteers\"*).
  - Dynamic Type support at all text sizes.

---

## 5. Workflow & Git Commit Conventions
- Work strictly day-by-day according to `Docs/PLAN_IOS.md` (Plan v3). The single source of truth for all API contracts, schemas, and business rules is `Docs/SHIFTHAND_MVP_SPEC_v2.md`. Never invent endpoints, screens, or features. If something is missing, document it in `Docs/OPEN_QUESTIONS.md`.
- Commit format: one bracketed tag per commit, lowercase start, under 60 characters:
  - `[Feature]`
  - `[Bug]`
  - `[Patch]`
  - `[Updation]`
  - `[Refactor]`
  - `[Docs]`
  - `[Config]`
  - `[Test]`
  - `[Chore]`
