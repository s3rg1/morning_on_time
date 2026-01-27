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
3. One optional check‑in via lock‑screen notification ("Going well" / "Running tight")  
4. Timely voice notifications at key moments  
5. Arrival confirmation by parent  
6. Success or failure is recorded  
7. Streak and reward progress updated

---

## **Functional Requirements**

### **1\. Initial Setup**

* Parent sets:  
  * Wake‑up time  
  * Leave‑home time  
  * Latest arrival time  
* Parent defines optional weekly rewards (e.g., "Movie night on Friday")  
* Settings are accessible from the home screen and can be changed at any time.

---

### **2\. Automatic Morning Activation**

The app automatically schedules and fires alarms throughout the morning without requiring user interaction. All alarms use Android's native AlarmManager for reliable background execution and automatically reschedule for the next day.

---

### **3\. Voice & Notification Engine**

The app schedules **5 different types of alarms** when settings are saved or updated:

#### **3.1. Wake-Up Alarm (ID: 1)**

* **Trigger:** At the user's configured wake-up time
* **Voice Message (TTS):** "Good morning! Today's mission is to arrive at school on time. Let's go!"
* **Notification:** "🌅 Good Morning!" with mission message
* **Behavior:** 
  - Fires exactly at wake-up time using AlarmManager
  - Plays TTS message automatically in background (even when app is closed)
  - Shows notification with mission reminder
  - Auto-reschedules for next day after firing
* **Reliability:** High (uses native Android AlarmManager, survives app closure and device restart)

#### **3.2. Check-In Alarms (IDs: 100-119)**

* **Trigger:** Every 8 minutes starting from wake-up time until 6 minutes before leave time
* **Voice Message (TTS):** "Hey! How are things going this morning?"
* **Notification:** "⏰ Quick Check-In" with two action buttons
* **Action Buttons:**
  - "✅ Going Well" - Morning is proceeding smoothly
  - "⚡ Running Tight" - Running behind schedule
* **Behavior:**
  - Multiple alarms scheduled throughout the morning window
  - Each plays TTS message automatically in background
  - No need to open app - responds via notification actions
  - Each alarm auto-reschedules individually for tomorrow
* **Reliability:** High (uses AlarmManager for guaranteed delivery)

#### **3.3. Leave Home Soon Alarm (ID: 3)**

* **Trigger:** 5 minutes before leave home time
* **Voice Message (TTS):** "In five minutes we must leave home, hurry up!!"
* **Notification:** "🏃 Leave Home Soon!"
* **Behavior:**
  - Creates sense of urgency as departure time approaches
  - Plays TTS message automatically
  - Auto-reschedules for next day
* **Reliability:** High (AlarmManager-based)

#### **3.4. Leave Home Alarm (ID: 4)**

* **Trigger:** Exactly at leave home time
* **Voice Message (TTS):** "We leave home now or we'll be late."
* **Notification:** "🚪 Leave Home Now!"
* **Behavior:**
  - Final reminder to depart
  - Plays TTS message automatically
  - Auto-reschedules for next day
* **Reliability:** High (AlarmManager-based)

#### **3.5. Arrival Check Alarm (ID: 5)**

* **Trigger:** 2 minutes before arrival deadline
* **Notification:** "🎯 Have we arrived on time?"
* **Message:** "Tap to confirm your arrival status"
* **Action Buttons:**
  - "✅ Yes, we have" - Arrived on time
  - "❌ No, we haven't" - Did not arrive on time
* **Behavior:**
  - Shows notification with confirmation buttons
  - Tapping "Yes" increments streak and marks day as achieved
  - Tapping "No" marks day as missed
  - Auto-reschedules for next day
* **Reliability:** High (AlarmManager-based)

#### **Technical Implementation**

* All alarms use `android_alarm_manager_plus` for reliable background execution
* TTS uses `flutter_tts` plugin to speak messages automatically
* Alarms persist through app closure, phone restart, and Doze mode
* Each alarm callback runs in isolated background context
* Battery optimization set to "unrestricted" for consistent delivery
* When settings are updated, all previous alarms are cancelled and rescheduled with new times

---

### **4\. Check‑In Interaction**

* **Multiple notifications per morning** - every 8 minutes from wake-up until 6 minutes before leaving
* **Lock-screen accessible** - no need to unlock phone or open app
* **Quick action buttons:**
  * "✅ Going Well" - Morning is proceeding smoothly
  * "⚡ Running Tight" - Running behind schedule
* **Purpose:**
  - Provides regular awareness of time pressure throughout the morning
  - Creates sense of dialogue with the app
  - Future: Could adapt reminder tone/frequency based on status responses
* **Voice Component:** TTS speaks "Hey! How are things going this morning?" when each notification fires
* **No interaction required:** Notifications appear with voice regardless of user response

---

### **5\. Arrival Registration**

* **Trigger:** 2 minutes before arrival deadline
* **Notification:** "🎯 Have we arrived on time?"
* **Action buttons:**
  * "✅ Yes, we have" - Confirms on-time arrival
  * "❌ No, we haven't" - Confirms late arrival

#### **On-Time Arrival (Yes button)**

* Day marked as on-time
* Streak increments by 1
* Record saved to history
* Celebration voice message plays
* Reward progress checked and announced if close

#### **Late Arrival (No button)**

* Day marked as failed
* Streak resets to 0
* Record saved to history
* Neutral message plays: "We didn't make it today. Tomorrow we try again."

#### **Auto-Processing**

* If no response by deadline, system can auto-process based on configured rules
* Arrival confirmation integrates directly with streak tracking system

### **6\. Daily Outcome Logic**

#### **Success**

* Day marked as on‑time  
* Streak increments  
* Celebration voice \+ sound

Example:

"Yes\! Another day achieved. That’s a 4‑day streak\!"

#### **Failure**

* Day marked as failed  
* Streak resets (unless freeze is applied)  
* Neutral message

Example:

"We didn’t make it today. Tomorrow we try again."

---

### **7\. Streak System**

* One streak per user  
* Visible streak counter  
* Celebrations at milestones (3, 7, 14 days)  
* Home screen displays current streak as well as a monthly view of achieved/failed days for this month.

---

### **8\. Rewards System (Parent‑Driven)**

* Parent defines rewards with a required streak length  
* App references rewards in voice messages

Example:

"Only 2 more days to earn movie night with popcorn 🍿"

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

