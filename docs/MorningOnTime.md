# **Product Requirements Document (PRD)**

## **Table of Contents**

1. [Product Name (Working Title)](#product-name-working-title)
2. [Product Vision](#product-vision)
3. [Problem Statement](#problem-statement)
4. [Target Users](#target-users)
   - [Primary User](#primary-user)
   - [Secondary User](#secondary-user)
5. [Goals & Success Criteria](#goals--success-criteria)
   - [User Goals](#user-goals)
   - [Product Goals](#product-goals)
   - [Success Metrics (MVP)](#success-metrics-mvp)
6. [Core Principles](#core-principles)
7. [MVP Scope](#mvp-scope)
8. [User Flow (Daily)](#user-flow-daily)
9. [Functional Requirements](#functional-requirements)
   - [1. Initial Setup](#1-initial-setup)
   - [2. Today's Mission Frame](#2-todays-mission-frame)
   - [3. Automatic Morning Activation](#3-automatic-morning-activation)
   - [4. Voice & Notification Engine](#4-voice--notification-engine)
   - [5. Today's Result: Success or Failure](#5-todays-result-success-or-failure)
   - [6. Streak System](#6-streak-system)
   - [7. Rewards System (Parent‑Driven)](#7-rewards-system-parentdriven)
10. [8. Testing Tools (Development Only)](#8-testing-tools-development-only---not-for-production)
11. [9. Monthly History View](#9-monthly-history-view)
12. [Non‑Functional Requirements](#nonfunctional-requirements)
13. [Risks & Mitigations](#risks--mitigations)
14. [MVP Definition of Done](#mvp-definition-of-done)
15. [Product Statement](#product-statement)

---

## **Product Name (Working Title)**

**Morning On Time**

## **Product Vision**

Help families arrive at school on time consistently by turning mornings into a lightweight, voice‑driven game that motivates children without adding friction, screens, or extra tasks.

*The app does not organize the morning. It accompanies it.*

---

## **Problem Statement**

Families with school‑age children often arrive late despite good intentions. Mornings are chaotic, children lack a sense of urgency, and parents are forced into constant reminders and pressure. Existing solutions rely on checklists, screens, or complex routines that add cognitive load rather than reduce it.

---

## **Target Users**

### **Primary User**

* Parent or caregiver of children aged 5–12

### **Secondary User**

* Child, who experiences the product mainly through voice and notifications

---

## **Goals & Success Criteria**

### **User Goals**

* Arrive at school on time consistently  
* Reduce morning stress and conflict  
* Increase child autonomy and motivation

### **Product Goals**

* Establish a daily on‑time habit  
* Encourage consistency through streaks and rewards  
* Minimize required interaction

### **Success Metrics (MVP)**

* % of school days marked as on‑time  
* Average streak length  
* Weekly active users (parents)  
* Retention after 14 and 30 days

---

## **Core Principles**

1. **Single Objective**: Arrive on time  
2. **Minimal Interaction**: No checklists, no task tracking  
3. **Voice First**: Audio over screens  
4. **Automatic by Default**: The app activates itself  
5. **Positive Motivation**: No punishment, no guilt

---

## **MVP Scope**

### **In Scope**

* Time‑based activation  
* Voice encouragement  
* Key moment notifications  
* Manual arrival confirmation  
* Daily success/failure tracking  
* Streak system  
* Parent‑defined rewards

---

## **User Flow (Daily)**

1. App activates automatically at wake‑up time  
2. Voice message sets the daily mission  
3. A recurring voice message informs the family of the time they have to leave.
4. Timely voice notifications at key moments, such as 5 minutes to leave or time to leave.
5. When it's time to leave, a countdown timer appears to inform the family how much time they have left.
6. After time to leave, the user can state that they have arrived at school. If they confirm that have arrived before arrival time, it's a success so the countdown timer stops.
7. If success, the app celebrates the achievement with a confetti animation.
8. At arrival time, if parent didn't confirm success, it's a failure. 
9. Success or failure is recorded hidding the countdown timer and updating the streak and monthly history
10. Streak and reward progress updated

---

## **Functional Requirements**

### **1\. Initial Setup**

#### **First Launch Behavior**

When the app is launched for the first time, the user goes through a welcoming onboarding flow that explains the problem, the solution, and the permissions needed before entering their schedule configuration.

##### **Onboarding Flow (4 Screens)**

**Screen 1: Welcome & Problem Statement**

* **Visual:** Illustration of a chaotic morning scene (family rushing, stressed parent, clock showing they're late)
* **Headline:** "Are mornings a daily struggle?"
* **Body Text:**
  - "Arriving late to school despite your best efforts?"
  - "Mornings filled with chaos, constant reminders, and stress?"
  - "Children lacking a sense of urgency while you're running behind?"
* **Action:** "Next" button

**Screen 2: The Solution**

* **Visual:** Illustration of calm, organized morning (smiling parent, child ready, streak trophy icon)
* **Headline:** "Turn mornings into a mission"
* **Body Text:**
  - "Morning Mission helps your family arrive on time consistently"
  - "Voice-driven reminders at key moments—no screens, no checklists"
  - "Motivates with streaks and rewards, not guilt or pressure"
  - "The app activates itself. You just live your morning."
* **Action:** "Next" button

**Screen 3: How It Works**

* **Visual:** Timeline graphic showing morning progression with icons
* **Headline:** "Automatic support throughout the morning"
* **Body Text:**
  - "🌅 Wake-up message sets today's mission"
  - "⏰ Voice check-ins every 10 minutes to stay on track"
  - "🚪 Countdown when it's time to leave"
  - "🎯 Confirm arrival to celebrate success and build your streak!"
* **Action:** "Next" button

**Screen 4: Permissions Required**

* **Visual:** Icons for notification bell and battery with checkmarks
* **Headline:** "Two quick permissions to get started"
* **Body Text:**
  - "For the app to work reliably, we need:"
  - **📬 Notifications:** "To send voice reminders and time alerts throughout your morning"
  - **🔋 Battery Unrestricted:** "To ensure alarms fire on time even when your phone is locked or sleeping"
* **Explanation Box (emphasized):**
  - "Why battery permission matters: Android puts apps to sleep to save power. Without this permission, morning alarms might not wake up on time when you need them most."
* **Action:** "Grant Permissions & Continue" button

**Screen 5: Permission Request Sequence**

After user taps "Grant Permissions & Continue":

1. **Notification Permission Dialog** (system prompt):
   * Standard Android permission dialog for POST_NOTIFICATIONS
   * User must tap "Allow" for app to continue

2. **Battery Optimization Dialog** (system prompt):
   * App calls `Permission.ignoreBatteryOptimizations.request()`
   * Opens Android settings page: Settings > Apps > Morning Mission > Battery
   * User must select "Unrestricted" or "Don't optimize"

3. **Permission Verification:**
   * App checks if both permissions are granted
   * If **both granted:** Proceed to Configuration Screen
   * If **either denied:** Show retry prompt:
     - "Permissions Required"
     - "Morning Mission needs both permissions to work reliably. Without them, alarms may not fire when your family needs them most."
     - "Try Again" button (re-launches permission flow)
     - "Exit App" button (closes app - cannot proceed without permissions)

**Note:** Permissions are **mandatory** for app to function. Users cannot skip or bypass the permission request.

---

##### **Configuration Screen**

After permissions are granted, the user configures their schedule:

1. **Time Configuration:** User enters three required times:
   * Wake-up time (when the morning journey begins)
   * Leave home time (when they need to depart)
   * Arrival time (latest acceptable arrival at school/work)

2. **Active Days Selection:** User selects which days of the week alarms should fire:
   * Day-of-week toggles: Mon, Tue, Wed, Thu, Fri, Sat, Sun
   * Quick presets: "Weekdays Only" (Mon-Fri) or "Every Day" (Mon-Sun)
   * Default: Weekdays only (Monday through Friday)
   * Purpose: Automatically skip weekends or configure custom school schedules

3. **Optional Rewards:** User can define weekly rewards (e.g., "Movie night on Friday") linked to streak milestones

4. **Save & Initialize:** Once the user saves these settings:
   * All alarms are automatically scheduled for the next 7 days according to active days pattern
   * Weekend days (or inactive days) are automatically skipped
   * **Alarms scheduled per active day:**
     - **Wake-up alarm (ID: 1)** - Fires at configured wake-up time
     - **Checkpoint alarms (IDs: 100-119)** - First at wake-up + 10 minutes, then every 10 minutes until 5 minutes before leave time (dynamic quantity based on time gap)
     - **Leave Home Soon alarm (ID: 3)** - Fires 5 minutes before leave home time
     - **Leave Home alarm (ID: 4)** - Fires at configured leave home time
     - **Pre-Arrival Check alarm (ID: 5)** - Fires 2 minutes before arrival deadline
     - **Arrival alarm (ID: 6)** - Fires at configured arrival deadline
   * **Example:** If wake-up is 6:30 AM and leave is 7:45 AM, checkpoint alarms fire at 6:40, 6:50, 7:00, 7:10, 7:20, 7:30, 7:40 (7 checkpoints total)
   * **Minimum gap:** At least 15 minutes between wake-up and leave time is recommended for checkpoint alarms to trigger
   * Home screen appears showing the **Today's Mission frame**
   * Today's Mission frame displays the configured times:
     - Wake-up time: [configured time]
     - Leave at: [configured time]
     - Arrive by: [configured time]

#### **Modifying Settings**

Settings are accessible from the home screen at any time and include:

**Time Settings:**
* Wake-up time, leave home time, and arrival deadline can be updated
* Changes apply to all scheduled alarms going forward

**Active Days Pattern:**
* User can enable/disable specific days of the week
* Example: Disable Wednesdays for recurring half-day schedule
* Changes immediately reschedule the 7-day alarm window

**Skip Tomorrow (One-Time Override):**
* Toggle switch: "Skip alarms for [tomorrow's date]"
* Use cases: Sick day, holiday, unexpected schedule change
* Clears automatically after the skipped date passes
* Does not affect recurring weekly pattern

**When Settings Change:**
* All existing alarms are cancelled
* **Any ongoing journey (countdown timer) is cancelled** - test journeys and real journeys both end immediately
* Full 7-day window is rescheduled with new times/pattern
* Only active days receive alarms (inactive days skipped)
* Today's Mission frame updates immediately to reflect new times

**Smart Cleanup:**
* Past skip dates are automatically removed when app launches
* Ensures skip list doesn't grow indefinitely

---

### **2\. Home Screen Journey Card**

The home screen adapts dynamically to the user's current journey state. Instead of always showing static alarm times (which are available in settings), the home screen surfaces **what is most relevant right now**: either a calm idle view when no journey is active, or a live journey card that evolves from wake-up through arrival.

#### **Purpose**

* Show contextually relevant information based on journey state
* Create a sense of progression and urgency during the morning journey
* Surface the last notification message so the user stays informed even if they missed it
* Replace static alarm times with a living, evolving card during active journeys
* Provide immediate visual feedback through color, progress, and phase labels

---

#### **Journey States**

The app recognizes three distinct states. The home screen layout changes based on which state is active.

| State | Time Window | User Context |
|-------|------------|--------------|
| **Idle** | Before wake-up, or after arrival resolved | No active journey |
| **Getting Ready** | Wake-up → leave-home time | User is at home preparing |
| **On the Way** | Leave-home → arrival deadline | User is heading to school |

**State Determination:**
* **Idle:** Current time is before today's wake-up time, OR today's journey has been resolved (arrival confirmed or deadline passed), OR today is not an active day
* **Getting Ready:** Current time is between wake-up and leave-home time on an active day, and journey has not been resolved
* **On the Way:** Current time is between leave-home and arrival deadline on an active day, and journey has not been resolved

**State transitions are computed in real time** from the current clock and configured times — no persistent flags needed beyond the existing `_arrivalConfirmedToday`.

---

#### **Idle State — Home Screen Layout**

When no journey is active (before wake-up, after arrival resolved, or on an inactive day), the home screen shows a calm, informational layout:

```
┌─────────────────────────────────────┐
│  "Next alarm in 8h 30m"            │  ← Next alarm indicator
├─────────────────────────────────────┤
│  Today's Result (if applicable)     │  ← Success/failure card (same day only)
├─────────────────────────────────────┤
│  🔥 Streak Card                     │  ← Current streak with character
├─────────────────────────────────────┤
│  🏆 Active Reward                   │  ← Reward progress
└─────────────────────────────────────┘
```

**Components:**

1. **Next Alarm Indicator (new)**
   * Single line at the top: "Next alarm in Xh Ym" or "Next alarm: Tomorrow at 6:30 AM"
   * Gives the user a glance-able confirmation that the next day is armed
   * Subtle, secondary text — not prominent
   * If no active days in next 7 days: "No upcoming journeys scheduled"

2. **Today's Result** (existing behavior, unchanged)
   * Appears after journey resolution (success or failure)
   * Green gradient for success, red gradient for failure
   * Disappears at next wake-up time

3. **Streak Card** (existing behavior, unchanged)
   * Character image, fire badge, level name, progress message

4. **Active Reward** (existing behavior, unchanged)
   * Progress bar, days remaining, manage button

**What's Removed from Idle State:**
* The old Mission frame with static alarm times (wake-up, leave, arrive) is no longer shown on the home screen during idle. These times are accessible in the settings screen.

**Next Active Day Detection** (unchanged logic):
1. Check if today is active: weekday in `activeDaysOfWeek`, date not in `skipDates`, arrival not passed → show today's context
2. If today is done or skipped, find next active day by scanning forward
3. If no active days in next 7 days: indicator shows "No upcoming journeys scheduled"

---

#### **Getting Ready State — Live Journey Card**

When the wake-up alarm fires and the journey begins, the Mission frame transforms into a **live journey card** that replaces the static alarm times. This card sits above the streak and reward cards.

```
┌─────────────────────────────────────┐
│  🌅 Getting Ready                   │  ← Phase label with icon
│                                     │
│  ━━━━━━━━━━━━━━━━━│░░░░░░░░░░░░░░░│  ← Progress bar with leave marker
│                                     │
│  "Leave by 7:15 · Arrive by 8:00"  │  ← Subtle time context
│                                     │
│  "⏰ 20 min until you need to leave"│  ← Last notification message
│                                     │
│  Background color: teal → amber     │  ← Progressive color shift
├─────────────────────────────────────┤
│  🔥 Streak Card                     │
├─────────────────────────────────────┤
│  🏆 Active Reward                   │
└─────────────────────────────────────┘
```

**Components:**

##### **Phase Label**
* Header text: **"🌅 Getting Ready"**
* Bold, white text on the colored background
* Provides instant orientation — the user knows where they are in the journey

##### **Progress Bar**
* A horizontal bar spanning the full width of the card
* Represents the **entire journey from wake-up to arrival deadline**
* Starts at 100% (full) at wake-up time, depletes continuously to 0% at arrival deadline
* Includes a **visible marker at the leave-home position** on the bar
  - The marker divides the bar into two visual segments: "Getting Ready" and "On the Way"
  - Helps the user see how much preparation time remains before they must leave
  - Marker position is proportional: if wake-up is 6:30, leave is 7:15, arrival is 8:00, the marker sits at 50% (45 min out of 90 min total)
* Bar color follows the same progressive color scheme as the card background
* Updates every second for smooth depletion

##### **Time Context Line**
* Subtle, secondary text: **"Leave by 7:15 · Arrive by 8:00"**
* Shown below the progress bar
* Small font, white with reduced opacity (0.7)
* Provides reference without being the focus — the progress bar and color carry the urgency

##### **Last Notification Banner**
* **Always visible** while the journey card is showing — never empty
* Two data sources with automatic fallback:
  1. **SharedPreferences value** (primary): written by background alarm callbacks with the actual randomized notification message. Read via `prefs.reload()` to pick up cross-isolate writes.
  2. **Computed fallback**: deterministic message derived from current time vs the alarm schedule. Used when no alarm has fired yet (e.g., the first minutes after wake-up) or if the SharedPreferences read fails for any reason.
* Updates every second (via the card's ticker) so the computed banner reflects the current moment
* Catches the user up if they missed the actual notification

**Computed banner logic (Getting Ready phase):**

| Time Window | Computed Banner |
|-------------|-----------------|
| Within 5 min after wake-up | "☀️ Good morning! Today's mission: arrive on time!" |
| ≤ 5 min until leave time | "🚨 Almost time to leave! Get ready!" |
| Otherwise (checkpoint zone) | "⏰ X minutes left until you need to leave" |

**Computed banner logic (On the Way phase):**

| Time Window | Computed Banner |
|-------------|-----------------|
| ≤ 15 sec to arrival | "🚨 Last chance! Confirm arrival now!" |
| ≤ 45 sec to arrival | "🎯 Almost there! Confirm your arrival" |
| Otherwise | "🚗 On the way! Arrive by HH:MM" |

**SharedPreferences override content (matches the alarm that fired):**

| After Alarm | Banner Text |
|-------------|-------------|
| Wake-up (ID: 1) | "☀️ Good morning! Today's mission: arrive on time" |
| Checkpoint (IDs: 100-119) | "⏰ X minutes until you need to leave" (uses the actual randomized text from the checkpoint message) |
| Leave Home Soon (ID: 3) | "🚨 In five minutes we must leave home, hurry up!" |
| Leave Home (ID: 4) | "🚗 We leave home now or we'll be late." |
| Pre-Arrival T-60s (ID: 5) | "🎯 Don't forget to confirm your arrival. 1 minute left!" |
| Pre-Arrival T-30s (ID: 7) | "⚠️ Don't forget to confirm your arrival. 30 seconds left!" |
| Pre-Arrival T-10s (ID: 8) | "🚨 Confirm now or today will be marked as late. 10 seconds left!" |

**Persistence:** The notification message is written to SharedPreferences by the alarm callback (which runs in a separate Dart isolate). The main isolate reads it via `prefs.reload()` to bypass the in-memory cache. The computed fallback ensures the banner is never empty even before the first alarm fires.

##### **Progressive Background Color**

The card background color shifts continuously from calm to urgent as time passes:

* The color is calculated using a **normalized ratio** from 0.0 (wake-up) to 1.0 (arrival deadline)
* Color transitions are **continuous** (using `Color.lerp`), not stepped, to avoid jarring jumps
* The gradient creates a "rising tension" feeling throughout the morning

**Color Interpolation Waypoints:**

| Journey Progress | Ratio | Color | Meaning |
|-----------------|-------|-------|---------|
| Wake-up | 0.0 | Calm teal (`#4DB6AC`) | Plenty of time, relaxed start |
| 25% through | 0.25 | Teal-green | Still comfortable |
| 50% (mid-journey) | 0.5 | Green-amber | Halfway, start paying attention |
| Leave-home time | ~0.5-0.6 (varies) | Amber (`#FFB300`) | Transition point |
| 75% through | 0.75 | Amber-orange | Urgency building |
| 90% through | 0.9 | Orange-red | Critical |
| Arrival deadline | 1.0 | Deep red (`#E03E3E`) | Maximum urgency |

**Implementation approach:**
```
ratio = (now - wakeUpTime) / (arrivalDeadline - wakeUpTime)
ratio = clamp(ratio, 0.0, 1.0)

Color palette waypoints: [teal, green, amber, orange, red]
Interpolate through waypoints based on ratio
```

The card also uses a **matching shadow color** for emphasis, following the same interpolation.

---

#### **On the Way State — Countdown Journey Card**

When the leave-home alarm fires, the journey card **evolves** — it does not disappear and get replaced. The same card transitions smoothly into the "On the Way" phase, with the countdown timer becoming the hero element.

```
┌─────────────────────────────────────┐
│  🚗 On the Way                      │  ← Phase label changes
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━│░░░░░░░░░░│  ← Progress bar (past leave marker)
│                                     │
│        ┌──────────────────┐         │
│        │     12:34         │         │  ← Countdown timer (hero element)
│        │  Time Remaining   │         │
│        └──────────────────┘         │
│                                     │
│  "🚨 1 minute left — confirm now!"  │  ← Last notification (pre-arrival)
│                                     │
│  [ ✅ Arrived at School ]           │  ← Confirmation button
│                                     │
│  Background color: amber → red      │  ← Continues progressive shift
├─────────────────────────────────────┤
│  🔥 Streak Card                     │
├─────────────────────────────────────┤
│  🏆 Active Reward                   │
└─────────────────────────────────────┘
```

**What Changes at Leave-Home Time:**

1. **Phase label:** "🌅 Getting Ready" → **"🚗 On the Way"**
2. **Countdown timer appears:** Circular progress indicator with time remaining (existing `CountdownTimer` widget). This becomes the dominant visual element in the card.
3. **Time context line hides:** No longer needed — the countdown provides the urgency directly
4. **"Arrived at School" button appears:** Same as current behavior
5. **Progress bar continues:** The bar keeps depleting — it's now past the leave-home marker
6. **Background color continues:** Picks up from where it was (amber zone) and progresses toward red
7. **Last notification banner continues:** Now shows pre-arrival check messages as they fire

**Countdown Timer Behavior** (unchanged from current):
* Circular progress indicator (200x200 CustomPaint)
* Displays HH:MM:SS or MM:SS remaining
* Pulsing animation when ≤ 5 minutes remain
* Timer color follows the same urgency palette (green → amber → orange → red)
* Updates every 1 second

**Last Notification Banner in this phase:**

| After Alarm | Banner Text |
|-------------|-------------|
| Leave Home (ID: 4) | "🚗 Time to leave! Head to school now" |
| Pre-Arrival 60s (ID: 5) | "🎯 Almost there! 1 minute left" |
| Pre-Arrival 30s (ID: 7) | "⚠️ 30 seconds! Confirm arrival now" |
| Pre-Arrival 10s (ID: 8) | "🚨 Last chance! Confirm in the app!" |

---

#### **State Transitions Summary**

The following diagram shows how the home screen evolves throughout a complete day:

```
NIGHT / BEFORE WAKE-UP (Idle)
┌──────────────────────────────────────────────────────────┐
│  Home screen: Next alarm indicator + Streak + Reward      │
│  No journey card visible                                  │
└──────────────────────────────────────────────────────────┘
                            │
                   🌅 Wake-up alarm fires
                            │
                            ▼
GETTING READY (wake-up → leave-home)
┌──────────────────────────────────────────────────────────┐
│  Journey card appears with:                               │
│  • Phase: "Getting Ready"                                 │
│  • Progress bar at ~100%, depleting                       │
│  • Background: calm teal                                  │
│  • Banner: "Good morning! Today's mission..."             │
│                                                           │
│  As time passes:                                          │
│  • Progress bar depletes toward leave marker              │
│  • Background shifts: teal → green → amber                │
│  • Banner updates with each checkpoint alarm              │
│  • At leave-soon: banner shows urgency message            │
└──────────────────────────────────────────────────────────┘
                            │
                   🚪 Leave-home alarm fires
                            │
                            ▼
ON THE WAY (leave-home → arrival deadline)
┌──────────────────────────────────────────────────────────┐
│  Journey card evolves:                                    │
│  • Phase: "On the Way"                                    │
│  • Countdown timer appears as hero element                │
│  • Progress bar continues past leave marker               │
│  • Background continues: amber → orange → red             │
│  • Banner updates with pre-arrival check messages         │
│  • "Arrived at School" button visible                     │
└──────────────────────────────────────────────────────────┘
                            │
               ┌────────────┴────────────┐
               │                         │
      ✅ User confirms arrival    ❌ Deadline passes
               │                         │
               ▼                         ▼
IDLE (journey resolved)
┌──────────────────────────────────────────────────────────┐
│  Journey card disappears                                  │
│  Today's Result card appears (success or failure)         │
│  Next alarm indicator shows tomorrow                      │
│  Streak + Reward update                                   │
└──────────────────────────────────────────────────────────┘
```

---

#### **Visual Design**

##### **Journey Card Styling**
* **Shape:** Rounded corners (16dp radius), soft shadow matching background color
* **Background:** Linear gradient (top-left to bottom-right) using progressive color
* **Padding:** 20dp internal padding, 16dp external margins
* **Text:** White for all text elements (high contrast on colored backgrounds)
* **Phase label:** Bold, 20pt, white
* **Time context:** Regular, 14pt, white with 0.7 opacity
* **Last notification banner:** Semi-bold, 16pt, white, inside a subtle white-with-low-opacity (0.15) rounded container for readability
* **Animations:**
  - Card appears with a fade+slide-up when transitioning from Idle to Getting Ready
  - Phase label cross-fades when transitioning from Getting Ready to On the Way
  - Countdown timer fades in when entering On the Way phase
  - Last notification banner text animates with a vertical slide on each update

##### **Progress Bar Styling**
* **Height:** 8dp
* **Track:** White with 0.2 opacity (visible but subtle)
* **Fill:** White with 0.9 opacity (bright against the colored background)
* **Leave-home marker:** A small vertical tick (2dp wide, 16dp tall) on the track, white with 0.6 opacity
* **Border radius:** Fully rounded (4dp)
* **Animation:** Smooth depletion, updates every second

##### **Next Alarm Indicator Styling (Idle State)**
* **Position:** Top of home screen, above streak card
* **Text:** Regular, 14pt, secondary color (gray)
* **Icon:** Small clock icon prefix
* **Example:** "🕐 Next alarm in 8h 30m" or "🕐 Next alarm: Tomorrow at 6:30 AM"

---

#### **Technical Implementation**

##### **Journey State Provider**

Extend `AppState` with a new computed property for the three-state journey model:

```dart
enum JourneyPhase { idle, gettingReady, onTheWay }

JourneyPhase get currentJourneyPhase {
  // Returns idle, gettingReady, or onTheWay based on:
  // - Current time vs configured wake-up / leave / arrival times
  // - Whether today is an active day
  // - Whether arrival has been confirmed today
}
```

The existing `isJourneyActive` getter (which only covers leave→arrival) can remain for backward compatibility but the UI should use `currentJourneyPhase` for rendering decisions.

##### **Last Notification Message Storage**

Each alarm callback (running in a background isolate) writes the last notification message to SharedPreferences:

```dart
// In alarm callback (background isolate):
SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setString('last_journey_notification', messageText);
await prefs.setInt('last_journey_notification_time', DateTime.now().millisecondsSinceEpoch);
```

The UI reads this value on build and when the app is foregrounded. A periodic timer (every 5 seconds) or `WidgetsBindingObserver.didChangeAppLifecycleState` can trigger re-reads to pick up new messages.

##### **Progressive Color Calculation**

```dart
Color getJourneyCardColor(DateTime now, DateTime wakeUp, DateTime arrival) {
  double ratio = (now.difference(wakeUp).inSeconds) /
                 (arrival.difference(wakeUp).inSeconds);
  ratio = ratio.clamp(0.0, 1.0);

  // Waypoints: teal(0.0) → green(0.3) → amber(0.5) → orange(0.75) → red(1.0)
  // Use multi-stop Color.lerp through the palette
}
```

##### **Progress Bar Ratio**

```dart
double getProgressRemaining(DateTime now, DateTime wakeUp, DateTime arrival) {
  double elapsed = now.difference(wakeUp).inSeconds.toDouble();
  double total = arrival.difference(wakeUp).inSeconds.toDouble();
  return 1.0 - (elapsed / total).clamp(0.0, 1.0);
}

double getLeaveMarkerPosition(DateTime wakeUp, DateTime leave, DateTime arrival) {
  double leaveOffset = leave.difference(wakeUp).inSeconds.toDouble();
  double total = arrival.difference(wakeUp).inSeconds.toDouble();
  return leaveOffset / total;  // e.g., 0.5 means leave is at the halfway point
}
```

##### **Data Sources**
* Times from `AppSettings` (SharedPreferences) — unchanged
* `activeDaysOfWeek` and `skipDates` — unchanged
* Last notification message from SharedPreferences (new)
* Current DateTime for all ratio calculations

##### **State Management**
* Provider-based reactivity — unchanged
* `Timer.periodic` every 1 second during active journey phases to update progress bar, color, and countdown
* `WidgetsBindingObserver` to refresh last notification message when app returns to foreground

##### **Performance**
* Lightweight: only date math and color interpolation per tick
* No network calls
* Timer runs only during active journey phases (Getting Ready + On the Way), not during Idle
* Minimal battery impact

---

#### **Edge Cases**

1. **Midnight Boundary:**
   * If arrival time < leave time (crosses midnight), the journey card handles date arithmetic correctly
   * Same logic as existing midnight handling in `isJourneyActive`

2. **No Active Days:**
   * Idle state shows "No upcoming journeys scheduled" in the next alarm indicator
   * No journey card appears

3. **Settings Changed Mid-Journey:**
   * If user changes times while a journey card is active, the journey is cancelled (existing behavior)
   * Home screen returns to Idle state with updated next alarm indicator

4. **App Restart During Journey:**
   * Journey phase is recalculated from current time on launch (no persistent state needed beyond `_arrivalConfirmedToday`)
   * Last notification message is read from SharedPreferences and displayed
   * Progress bar and colors resume at the correct position

5. **App Opened After Missing Notifications:**
   * The last notification banner shows the most recent message
   * The progress bar and background color immediately reflect how much time has elapsed
   * The user gets a clear visual of where they are in the journey without having seen any notification

6. **Test Mode:**
   * Test button uses compressed times — journey card works identically with test times
   * All three phases are observable during a test run

7. **Wake-Up Alarm Missed (Phone Off / DND):**
   * When the user opens the app after wake-up time, the journey card appears in the correct phase based on current time
   * Last notification banner shows whatever the most recent callback managed to write (or a default "Journey in progress" if nothing was written)
   * Progress bar and color reflect actual elapsed time

---

### **3\. Automatic Morning Activation**

The app automatically schedules and fires alarms throughout the morning without requiring user interaction. All alarms use Android's native AlarmManager for reliable background execution and automatically reschedule for the next day.

---

### **4\. Voice & Notification Engine**

The app schedules **5 different types of alarms** when settings are saved or updated.

The morning plan begins at wake-up time and finished at arrival time. The trip to school starts at leave time and finishes at arrival time.

See below the diffent types of alarms:

#### **4.1. Wake-Up Alarm (ID: 1)**

* **Trigger:** At the user's configured wake-up time
* **Voice Message (TTS):** "Good morning! Today's mission is to arrive at school on time. Let's go!"
* **Notification:** "🌅 Good Morning!" with mission message
* **Behavior:** 
  - Fires exactly at wake-up time using AlarmManager
   - The notification plays sounds/wake-up/morning-rooster.wav (even when app is closed)
   - TTS starts 5 seconds after notification sound playback begins
   - Plays TTS message automatically in background (even when app is closed)
  - Shows notification with mission reminder
* **Reliability:** High (uses native Android AlarmManager, survives app closure and device restart)

#### **4.2. Checkpoint Alarms (IDs: 100-119)**

* **Trigger:** Every 5 minutes starting from wake-up time until the leave time
* **Voice Message (TTS):** Different messages are available
* **Notification:** Custom message with the minutes left to leave home
* **Behavior:**
  - The alarm is triggered 5 minutes after the wake up time
   - The notification plays randomly one of the audio files found at sounds/checkpoints/ (even when app is closed)
   - TTS starts 5 seconds after notification sound playback begins
  - It plays a TTS message that includes the minutes left to go, so the message is dynamic.
  - There are different types of notification message (TTS) depending on the time available. Choose one randomly from the right category based on minutes available.
    - if there is more than 75% of the time available from wake-up to leave time:
      - "Come on! We've a streak to beat, we're leaving in {minutes left to go} minutes."
      - "What, I won't be the first? Come on, we still have {minutes left to go} minutes to leave."
      - "Today is a fantastic day to be first. We still have {minutes left to go} minutes."
      - If there is a reward defined not achieved yet: "Come on, we have to leave in {minutes left to go} minutes if we want to win the {reward}"
    - else if there is more than 50% of the time available from wake-up to leave time:
      - "I've seen faster turtles. We have {minutes left to go} minutes left to leave."
      - "Do you expect to arrive on time? Hurry, we only have {minutes left to go} minutes left."
      - "Why are you moving so slowly? We need to leave in {minutes left to go} minutes."
      - If there is a reward defined not achieved yet: "We need to leave in {minutes left to go} minutes if we want {reward}"
    - else
      - "You look like sloths, run because you only have {minutes left to go} minutes left"
      - "I've never seen a family this slow. You have {minutes left to go} minutes left."
      - "Hurry up! We have {minutes left to go} minutes left to go"
      - "Are you deaf? We have to leave in {minutes left to go} minutes"
      - If there is a reward defined not achieved yet: "Do you still want the {reward}? If we don't leave the house in {minutes left to go} minutes, we won't get it.
  - It's triggered again every 5 minutes updating the TTS message with the minutes left to go.
  - The alarm doesn't trigger after 5 minutes before time to leave.
  - Each plays TTS message automatically in background. No need to open app.
* **Reliability:** High (uses AlarmManager for guaranteed delivery)

#### **4.3. Leave Home Soon Alarm (ID: 3)**

* **Trigger:** 5 minutes before leave home time
* **Voice Message (TTS):** "In five minutes we must leave home, hurry up!!"
* **Notification:** "🏃 Leave Home Soon!"
* **Behavior:**
  - The alarm is triggered 5 minutes before the time to leave
  - Creates sense of urgency as departure time approaches
   - The notification plays randomly one of the audio files found at sounds/leave-soon/ (even when app is closed)
   - TTS starts 5 seconds after notification sound playback begins
  - Plays TTS message automatically
* **Reliability:** High (AlarmManager-based)

#### **4.4. Leave Home Alarm (ID: 4)**

* **Trigger:** Exactly at leave home time
* **Voice Message (TTS):** "We leave home now or we'll be late."
* **Notification:** "🚪 Leave Home Now!"
* **Behavior:**
  - The alarm is triggered at time to leave
  - Final reminder to depart
   - The notification plays sounds/leave-now/war-horn.wav (even when app is closed)
   - TTS starts 5 seconds after notification sound playback begins
  - Plays TTS message automatically
  - A countdown timer begins from the leave home time to the arrival time so that the user can see how much time they have left
  - The coundown timer is shown in the home screen.
* **Reliability:** High (AlarmManager-based)

#### **4.5. Pre Arrival Check Alarms (IDs: 5, 7, 8)**

Three scheduled reminder alarms prompt the user to confirm arrival before the deadline. Their purpose is twofold:

1. **Urgency:** Alert the family that the countdown is finishing so they must hurry up.
2. **Prevent accidental failure:** If the family arrived on time but forgot to tap the confirmation button, the day would be recorded as a failure. Repeated reminders reduce the chance of this happening.

Each alarm fires at a fixed offset before the arrival deadline, plays a custom notification sound (no TTS), and includes an action button to confirm arrival directly from the notification.

##### **Alarm Schedule**

| Alarm | ID | Trigger | Notification Title | Notification Message |
|-------|----|---------|--------------------|----------------------|
| Pre Arrival Check 1 | 5 | 60 seconds before arrival deadline | "🎯 Have we arrived already?" | "Don't forget to confirm your arrival. 1 minute left!" |
| Pre Arrival Check 2 | 7 | 30 seconds before arrival deadline | "🎯 Have we arrived already?" | "Don't forget to confirm your arrival. 30 seconds left!" |
| Pre Arrival Check 3 | 8 | 10 seconds before arrival deadline | "⚠️ Last chance!" | "Confirm now or today will be marked as late. 10 seconds left!" |

##### **Action Buttons**

All three notifications include the same action button:
  - "✅ Yes, we have" — Marks the day as arrived on time

##### **Behavior**

* Each notification plays a **custom sound** that escalates in urgency:
  - **T-60s (ID 5):** Gentle reminder chime
  - **T-30s (ID 7):** More urgent alert tone
  - **T-10s (ID 8):** Critical/alarm tone
* **No TTS** — sound-only notifications to avoid overlapping voice messages near the deadline
* Notifications are delivered even when the app is in the background, closed, or the device is locked (AlarmManager-based)
* Tapping "✅ Yes, we have" on **any** of the three notifications:
  - Increments streak and marks day as achieved
  - Stops the countdown timer
  - Cancels any remaining Pre Arrival Check alarms that haven't fired yet
  - Cancels the Arrival Alarm (ID 6) since it's no longer needed
* If the user already confirmed arrival (e.g., via an earlier notification), subsequent Pre Arrival Check alarms are **silently skipped** (no notification shown)

##### **Cancellation Logic**

When the user confirms arrival from any source (notification action button or in-app button):
* All three Pre Arrival Check alarms (IDs 5, 7, 8) are cancelled for the current day
* The Arrival Alarm (ID 6) is cancelled for the current day
* No further notifications are shown for the current journey

* **Reliability:** High (AlarmManager-based, 3 independent alarms for redundancy)

#### **4.6. Arrival Alarm (ID: 6)**

* **Trigger:** At arrival deadline
* **Notification:** "⌛ Time is up!"
* **Message:** "Sorry, you did not make it today"
* **Behavior:**
   - Silent notification only (no custom sound and no TTS)
  - This notification is triggered if the user hasn't confirmed they arrived on time
  - It marks day as missed.
* **Reliability:** High (AlarmManager-based)

#### **Technical Implementation**

**Core Technology Stack:**
* All alarms use `android_alarm_manager_plus` for reliable background execution
* TTS uses `flutter_tts` plugin to speak messages automatically
* Alarms persist through app closure, phone restart, and Doze mode
* Each alarm callback runs in isolated background context
* Battery optimization set to "unrestricted" for consistent delivery

**7-Day Rolling Window Re-Scheduling Strategy:**

To ensure maximum reliability and eliminate single points of failure, the app maintains alarms for the next 7 days at all times:

* **Initial Setup:** When settings are saved, all alarms are scheduled for the next 7 days
* **Daily Extension:** When wake-up alarm fires each morning, it schedules alarms for day 8, maintaining the 7-day rolling window
* **Self-Healing:** When app launches, it verifies at least 2 days of alarms exist ahead; if not, reschedules the full 7-day window
* **Settings Changes:** When times are updated, all existing alarms are cancelled and the full 7-day window is rescheduled with new times

**Alarm ID Scheme:**

To support multiple days of alarms without conflicts, each alarm uses a unique ID based on day offset and alarm type:

```
Alarm ID = (day_offset × 1000) + alarm_type

Examples:
- Day 0, Wake-up (type 1):        0 × 1000 + 1   = 1
- Day 1, Wake-up (type 1):        1 × 1000 + 1   = 1001
- Day 2, Checkpoint #1 (type 100): 2 × 1000 + 100 = 2100
- Day 6, Arrival (type 6):        6 × 1000 + 6   = 6006
```

**Day-of-Week Scheduling Support:**

Alarms are only scheduled for days that match the user's active pattern:
* **Active Days:** User selects which days of the week alarms should fire (e.g., weekdays only)
* **Skip Dates:** User can disable alarms for specific dates (holidays, sick days)
* **Conditional Scheduling:** Each day in the 7-day window is checked against active pattern before scheduling

**Reliability Guarantees:**

* **7 consecutive wake-up failures** required to break the system
* **User opening app at any time** triggers self-healing and restores missing alarms
* **Maximum alarms:** 56 total (well within Android's 500+ alarm limit per app)
* **Transparent:** User can verify scheduled alarms in Android system settings

---

### **5\. Today's result: success or failure**

The Today's Result frame displays the outcome of the daily morning journey and appears on the home screen to provide immediate feedback.

#### **When It Appears**

**Success Case:**
* **Trigger:** User confirms arrival on time (via Pre Arrival Check notification or manual confirmation before deadline)
* **Appears:** Immediately after confirmation
* **Displays:** Success message with confetti animation

**Failure Case:**
* **Trigger:** Arrival Alarm fires at deadline without prior confirmation
* **Appears:** Immediately when deadline passes
* **Displays:** Failure message (encouraging tone)

#### **When It Disappears**

* **Timing:** Automatically disappears at the next wake-up time
* **Reason:** Clears previous day's result to start fresh for the new day
* **Note:** Today's Mission and Today's Result are independent frames that can coexist on the home screen

#### **Success Outcome**

**Visual Feedback:**
1. **Confetti Animation:** Colorful confetti bursts from screen center for 3 seconds
2. **Result Message:** "✅ Success! We arrived on time today!"

**State Changes:**
* Countdown timer stops and disappears
* Streak increments by 1
* Character may level up (if reaching threshold)
* Day marked as successful in monthly history
* Arrival Alarm is cancelled (no longer needed)

#### **Failure Outcome**

**Visual Feedback:**
1. **No Animation:** No confetti or negative visuals
2. **Result Message:** "⌛ We didn't make it today. Tomorrow we try again."

**State Changes:**
* Countdown timer stops and disappears
* Streak resets to 0
* Character returns to Level 0 (Beginner Runner)
* Day marked as failed in monthly history

#### **Technical Notes**

* Result frame persists until end of day or next wake-up time (survives app restarts)
* Confetti uses `confetti` package with ConfettiController
* Result state stored locally to show correct message after app closure
* Frame automatically clears to prevent clutter accumulation

---

### **6\. Streak system**

The streak system tracks consecutive successful days and provides visual progression to maintain motivation through gamification.

#### **Streak Tracking**

* **Increment:** Streak increases by 1 each day the user arrives on time
* **Reset:** Streak resets to 0 if the user fails to arrive on time (unless a freeze is applied)
* **Display:** Current streak number shown on home screen with fire icon badge
* **Persistence:** Streaks are saved locally and survive app restarts

#### **Level Progression System**

The app uses a Duolingo-style character evolution system with 5 visual levels based on streak count:

| Level | Streak Range | Character | Color Theme | Description |
|-------|-------------|-----------|-------------|-------------|
| 0 | 0-9 days | Beginner Runner | Orange | Just starting the journey |
| 1 | 10-19 days | Occasional Runner | Green | Building the habit |
| 2 | 20-29 days | Pro Runner | Purple | Getting serious |
| 3 | 30-39 days | Champion Runner | Red | Almost at the top |
| 4 | 40+ days | Ultimate Jaguar | Gold | Maximum level achieved |

#### **Visual Design**

The streak card on the home screen displays:

* **Character Image:** Large (120x120) character image representing current level
* **Colored Circle Background:** Color-coded background matching the level theme
* **Fire Badge Overlay:** Positioned bottom-right, shows streak number with fire icon
* **Level Name:** Displays current achievement tier (e.g., "Pro Runner")
* **Progress Message:** Shows days remaining to reach next level
  - Example: "5 days until next level! 🚀"
  - At maximum level: "Maximum level reached! 🏆"

#### **Motivation Strategy**

* **Character Evolution:** Visual progression creates tangible sense of achievement
* **Family-Friendly Design:** Characters designed to appeal to both children and adults
* **Clear Goals:** Progress message shows exactly how many days until next milestone
* **No Punishment:** Missing a day resets progress but provides encouraging message to try again
* **Long-Term Engagement:** 5 levels require 40+ days, encouraging sustained habit formation

#### **Technical Notes**

* Character images stored in `assets/images/streak/`
* Level determination calculated dynamically based on current streak
* Background colors and level names managed by `_getStreakLevelInfo()` helper method

---

### **7\. Rewards System (Parent‑Driven)**

The Rewards System provides family-defined incentives tied to streak milestones, keeping children motivated with tangible, achievable rewards.

#### **Purpose**

* Provide family-defined incentive for reaching streak milestones
* Keep children motivated with tangible rewards
* Simple, single-focus reward system (one active reward at a time)
* Foster engagement through visible progress tracking

#### **Display Location**

**Position:** Home screen, directly below the streak card
**Visibility:** Always visible when a reward is active
**Layout:** Compact card design that doesn't dominate the screen

#### **Default Reward (First Launch)**

When the app is first launched, a default reward is automatically suggested:

* **Reward Name:** "Movie night with popcorn 🍿"
* **Required Streak:** 5 days
* **Initial Message:** "Only 5 days to earn movie night with popcorn 🍿"
* **Purpose:** Gets users started immediately without configuration friction

#### **Reward Display Components**

The reward card shows:

1. **Visual Progress Bar**
   * Horizontal progress bar showing percentage complete
   * Example: `[████████░░] 80%`
   * Color-coded to match streak level theme
   * Fills left-to-right as streak increases

2. **Progress Message**
   * Dynamic text showing days remaining
   * Updates automatically as streak changes
   * Emoji included for visual appeal

3. **Manage Button**
   * Small button/icon to access reward management
   * Opens reward configuration dialog
   * Always accessible for quick updates

#### **Reward Management Dialog**

Accessed via "Manage" button on the reward card.

**Dialog Components:**

1. **Reward Name Input**
   * Text field for custom reward name
   * Placeholder: "Enter reward name (e.g., Pizza night 🍕)"
   * Supports emojis
   * Current value pre-filled when editing

2. **Streak Requirement Selector**
   * Number picker with three components:
     - Decrease button (-)
     - Current value display (e.g., "5 days")
     - Increase button (+)
   * **Minimum:** 3 days (prevents unrealistic goals)
   * **Maximum:** 30 days (keeps goals achievable)
   * **Default:** 5 days

3. **Quick Reward Templates** (Optional Enhancement)
   * Pre-defined suggestions to speed up creation:
     - 🍿 Movie night
     - 🍕 Pizza dinner
     - 🎮 Extra game time
     - 🏞️ Park visit
     - 🎨 Art project
     - 🍦 Ice cream outing
   * Tapping a template auto-fills the reward name
   * Parent can still edit the template text

4. **Action Buttons**
   * **Cancel:** Dismiss dialog without changes
   * **Save:** Update reward and close dialog

**Save Behavior:**
* Updates reward name and required streak
* Recalculates progress based on current streak
* Updates progress message immediately
* Persists changes locally

#### **Progress States**

The reward message changes dynamically based on progress:

**1. Initial/Early Progress (0-49%)**
```
Only 5 days to earn movie night with popcorn 🍿
Only 4 days to earn movie night with popcorn 🍿
Only 3 days to earn movie night with popcorn 🍿
```

**2. Halfway Milestone (50%)**
```
Halfway there! 🔥 2 more days to earn movie night with popcorn 🍿
```
* Different emoji and tone to celebrate progress
* Reinforces they're making good progress

**3. Almost There (1 day remaining)**
```
Almost there! 🚀 1 day to earn movie night with popcorn 🍿
```
* Special message for final day
* Builds anticipation and excitement

**4. Goal Achieved**
```
🎉 Congratulations! You earned movie night with popcorn 🍿
```
* Celebration message replaces progress message
* Confetti animation plays (reuses existing celebration code)
* Trophy/medal icon appears briefly
* "Set Next Reward" button appears

**5. After Streak Failure**

When the streak resets to 0, the reward is not lost but delayed:

```
Streak reset 😔 But you can still earn your reward!
Progress: 0/5 days toward movie night with popcorn 🍿
[Keep Going] [Choose New Reward]
```

* Frame it as "delay" not "failure"
* Progress resets to 0 but reward remains active
* Two action buttons:
  - **Keep Going:** Continue with same reward (resets progress to 0)
  - **Choose New Reward:** Opens management dialog to pick different goal

#### **Achievement Celebration**

When the reward goal is reached (streak meets or exceeds requirement):

**Visual Feedback:**
1. Confetti animation bursts from screen center (3 seconds)
2. Trophy/medal icon appears briefly
3. Success message: "🎉 Congratulations! You earned [reward name]"
4. Reward card background changes to celebratory color (gold/green)

**State Changes:**
* Mark reward as completed
* Store completion date
* Show last completed reward in small badge

**Next Steps:**
* "Set Next Reward" button appears prominently
* Tapping opens reward management dialog
* Encourages continuous engagement with new goals

#### **Completion History (Simple)**

After a reward is achieved, show a small completion badge:

```
✅ Last achievement: Movie night with popcorn 🍿 (Feb 1)
```

* Shows only the most recent completed reward
* Provides proof of achievement to children
* Parent can reference it later
* Doesn't clutter the interface with full history

#### **Progress Updates**

**On Success (Streak Increments):**
1. Streak counter increases by 1
2. Progress bar advances
3. Progress message updates (e.g., "5 days" → "4 days")
4. If goal reached, trigger celebration

**On Failure (Streak Resets):**
1. Streak counter resets to 0
2. Progress bar resets to empty
3. Show "delayed but not lost" message
4. Offer options to continue or change reward

#### **Technical Implementation**

* **Storage:** SharedPreferences for reward data
  - Reward name (String)
  - Required streak (int)
  - Creation date (DateTime)
  - Completion date (DateTime, nullable)
  - Active status (bool)

* **Progress Calculation:**
  ```dart
  int daysRemaining = max(0, requiredStreak - currentStreak);
  double progressPercent = (currentStreak / requiredStreak) * 100;
  ```

* **State Management:** Provider pattern for reactive updates
* **Persistence:** Reward survives app restarts
* **Validation:** Minimum 3 days, maximum 30 days enforced in UI

#### **Design Principles**

* **Single Reward Focus:** Only one active reward at a time (reduces complexity)
* **Default Suggestion:** App suggests a reward immediately (eliminates blank slate)
* **Visual Progress:** Progress bar makes advancement tangible for children
* **Positive Framing:** Failure delays but doesn't destroy the reward
* **Immediate Feedback:** Progress updates instantly after each success
* **Simple Management:** 3-tap flow to update reward (Open → Edit → Save)

---

## **8\. Testing Tools (Development Only - Not for Production)**

⚠️ **WARNING:** This feature is strictly for development and testing purposes. Must be removed before production release.

### **Test Button**

A testing utility that simulates a compressed morning journey for rapid validation of alarm flows, countdown timer, and arrival confirmation logic.

#### **Location**

* **Position:** App bar, between home title and settings icon
* **Icon:** Orange science beaker icon (🧪)
* **Tooltip:** "Test Countdown"
* **Visibility:** Development builds only

#### **Purpose**

Allows developers and testers to validate the complete morning journey workflow in approximately 4 minutes instead of waiting for real morning hours:

* Verify alarm scheduling works correctly
* Test countdown timer appearance and behavior
* Validate arrival confirmation flow
* Test success/failure logic
* Check streak updates and confetti animations
* Debug edge cases without waiting overnight

#### **Test Flow Dialog**

When tapped, shows a confirmation dialog explaining the test sequence:

**Dialog Title:** "🧪 Test All Alarms (20-Minute Journey)"

**Dialog Content:**
```
This will test ALL alarm types in ~20 minutes:

✅ Wake-up alarm (T+10 sec)
✅ Checkpoint alarm #1 (T+10 min)
✅ Leave Home Soon (T+11 min)
✅ Leave Home → countdown starts (T+16 min)
✅ Pre-Arrival Check (T+18 min)
✅ Arrival deadline (T+20 min)

Tap "Arrived" before deadline to test success path.
Let timer expire to test failure path.

⚠️ Cannot run between 11:40 PM - midnight.
```

**Actions:**
* **Cancel:** Dismisses dialog without starting test
* **🚀 Start Test:** Initiates compressed test sequence

#### **Test Execution**

When user taps "Start Test", the following happens automatically:

**1. Environment Reset:**
* Clears any existing result for today's date
* Resets arrival confirmation flag (`arrival_confirmed = false`)
* Prepares clean state for test run

**2. Compressed Timeline Creation:**

Creates test settings with times calculated to trigger ALL alarm types in minimum possible time while respecting alarm scheduling logic:

**Key Constraint:** Checkpoint alarms require wake-up + 10 min < leave - 5 min, which means leave must be > wake + 15 minutes.

**Calculated Test Times:**
* **Wake-up time:** Current time + 10 seconds (allows processing time)
* **Leave home time:** Current time + 15 minutes 40 seconds
* **Arrival deadline:** Current time + 19 minutes 40 seconds

**Why These Specific Times:**

The 15 minute 40 second gap between wake-up and leave is the **minimum required** to test checkpoint alarms:
- First checkpoint fires at: wake-up + 10 min = T+10:10
- Checkpoint cutoff is: leave - 5 min = T+15:40 - 5:00 = T+10:40
- Since T+10:10 < T+10:40, one checkpoint alarm schedules successfully ✅
- Leave Home Soon fires at: leave - 5 min = T+10:40
- Journey duration (leave to arrival): 4 minutes (realistic minimum)

This compressed timeline triggers the exact same scheduling logic as production with no shortcuts or special cases.

**3. Test Deadline Storage:**

Sets a special test deadline in SharedPreferences:
* Key: `test_arrival_deadline`
* Value: Exact DateTime for arrival (current time + 19:40)
* Purpose: Countdown timer uses this to show accurate remaining time during test
* Persistence: Automatically cleared when next real wake-up alarm fires

**4. Standard Alarm Scheduling:**

Calls standard `saveSettings()` flow with test times:
* Cancels all existing alarms (7-day window cleared)
* Schedules full 7-day rolling window using test times
* Day 0 alarms use compressed schedule, Days 1-6 use same times for next days
* Uses identical alarm callbacks as production
* No test-specific code paths - validates complete production logic

**5. All Alarms That Will Fire During Test:**

Based on the compressed timeline, **all 6 alarm types** will trigger:

| Time Offset | Alarm Type | ID | Action |
|------------|------------|-----|---------|
| T+10 sec | Wake-up | 1 | TTS: "Good morning! Today's mission is to arrive at school on time. Let's go!" |
| T+10 min 10 sec | Checkpoint #1 | 100 | TTS: "Hey! How are things going? We have 5 minutes left to go" |
| T+10 min 40 sec | Leave Home Soon | 3 | TTS: "In five minutes we must leave home, hurry up!!" |
| T+15 min 40 sec | Leave Home | 4 | TTS: "We leave home now or we'll be late." + Countdown timer starts |
| T+17 min 40 sec | Pre-Arrival Check | 5 | Notification with "✅ Yes, we have" button |
| T+19 min 40 sec | Arrival | 6 | TTS: "Sorry, you did not make it today" (if no confirmation) |

**Note:** Only one checkpoint alarm fires (not multiple) due to the compressed 15:40 gap. In production with realistic timing (e.g., 6:30 AM to 7:45 AM = 75 minutes), 6-7 checkpoints would fire.

**6. User Confirmation Snackbar:**

Shows orange informational message for 7 seconds:

```
🧪 Test Started! (20-minute journey)
• Wake-up: in 10 seconds
• Checkpoint #1: in 10 minutes
• Leave Home: in 16 minutes → countdown starts
• Pre-Arrival Check: in 18 minutes
• Arrival deadline: in 20 minutes
• Stay on screen to observe alarms firing
```

#### **Expected Test Behavior**

**Complete Timeline of Events:**

* **T+0 sec:** Test initiated, snackbar shown, settings saved
* **T+10 sec:** Wake-up alarm fires
  - TTS message plays: "Good morning! Today's mission is to arrive at school on time. Let's go!"
  - Notification shown: "🌅 Good Morning!"
  - Today's Mission frame visible on home screen
* **T+10 min 10 sec:** Checkpoint alarm #1 fires
  - TTS message plays: "Hey! How are things going? We have 5 minutes left to go"
  - Dynamic message calculated from current time to leave time
  - No notification, only voice
* **T+10 min 40 sec:** Leave Home Soon alarm fires
  - TTS message plays: "In five minutes we must leave home, hurry up!!"
  - Notification shown: "🏃 Leave Home Soon!"
  - Creates urgency 5 minutes before departure
* **T+15 min 40 sec:** Leave Home alarm fires **[CRITICAL MOMENT]**
  - TTS message plays: "We leave home now or we'll be late."
  - Notification shown: "🚪 Leave Home Now!"
  - **Countdown timer appears on home screen**
  - Today's Mission frame disappears (replaced by countdown)
  - Timer shows ~4 minutes remaining until arrival deadline
* **T+17 min 40 sec:** Pre-Arrival Check notification appears
  - Notification title: "🎯 Have we arrived on time?"
  - Message: "Tap to confirm your arrival status"
  - Action button: "✅ Yes, we have"
  - **User can tap to confirm arrival (success path)**
  - Notification remains until user taps or deadline passes
* **T+19 min 40 sec (if no confirmation):** Arrival alarm fires **[DEADLINE]**
  - TTS message plays: "Sorry, you did not make it today"
  - Notification shown: "⌛ Time is up!"
  - Countdown timer stops at 00:00
  - Day marked as failed
  - Streak resets to 0

**Success Path (User Confirms Before Deadline):**
1. User taps "✅ Yes, we have" button anytime between T+17:40 and T+19:40
2. Immediate feedback:
   - Confetti animation bursts from center of screen (3 seconds)
   - Success message appears: "✅ Success! We arrived on time today!"
   - Countdown timer stops immediately and disappears
3. State changes:
   - Streak increments by 1 (e.g., 5 → 6)
   - Character may level up if threshold reached
   - Day marked as successful in monthly history
   - Arrival alarm (ID: 6) is cancelled automatically
   - Today's Mission frame returns to display
4. Persistence:
   - Success result survives app restarts
   - Remains visible until next wake-up time
   - Coexists with streak card and reward progress

**Failure Path (No Confirmation):**
1. T+19 min 40 sec passes without user tapping confirmation button
2. Arrival alarm callback executes automatically:
   - TTS message plays in background
   - Notification appears with failure message
   - Countdown timer shows 00:00 briefly, then disappears
3. State changes:
   - Streak resets to 0 (regardless of previous value)
   - Character returns to Level 0 (Beginner Runner, orange)
   - Day marked as failed in monthly history
   - Today's Mission frame returns to display
4. UI feedback:
   - Failure message: "⌛ We didn't make it today. Tomorrow we try again."
   - No confetti or celebrations
   - Encouraging tone (no punishment language)
5. Persistence:
   - Failure result survives app restarts
   - Remains visible until next wake-up time

**Observable Indicators During Test:**

* **Home Screen Changes:**
  - Start: Today's Mission frame visible
  - T+15:40: Countdown timer replaces Today's Mission
  - T+19:40 or on confirmation: Result message appears, countdown disappears
  
* **Notification Tray:**
  - Multiple notifications accumulate (wake-up, leave-soon, leave-home, pre-arrival)
  - User can tap notifications to open app
  - Notifications persist until dismissed

* **Audio Feedback:**
  - All TTS messages play automatically (ensure device volume up)
  - Messages play even if app in background
  - No overlap (each message completes before next alarm fires)

* **Streak Card Updates:**
  - Updates immediately upon success/failure
  - Fire badge number changes (increment or reset to 0)
  - Character image may change if leveling up
  - Progress message updates ("X days until next level")

* **Reward Progress (if active):**
  - Progress bar advances on success
  - Progress message updates (e.g., "4 days" → "3 days")
  - Resets to 0% on failure but reward remains active

#### **Testing Best Practices**

**Before Running Test:**
* Ensure app has all required permissions (exact alarms, notifications, microphone for TTS)
* **Keep device volume UP** to hear all TTS messages
* Keep app in foreground for first 16 minutes to see all UI changes
* Can put app in background after countdown appears (T+15:40) to test persistence
* Clear notification tray before test to easily spot new notifications
* Have at least 25 minutes of uninterrupted time for full test cycle

**What to Observe:**

| Timing | What to Watch | Expected Result |
|--------|---------------|-----------------|
| T+10 sec | Audio & notification | Wake-up TTS plays, notification appears |
| T+10 min | Audio only | Checkpoint TTS plays with "5 minutes left" |
| T+11 min | Audio & notification | Leave-soon TTS plays, notification appears |
| T+16 min | UI change + audio | Countdown timer appears, leave-home TTS plays |
| T+17 min | Countdown ticking | Timer shows ~2 minutes remaining |
| T+18 min | Notification | Pre-arrival check with action button |
| T+20 min | Result screen | Success (if confirmed) or Failure (if not) |

**Interactive Testing Paths:**

**Path 1: Success Journey (Recommended First Test)**
1. Start test
2. Observe all alarms firing sequentially
3. At T+18 min, tap "✅ Yes, we have" button in notification
4. Verify: Confetti plays, countdown stops, streak increments
5. Check monthly calendar shows success for today

**Path 2: Failure Journey**
1. Start test
2. Observe all alarms firing
3. DO NOT tap confirmation button
4. Wait until T+20 min for arrival alarm
5. Verify: Failure message appears, countdown stops, streak resets to 0
6. Check monthly calendar shows failure for today

**Path 3: Background Persistence Test**
1. Start test
2. At T+16 min (when countdown appears), press home button
3. Keep app in background until T+18 min
4. Tap pre-arrival notification to reopen app
5. Verify: Countdown timer restored correctly with accurate time
6. Confirm arrival and verify success

**Path 4: App Restart Test**
1. Start test
2. At T+16 min, force-close app (swipe away from app switcher)
3. Wait 1 minute
4. Reopen app
5. Verify: Countdown timer reappears with correct remaining time
6. Complete test (confirm or let expire)

**Known Limitations:**
* **Cannot run between 11:40 PM - midnight:** Test crosses midnight boundary causing alarm times to appear "in the past" and not schedule
* Only 1 checkpoint alarm fires (vs 6-7 in real morning with 75-minute gap)
* TimeOfDay conversion may cause ±30 second timing variations
* Multiple rapid sequential tests may interfere (wait 25 min between tests)
* Test overwrites any real result for today's date (use on test days only)
* Checkpoint message says "5 minutes left" due to compressed timeline (vs dynamic real values)

**Troubleshooting:**

| Issue | Likely Cause | Solution |
|-------|--------------|----------|
| Test refuses to start (11:40 PM - midnight) | Not enough time before midnight | Wait until after midnight or test earlier in day |
| Wake-up alarm doesn't fire | Alarm permissions denied | Check Settings > Apps > Morning On Time > Alarms |
| No TTS audio | Device muted or TTS not initialized | Increase volume, restart app |
| Countdown doesn't appear | Leave Home alarm failed | Check logs for alarm scheduling errors |
| Times seem wrong | TimeOfDay rounding | Expected - times rounded to nearest minute |
| App crashes at T+16 min | Memory issue | Ensure device has available RAM |

#### **Security Considerations**

* **No Production Risk:** Test button uses identical production code paths with no shortcuts
* **Data Safety:** Test results stored using same mechanisms as real results (can be viewed/deleted in monthly calendar)
* **Alarm Safety:** Uses standard AlarmManager APIs with proper IDs - no conflicts with real alarms
* **User Data Integrity:** Test overwrites today's result only - historical data remains intact
* **Permission Requirements:** Same as production (exact alarms, notifications, microphone)
* **No Network Calls:** Fully offline test, no external dependencies
* **State Cleanup:** Test deadline auto-clears on next real wake-up alarm
* **Reversibility:** User can manually delete test result from calendar if needed

**Potential Issues:**

| Issue | Risk Level | Mitigation |
|-------|-----------|------------|
| Test on real school day | Medium | User sees test result instead of real result | Document "test days only" in testing guide |
| Multiple rapid tests | Low | Alarms may overlap or interfere | Enforce 25-minute cooldown between tests |
| Test during real morning | Low | Overwrites real journey in progress | Show warning if current time between wake-up and arrival |
| Memory usage spike | Very Low | Multiple alarms in short time | Total alarms: 42 (well within limits) |

#### **Future Enhancements (Optional)**

**Test Mode Improvements:**

1. **Multiple Test Presets:**
   ```
   🧪 Quick Test (20 min) - Tests all alarms with 1 checkpoint
   🧪 Extended Test (30 min) - Tests with 3 checkpoints
   🧪 Real-Time Test (60 min) - Near-realistic timing with 5 checkpoints
   ```

2. **Test Configuration Dialog:**
   - Slider to adjust journey duration (15-60 minutes)
   - Checkbox to enable/disable specific alarms
   - Toggle for automatic success (auto-confirms at T+18 min)

3. **Test Status Indicator:**
   - Badge on home screen: "🧪 Test Mode Active"
   - Countdown shows test duration remaining
   - Clear visual distinction from real journey

4. **Test Result Isolation:**
   - Store test results in separate storage key
   - Monthly calendar shows test days with special marker
   - Option to exclude test days from streak calculation
   - "Clear All Test Data" button in settings

5. **Test Log Export:**
   - Generate detailed test report with timing data
   - Show which alarms fired vs skipped
   - Export logs as text file for debugging
   - Share test results with development team

6. **Automated Test Scenarios:**
   ```dart
   enum TestScenario {
     ALL_ALARMS,        // Tests 6 alarm types
     SUCCESS_PATH,      // Auto-confirms at T+18 min
     FAILURE_PATH,      // Never confirms, tests failure flow
     BACKGROUND_ONLY,   // Forces app to background at T+1 min
     RESTART_TEST,      // Force-closes and reopens app at T+10 min
   }
   ```

7. **Build Flavor Integration:**
   ```dart
   // Only show test button in debug/staging builds
   if (kDebugMode || flavor == 'staging') {
     // Test UI visible
   }
   ```

8. **Test Analytics:**
   - Track which alarms fired on time vs late
   - Measure TTS playback latency
   - Record countdown timer accuracy
   - Log permission issues encountered

---

## **9\. Monthly History View**

A calendar-based reporting feature that displays the user's historical performance across the month, showing which days were successful, failed, or skipped.

#### **Purpose**

* Provide visual overview of monthly on-time performance
* Allow parents and children to review progress over time
* Identify patterns (e.g., certain days consistently missed)
* Celebrate achievements with visual success markers
* Secondary/reporting feature - not part of daily workflow

#### **Access Method**

**Location:** App bar, top-right area of home screen

**Icon:** 📅 Calendar icon

**Position:** Between the hourglass icon (test button) and settings gear icon

**Interaction:** Single tap opens full-screen monthly calendar view

**Rationale:**
* Standard placement for secondary/reporting features
* Keeps home screen focused on daily mission and motivation
* Always accessible but not intrusive
* Matches existing app bar pattern (3 icons: test, calendar, settings)

#### **Calendar View Layout**

When opened, displays a full-screen monthly calendar with:

**Header:**
* Current month and year (e.g., "February 2026")
* Navigation arrows to switch months (← →)
* Close button (X) to return to home screen

**Calendar Grid:**
* Standard 7-column layout (Sun-Sat or Mon-Sun based on locale)
* Current month's dates displayed prominently
* Previous/next month dates shown in muted colors for context

**Date Markers:**

Each date is visually coded based on journey outcome:

| Status | Visual Indicator | Meaning |
|--------|-----------------|---------|
| Success | ✅ Green checkmark or filled circle | Arrived on time that day |
| Failure | ⌛ Red X or hollow circle | Missed deadline that day |
| Skipped | 🚫 Gray dash or strikethrough | Manually skipped via settings |
| No Journey | Empty/default | Inactive day (weekend) or no alarm scheduled |
| Future | Muted/grayed out | Date hasn't occurred yet |
| Today | Highlighted border | Current day (outcome pending or just occurred) |

**Tap Interaction (Optional):**
* Tapping a date shows detailed information in a tooltip/modal:
  - Date: "Monday, Feb 9, 2026"
  - Outcome: "✅ Success - arrived on time!"
  - Times: "Wake: 6:30 AM | Left: 7:45 AM | Arrived: 7:58 AM"
  - Streak at that time: "Streak was 5 days"

#### **Monthly Statistics (Optional Enhancement)**

Display summary metrics at bottom of calendar:

```
February 2026 Summary:
✅ On-time days: 15
⌛ Late days: 2
📊 Success rate: 88%
🔥 Best streak: 7 days
```

#### **Data Source**

* Reads from locally stored daily results (SharedPreferences or SQLite)
* Each successful/failed journey writes a date-stamped record
* Skipped dates read from settings `skipDates` set
* Active days pattern determines which dates have "No Journey" status

#### **Edge Cases**

1. **First Launch (No History):**
   - Shows current month with all dates empty
   - Message: "Start your journey to see your progress!"

2. **Partial Month:**
   - Only shows outcomes for dates that have occurred
   - Future dates remain muted/empty

3. **Month Navigation:**
   - Can view past months to see historical data
   - Future months show empty calendar with scheduled active days indicated

4. **Test Results:**
   - Test journey results appear in calendar like real results
   - Consider indicator to differentiate test days (e.g., 🧪 badge)

#### **Design Principles**

* **Secondary Feature:** Not needed for daily app function
* **Quick Access:** One tap from home screen (app bar icon)
* **Visual Clarity:** Color-coded status makes month performance obvious at a glance
* **Minimal Home Screen Impact:** Icon in app bar doesn't compete with motivational content
* **Historical Context:** Helps users understand long-term patterns and improvement

#### **Technical Implementation**

* **Storage:** Daily results stored with date keys (YYYY-MM-DD format)
* **Calendar Widget:** Use Flutter `table_calendar` package or custom grid
* **State Management:** Provider pattern to reactively update after each journey
* **Performance:** Load only current month's data initially; fetch other months on demand
* **Persistence:** Results survive app restarts and updates

#### **Future Enhancements**

1. **Export/Share:** Export monthly report as image to share with family
2. **Trends:** Multi-month view showing success rate over time (line chart)
3. **Goals:** Set monthly on-time target (e.g., "18/20 school days")
4. **Notes:** Add optional notes to dates (e.g., "Sick day" or "Early dismissal")
5. **Filtering:** Toggle to show only school days vs all days

---


## **Non‑Functional Requirements**

* App must work offline during mornings  
* Notifications must work with locked screen  
* Voice playback must not require app foreground  
* Battery usage must be minimal

---

## **Risks & Mitigations**

| Risk | Mitigation |
| ----- | ----- |
| Users forget to confirm arrival | Clear arrival notification \+ grace period |
| Too many notifications | Strict limit to key moments only |
| Children ignore voice | Customizable voice tone and energy |
| Device volume too low to hear TTS | Volume check at app launch (if setup complete) and during setup saves, warns if < 70%, allowing user to adjust |

---

## **MVP Definition of Done**

* A parent can configure times in under 2 minutes  
* The app runs a full school morning without manual opening  
* Daily success/failure is recorded reliably  
* Streaks and rewards update correctly  
* Families feel less rushed after 2 weeks of use

---

## **Product Statement**

**Morning On Time helps families win the morning without adding anything to it.**

