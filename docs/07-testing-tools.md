# Testing Tools (Development Only - Not for Production)

*Part of the [Morning On Time PRD](MorningOnTime.md) — Section 8 of Functional Requirements*

---

**WARNING:** This feature is strictly for development and testing purposes. Must be removed before production release.

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
