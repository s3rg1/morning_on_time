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
6. Success arrival confirmation by parent through both the notification or home screen.
7. At arrival time, if parent didn't confirm success, it's a failure. 
7. Success or failure is recorded  
8. Streak and reward progress updated

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

The app schedules **5 different types of alarms** when settings are saved or updated.

The morning plan begins at wake-up time and finished at arrival time. The trip to school starts at leave time and finishes at arrival time.

See below the diffent types of alarms:

#### **3.1. Wake-Up Alarm (ID: 1)**

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

#### **3.2. Checkpoint Alarms (IDs: 100-119)**

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

#### **3.3. Leave Home Soon Alarm (ID: 3)**

* **Trigger:** 5 minutes before leave home time
* **Voice Message (TTS):** "In five minutes we must leave home, hurry up!!"
* **Notification:** "🏃 Leave Home Soon!"
* **Behavior:**
  - The alarm is triggered 5 minutes before the time to leave
  - Creates sense of urgency as departure time approaches
  - Plays TTS message automatically
* **Reliability:** High (AlarmManager-based)

#### **3.4. Leave Home Alarm (ID: 4)**

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

#### **3.5. Pre Arrival Check Alarm (ID: 5)**

* **Trigger:** Two minutes before the arrival deadline
* **Notification:** "🎯 Have we arrived on time?"
* **Message:** "Tap to confirm your arrival status"
* **Action Buttons:**
  - "✅ Yes, we have" - Arrived on time.
* **Behavior:**
  - Shows notification with confirmation buttons
  - Tapping "Yes" increments streak and marks day as achieved. Also stops the countdown timer and disables Arrival Alarm since it's not needed
* **Reliability:** High (AlarmManager-based)

#### **3.6. Arrival Alarm (ID: 6)**

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
* When time settings are updated (wake up, leave at and arrival time), all previous alarms are cancelled and rescheduled with new times

---


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

