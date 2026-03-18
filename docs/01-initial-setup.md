# Initial Setup

*Part of the [Morning On Time PRD](MorningOnTime.md) — Section 1 of Functional Requirements*

---

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
  - "Never Late helps your family arrive on time consistently"
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
   * Opens Android settings page: Settings > Apps > Never Late > Battery
   * User must select "Unrestricted" or "Don't optimize"

3. **Permission Verification:**
   * App checks if both permissions are granted
   * If **both granted:** Proceed to Configuration Screen
   * If **either denied:** Show retry prompt:
     - "Permissions Required"
     - "Never Late needs both permissions to work reliably. Without them, alarms may not fire when your family needs them most."
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
