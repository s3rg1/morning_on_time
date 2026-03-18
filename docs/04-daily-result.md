# Today's Result: Success or Failure

*Part of the [Morning On Time PRD](MorningOnTime.md) — Section 5 of Functional Requirements*

---

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
