# **Product Requirements Document (PRD)**

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

When the app is launched for the first time, the user is guided through a simple time configuration:

1. **Configuration Screen:** User enters three required times:
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

### **2\. Today's Mission Frame**

The Mission frame is a dynamic information card on the home screen that shows upcoming alarms and reinforces the daily goal of arriving on time.

#### **Purpose**

* Shows only relevant, upcoming alarms (filters out past times)
* Automatically displays the next active day's schedule
* Provides clear mission statement with contextual date
* Keeps focus on what's coming next, not what's already passed

#### **Dynamic Header Logic**

The frame header changes based on which day has the next scheduled alarm:

1. **"Today's Mission: Arrive on time!"**
   * Shown when today is an active day and current time is before arrival deadline
   * Example: Monday morning before 8:00 AM arrival time

2. **"Tomorrow's Mission: Arrive on time!"**
   * Shown when today's journey is complete (after arrival deadline) and tomorrow is active
   * Example: Monday evening after 8:00 AM, showing Tuesday's schedule

3. **"[Weekday, Month Day] Mission: Arrive on time!"**
   * Shown when next active day is 2+ days away
   * Example: Friday evening showing "Monday, Feb 9 Mission" (skipping weekend)
   * Date format: Full weekday name, abbreviated month, day number

#### **Information Displayed**

