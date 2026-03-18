# Home Screen Journey Card

*Part of the [Morning On Time PRD](MorningOnTime.md) — Section 2 of Functional Requirements*

---

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
