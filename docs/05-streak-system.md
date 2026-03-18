# Streak System

*Part of the [Morning On Time PRD](MorningOnTime.md) — Section 6 of Functional Requirements*

---

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