The frame shows only **pending alarms** (alarms that haven't fired yet):

**Always Shown (if pending):**
1. **🌅 Wake up at:** User's configured wake-up time
2. **🚪 Leave at:** User's configured leave home time  
3. **🎯 Arrive by:** User's configured arrival deadline

**Filtering Rules:**
* If current time has passed wake-up → Don't show wake-up time
* If current time has passed leave time → Don't show leave time
* If current time has passed arrival → Switch to next day's mission
* Always show at least the times that haven't occurred yet

**Not Shown:**
* Checkpoint alarms (implementation detail)
* Leave Home Soon alarm (implementation detail)
* Pre-Arrival Check alarm (implementation detail)

**Example Scenarios:**

| Current Time | What's Shown |
|--------------|-------------|
| 6:00 AM (before everything) | Wake: 6:30 AM, Leave: 7:45 AM, Arrive: 8:00 AM |
| 6:45 AM (after wake-up) | Leave: 7:45 AM, Arrive: 8:00 AM |
| 7:50 AM (after leave) | Arrive: 8:00 AM |
| 8:10 AM (after arrival) | Tomorrow's mission (all 3 times) |

#### **Next Active Day Detection**

The frame intelligently finds the next day with scheduled alarms:

1. **Check if today is active:**
   * Is today's weekday in `activeDaysOfWeek`?
   * Is today's date NOT in `skipDates`?
   * Has today's arrival deadline not passed?
   * If YES → Show today's mission

2. **If today is done or skipped, find next active day:**
   * Start checking tomorrow, then day after, etc.
   * Find first date where:
     - Weekday is in `activeDaysOfWeek`
     - Date is NOT in `skipDates`
   * Show that date's mission

3. **Edge case - No active days in next 7 days:**
   * Show message: "No upcoming journeys scheduled"
   * Prompt user to check settings

#### **Interaction with Countdown Timer**

The Mission frame and countdown timer are **mutually exclusive**:

**When Countdown Appears:**
* Trigger: Leave Home alarm fires (at configured leave time)
* Action: Mission frame **hides completely**
* Reason: Countdown provides real-time urgency; static mission times are less relevant

**When Countdown Disappears:**
* Trigger: User confirms arrival OR arrival deadline passes
* Action: Mission frame **reappears showing next day's schedule**
* Reason: Today's journey is complete; prepare for tomorrow

**Example Flow:**
```
6:00 AM → Mission frame shows TODAY (wake/leave/arrive)
7:45 AM → Leave alarm fires → Mission frame HIDES, countdown APPEARS
8:00 AM → User confirms arrival → Countdown HIDES, Mission frame SHOWS TOMORROW
```

#### **Visibility Rules**

**Frame is VISIBLE when:**
* No countdown timer is active
* User has configured times (initial setup complete)
* There's at least one upcoming alarm to show

**Frame is HIDDEN when:**
* Countdown timer is active (between leave time and journey completion)
* User hasn't completed initial setup
* No active days exist in next 7 days

**Frame UPDATES when:**
* Any alarm fires (automatically filters out that time)
* Arrival deadline passes (switches to next day)
* User changes settings (new times reflected immediately)
* App reopens after being in background

#### **Skip Days & Weekend Handling**

**Natural Skip Behavior:**
* If tomorrow is a skip day (in `skipDates`), frame automatically shows next active day
* If weekends are disabled, Friday evening shows "Monday's Mission"
* No special "skip day" message needed - just show what's next

**Example:**
* User skips Wednesday for doctor appointment
* Tuesday evening after arrival → Frame shows "Thursday, Feb 12 Mission"
* No indication that Wednesday is skipped; it's simply not shown

#### **Visual Design**

* **Card Style:** Light background, rounded corners, subtle shadow
* **Header:** Bold mission statement with date context
* **Time List:** Vertical list with emoji icons and clear labels
* **Typography:** Large, readable times (user's 12h/24h format)
* **Spacing:** Comfortable padding between times
* **Animations:** Smooth fade when showing/hiding, slide when updating times

#### **Technical Implementation**

**Data Source:**
* Reads times from `AppSettings` (SharedPreferences)
* Checks `activeDaysOfWeek` set to determine valid days
* Checks `skipDates` set to filter excluded dates
* Compares current DateTime to alarm times for filtering

**No Alarm Queries Needed:**
* Does NOT query AlarmManager for scheduled alarms
* Uses settings as source of truth (simpler, faster)
* Assumption: Settings and scheduled alarms are always in sync

**State Management:**
* Provider-based reactivity (updates UI automatically)
* Rebuilds when settings change
* Rebuilds when time passes (periodic checks or alarm callbacks)

**Performance:**
* Lightweight calculation (date math only)
* No network calls
* Minimal battery impact (no background polling)

#### **Edge Cases Handled**

1. **Midnight Boundary:**
   * If arrival time < leave time (crosses midnight), handle date arithmetic correctly
   * Example: Leave at 11:50 PM, arrive at 12:10 AM (next day)

2. **No Active Days:**
   * All 7 weekdays disabled: Show "No journeys scheduled" message
   * Prompt user to enable at least one day

3. **Settings Changed Mid-Journey:**
   * If user changes times while countdown is active, countdown uses old times
   * Mission frame (when it reappears) will show new times

4. **App Restart:**
   * Frame state persists across app restarts
   * Recalculates next day and pending times on launch

5. **Test Mode:**
   * Test button creates temporary settings
   * Mission frame shows test times
   * After test completes, reverts to real settings

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
  - Plays TTS message automatically in background (even when app is closed)
  - Shows notification with mission reminder
* **Reliability:** High (uses native Android AlarmManager, survives app closure and device restart)

#### **4.2. Checkpoint Alarms (IDs: 100-119)**

* **Trigger:** Every 10 minutes starting from wake-up time until the leave time
* **Voice Message (TTS):** "Hey! How are things going? We have x minutes left to go"
* **Notification:** "⏰ How are we going?" with the minutes left to leave home
* **Behavior:**
  - The alarm is triggered 10 minutes after the wake up time
  - It plays a TTS message that includes the minutes left to go, so the message is dynamic.
  - It's triggered again every 10 minutes updating the TTS message with the minutes left to go.
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
  - Plays TTS message automatically
* **Reliability:** High (AlarmManager-based)

#### **4.4. Leave Home Alarm (ID: 4)**

* **Trigger:** Exactly at leave home time
* **Voice Message (TTS):** "We leave home now or we'll be late."
* **Notification:** "🚪 Leave Home Now!"
* **Behavior:**
  - The alarm is triggered at time to leave
  - Final reminder to depart
  - Plays TTS message automatically
  - A countdown timer begins from the leave home time to the arrival time so that the user can see how much time they have left
  - The coundown timer is shown in the home screen.
* **Reliability:** High (AlarmManager-based)

#### **4.5. Pre Arrival Check Alarm (ID: 5)**

* **Trigger:** Two minutes before the arrival deadline
* **Notification:** "🎯 Have we arrived on time?"
* **Message:** "Tap to confirm your arrival status"
* **Action Buttons:**
  - "✅ Yes, we have" - Arrived on time.
* **Behavior:**
  - Shows notification with confirmation buttons
  - Tapping "Yes" increments streak and marks day as achieved. Also stops the countdown timer and disables Arrival Alarm since it's not needed
* **Reliability:** High (AlarmManager-based)

#### **4.6. Arrival Alarm (ID: 6)**

* **Trigger:** At arrival deadline
* **Notification:** "⌛ Time is up!"
* **Message:** "Sorry, you did not make it today"
* **Behavior:**
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

#### **Integration with Voice Alarms** (Future Enhancement)

Voice messages can reference reward progress:

* Wake-up: "Good morning! Only 2 more days to earn movie night!"
* Pre-arrival: "Let's arrive on time and get closer to pizza night!"

*Note: Voice integration optional for MVP*

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

