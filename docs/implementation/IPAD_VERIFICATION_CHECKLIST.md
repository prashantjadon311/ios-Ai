# Physical iPad Verification & Acceptance Checklist (V1)

**Application Target:** `PersonalAssistant.swiftpm`  
**Host App:** Apple Swift Playgrounds 5.9+  
**Target Platform:** iPadOS 18.6+ (compatible with iPad Air, iPad Pro, iPad mini, iPad 10th gen)  
**Compilation Mode:** On-device Playgrounds App compilation / Xcode iOS Simulator  

---

## 1. Transfer & Import Instructions

### Option A: AirDrop Transfer (Recommended)
1. On your Mac/Linux host, compress or directly AirDrop the `PersonalAssistant.swiftpm` bundle folder to your iPad.
2. On your iPad, tap **Accept** when the AirDrop prompt appears.
3. Choose **Open with Swift Playgrounds**.
4. The project will appear in your Playgrounds library with the Personal Assistant icon.

### Option B: iCloud Drive Transfer
1. Copy the `PersonalAssistant.swiftpm` directory into your `iCloud Drive/Playgrounds/` folder.
2. Open **Swift Playgrounds** on your iPad.
3. Locate `PersonalAssistant` in the library and tap to open.

### Option C: Working Directory & Direct Launch
1. Ensure the package directory name ends in `.swiftpm` exactly (`PersonalAssistant.swiftpm`).
2. Verify `Package.swift` contains the `.appModule(...)` configuration targeting iOS 18.6.

---

## 2. Capability Entitlements & Permissions Verification

Upon first use of hardware features, iPadOS will prompt for authorization. Verify that standard system permission dialogs display the declared purpose strings:

| Permission | Trigger Action | Declared Purpose |
|---|---|---|
| **Microphone** | Tap microphone button in Chat composer | "Personal Assistant uses your microphone for voice commands and speech transcription." |
| **Speech Recognition** | Voice transcription initiation | "Personal Assistant uses speech recognition to convert spoken words into text." |
| **UserNotifications** | Creating a scheduled task with reminder | Local alerts for task occurrences and scheduled alarms. |
| **Calendars (EventKit)** | Creating a calendar event | "Personal Assistant integrates with Calendars to schedule events upon your request." |

---

## 3. Step-by-Step Device Acceptance Procedure

### Gate 1: Launch & Bootstrapping
- [ ] Tap **Run My Code** or the Play icon in Swift Playgrounds.
- [ ] App launches into the primary `AdaptiveLayout` (NavigationSplitView on iPad landscape/regular, TabView on compact).
- [ ] Local bootstrapping executes silently: verifies `UserProfile("Me")`, `AssistantProfile("Maya")`, and `AssistantProfile("Saar")` are initialized in SwiftData.
- [ ] No crash, no red compilation banner, no store recovery modal on clean launch.

### Gate 2: Five Primary Destinations
- [ ] **Dashboard:** Active assistant card (Maya by default with purple emblem), Quick Ask input bar, recent conversations list, today's tasks section.
- [ ] **Tasks:** Task dashboard showing scheduled, pending, and completed tasks; "+" button opens Task Editor.
- [ ] **History:** Searchable conversation and memory ledger scoped strictly to owner.
- [ ] **Configuration:** AI Providers list (Groq, OpenRouter, Custom Endpoint) with enabled status toggles and BYOK entry.
- [ ] **Settings:** Appearance mode selector (System, Light, Dark), Privacy mode, Diagnostics, Storage overview, Permissions list, and "Lock App Immediately" button.

### Gate 3: Assistant Switching
- [ ] On the Dashboard, tap the assistant switcher icon.
- [ ] Select **Saar** (amber emblem).
- [ ] Verify Dashboard header immediately updates to Saar.
- [ ] Switch back to **Maya**. Verify state and appearance reflect Maya.

