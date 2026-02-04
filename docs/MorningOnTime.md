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

2. **Optional Rewards:** User can define weekly rewards (e.g., "Movie night on Friday") linked to streak milestones

3. **Save & Initialize:** Once the user saves these settings:
   * All alarms are automatically scheduled for the next day
   * Home screen appears showing the **Today's Mission frame**
   * Today's Mission frame displays the configured times:
     - Wake-up time: [configured time]
     - Leave at: [configured time]
     - Arrive by: [configured time]

#### **Modifying Settings**

* Settings are accessible from the home screen at any time
* When times are updated, all existing alarms are cancelled and rescheduled with new values
* Today's Mission frame updates immediately to reflect new times

---

### **2\. Today's Mission**

The Today's Mission frame is a persistent information card displayed on the home screen that shows the user's daily schedule and current status.

#### **Purpose**

* Provides at-a-glance view of the day's time targets
* Keeps the daily goal ("Arrive on time!") visible and front-of-mind
* Shows current journey phase (before/during/after trip)
* Serves as the central reference point for the morning routine

#### **Information Displayed**

The frame shows three key times with corresponding status:

1. **Wake-up Time**
   * Label: "🌅 Wake up at:"
   * Time: User's configured wake-up time
   * Status indicator: Shows if this milestone has passed

2. **Leave Home Time**
   * Label: "🚪 Leave at:"
   * Time: User's configured departure time
   * Status indicator: Shows if departure time has passed

3. **Arrival Deadline**
   * Label: "🎯 Arrive by:"
   * Time: User's configured arrival time (latest acceptable arrival)
   * Status indicator: Shows if arrival time has passed

4. **Mission Statement**
   * Text: "Today's Mission: Arrive on time!"
   * Purpose: Reinforces the single daily objective

#### **When It Appears**

* **First Display:** Appears immediately after initial setup when times are saved
* **Daily Display:** Visible from wake-up time until leave home time
* **Persistence:** Survives app restarts during its display period

#### **When It's Replaced by Countdown Timer**

* **Trigger:** Exactly at leave home time (when Leave Home Alarm fires)
* **Action:** Today's Mission frame disappears and countdown timer takes its place
* **Reason:** During the trip to school, real-time countdown is more useful than scheduled times
* **Mutually Exclusive:** Only one is shown at a time - either Today's Mission OR countdown timer

#### **When It's Restored**

The Today's Mission frame reappears in two scenarios:

1. **After Success:**
   * User confirms arrival on time (before deadline)
   * Countdown timer stops and disappears
   * Today's Mission frame returns to display
   * Remains visible for rest of day alongside Today's Result (success message)

2. **After Failure:**
   * Arrival deadline passes without confirmation
   * Countdown timer stops and disappears
   * Today's Mission frame returns to display
   * Remains visible for rest of day alongside Today's Result (failure message)

3. **Next Day Reset:**
   * At next wake-up time, the cycle repeats
   * Today's Mission frame shows updated schedule for new day


#### **Dynamic Behavior**

* **Time Updates:** If user modifies settings, the displayed times update immediately
* **Status Indicators:** May show checkmarks or highlights as milestones pass (wake-up, departure)
* **Coexistence:** Can appear alongside Today's Result and streak card, but never with countdown timer

#### **Visual Design**

* Card-style frame with light background
* Clear typography for easy readability
* Icons for each time milestone (sunrise, door, target)
* Maintains visibility without dominating the screen

#### **Technical Notes**

* Times displayed in user's local format (12h/24h based on device settings)
* Frame refreshes when returning to home screen
* No interaction required - information-only display
* Syncs with saved time settings in SharedPreferences

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
  - Auto-schedule the next alarms: the checkpoint alarms, the leave home soon alarm, the leave home alarm, the pre arrival check alarm and the arrival alarm.
  - Auto-reschedules for next day
* **Reliability:** High (uses native Android AlarmManager, survives app closure and device restart)

#### **4.2. Checkpoint Alarms (IDs: 100-119)**

* **Trigger:** Every 10 minutes starting from wake-up time until the leave time
* **Voice Message (TTS):** "Hey! How are things going? We have x minutes left to go"
* **Notification:** "⏰ How are we going?" with the minutes left to leave home
* **Behavior:**
  - The alarm is triggered 10 minutes after the wake up time
  - It plays a TTS message that includes the minutes left to go, so the message is dynamic.
  - The alarm auto-reschedules evey 10 minutes updating the TTS message with the minutes left to go.
  - The alarm is disabled 5 minutes before time to leave.
  - Each plays TTS message automatically in background. No need to open app
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

* All alarms use `android_alarm_manager_plus` for reliable background execution
* TTS uses `flutter_tts` plugin to speak messages automatically
* Alarms persist through app closure, phone restart, and Doze mode
* Each alarm callback runs in isolated background context
* Battery optimization set to "unrestricted" for consistent delivery
* When time settings are updated (wake up, leave at and arrival time), all previous alarms are cancelled and rescheduled with new times.

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

