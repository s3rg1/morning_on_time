# Rewards System (Parent-Driven)

*Part of the [Morning On Time PRD](MorningOnTime.md) — Section 7 of Functional Requirements*

---

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