### Gate 4: BYOK Provider Setup & Keychain Storage
- [ ] Navigate to **Configuration** -> **Groq** (or **OpenRouter**).
- [ ] Toggle **Enable Provider**.
- [ ] Enter a valid personal API key into the secure field.
- [ ] Tap **Save Configuration**.
- [ ] Verify key is saved to device Keychain (`kSecAttrAccessibleWhenUnlockedThisDeviceOnly`).
- [ ] Disclose note: API keys are communicated directly to the chosen provider as an Authorization header, never to any intermediary.

### Gate 5: Two-Turn AI Chat Vertical Slice
- [ ] Return to **Dashboard**. Type in Quick Ask: `"Hello, what can you do?"` and tap send.
- [ ] Verify Chat sheet opens, showing the user message.
- [ ] Assistant begins streaming response with live typing animation.
- [ ] Verify stop button (`stop.circle.fill`) appears during generation and cancels cleanly if pressed.
- [ ] When generation completes, response remains visible and persisted.
- [ ] Type a second turn: `"Tell me two tips for time management."` and tap send.
- [ ] Verify second turn continues within the **same** conversation rather than creating a new unlinked chat.
- [ ] Tap **Done** to close chat sheet.
- [ ] Verify the conversation appears under **Recent Conversations** on the Dashboard.

### Gate 6: Voice Input & Live Transcription
- [ ] Open any conversation.
- [ ] In the composer, tap the microphone button (`mic`).
- [ ] System prompts for Microphone and Speech Recognition permissions. Tap **Allow**.
- [ ] The microphone icon turns red (`mic.fill`). Speak clearly: `"Schedule a meeting tomorrow at 10 AM."`
- [ ] Verify words appear in real-time inside the message text field.
- [ ] Tap the microphone button again to stop listening.
- [ ] The transcribed text remains in the composer, editable before sending.

### Gate 7: Deterministic Task & Notification Scheduling
- [ ] Navigate to **Tasks** -> tap **+** to add a task.
- [ ] Enter title: `"Review project deliverable"`, set fire date to 5 minutes in the future.
- [ ] Save task. Verify task appears in the task list with an active scheduled indicator.
- [ ] Verify system notification prompt appears. Allow notifications.
- [ ] Wait for the scheduled time: local notification alert fires on iPad.
- [ ] Delete or complete task: verify pending notification is cleanly canceled.

### Gate 8: Data Privacy Mode Enforcement
- [ ] Navigate to **Settings** -> **Privacy**.
- [ ] Switch Data Privacy Mode from **Cloud Allowed** to **Private Only**.
- [ ] Open Chat and attempt an external AI request.
- [ ] Verify request is blocked immediately with an honest explanation ("Private-only mode blocks all external network requests"). Zero external bytes leave the device.
- [ ] Switch back to **Cloud Allowed** and verify normal operation resumes.

### Gate 9: App Lock & Security
- [ ] Navigate to **Settings** -> tap **Lock App Immediately**.
- [ ] App immediately transitions to locked overlay, obscuring private conversation and task data.
- [ ] Tap unlock / biometric authentication to restore active session.

---

## 4. Defect Reporting Template for iPad Testers

If any issue is encountered during physical iPad testing, record the following details:

```text
=======================================================
IPAD VERIFICATION DEFECT REPORT
=======================================================
Device Model: [e.g. iPad Pro 11-inch (M4), iPad Air (M2), iPad 10th gen]
iPadOS Version: [e.g. 18.6, 18.6.1]
Swift Playgrounds Version: [e.g. 5.9 (build 1234)]
Test Step Failed: [e.g. Gate 5 - Two-Turn AI Chat]
Observed Behavior: [Exact description of error or visual issue]
Expected Behavior: [Expected result per checklist]
Console / Error Output: [Text of any alert or Playgrounds error banner]
Screenshots / Media: [Attach screenshot if available]
=======================================================
```
