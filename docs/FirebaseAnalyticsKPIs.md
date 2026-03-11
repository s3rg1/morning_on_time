# Firebase Analytics KPIs

## Overview

Three key metrics to measure whether the app is helping users arrive on time. All metrics are tracked via Firebase Analytics custom events.

---

## KPI 1: On-Time Rate

**Goal:** Measure the percentage of journeys that end with an on-time arrival.

**Event:** `journey_completed`

| Parameter | Type | Values |
|-----------|------|--------|
| `on_time` | bool | `true` / `false` |

**How to calculate:**

```
on_time_rate = count(journey_completed where on_time=true) / count(journey_completed) × 100
```

### Implementation

The event is logged from two code paths:

1. **User confirms arrival (foreground):**
   - Hook: `AppState.confirmArrival()` in `lib/providers/app_state.dart`
   - Covers both on-time and late manual confirmations
   - Logged after the `DayRecord` is saved

2. **Deadline passes without confirmation (background):**
   - Hook: `AlarmService.markMissionFailed()` in `lib/services/alarm_service.dart`
   - This runs in a background isolate where Firebase may not be initialized
   - **Deferred logging:** Write a pending event flag to SharedPreferences; flush to Firebase on next app open in `AppState.initialize()`

---

## KPI 2: Journey Completion Rate

**Goal:** Measure how many started journeys produce an outcome (arrival confirmed or deadline reached), vs. journeys that are abandoned mid-way.

**Events:** `journey_started` and `journey_completed`

| Event | Trigger |
|-------|---------|
| `journey_started` | Phase transitions from `idle` → `gettingReady` |
| `journey_completed` | User confirms arrival or deadline passes (same event as KPI 1) |

**How to calculate:**

```
completion_rate = count(journey_completed) / count(journey_started) × 100
```

A `journey_started` without a matching `journey_completed` on the same day indicates an abandoned journey (app killed, user skipped mid-morning, or forgot to tap "Arrived").

### Implementation

- Hook: `HomeScreen._startJourneyStateMonitoring()` timer callback in `lib/screens/home_screen.dart`
- The timer polls every 5 seconds and detects phase changes
- When `_lastJourneyPhase == idle` and the new phase is `gettingReady`, log `journey_started`
- `journey_completed` is already logged via KPI 1

---

## KPI 3: Average Streak Length

**Goal:** Measure how long users sustain consecutive on-time days before breaking the streak. Longer streaks indicate the app is building a lasting habit.

**Events:** `streak_updated` and `streak_broken`

| Event | Parameter | Type | Description |
|-------|-----------|------|-------------|
| `streak_updated` | `streak_length` | int | Current streak after an on-time arrival |
| `streak_broken` | `streak_length_before_reset` | int | Streak value just before it resets to 0 |

**How to calculate:**

```
avg_streak_at_break = avg(streak_length_before_reset) across all streak_broken events
```

The distribution of `streak_length_before_reset` reveals habit formation patterns: if most streaks break at 2–3 days the habit isn't forming; at 10+ the app is working.

### Implementation

1. **On-time arrival (streak grows):**
   - Hook: `AppState.confirmArrival(true)` in `lib/providers/app_state.dart`, after `calculateCurrentStreak()` completes
   - Log `streak_updated` with the new streak value

2. **Late arrival (streak resets):**
   - Hook: `AppState.confirmArrival(false)` in `lib/providers/app_state.dart`, before the streak is set to 0
   - Log `streak_broken` with the streak value before reset
   - For auto-failures in the background isolate: use the same deferred logging approach as KPI 1

---

## Architecture

A single `AnalyticsService` class in `lib/services/analytics_service.dart` will:

1. Wrap `FirebaseAnalytics.instance.logEvent()` for all custom events
2. Handle deferred events from background isolates (read/write pending events to SharedPreferences)
3. Flush pending events on app startup in `AppState.initialize()`

### Files to modify

| File | Change |
|------|--------|
| `lib/services/analytics_service.dart` | New file — analytics event logging and deferred event queue |
| `lib/providers/app_state.dart` | Log `journey_completed`, `streak_updated`, `streak_broken`; flush pending events on init |
| `lib/screens/home_screen.dart` | Log `journey_started` on phase transition |
| `lib/services/alarm_service.dart` | Write deferred `journey_completed(on_time=false)` and `streak_broken` to SharedPreferences |

---

## How to Measure the KPIs

### Step 1: Verify events are arriving

Before building any reports, confirm events are being logged correctly.

1. Open [Firebase Console](https://console.firebase.google.com/) → select your project
2. Go to **Analytics → Events**
3. You should see these custom events in the list:
   - `journey_started`
   - `journey_completed`
   - `streak_updated`
   - `streak_broken`
4. Click any event to see its count over time and parameter breakdowns

> **Note:** New custom events can take up to 24 hours to appear in the Firebase Console. Use **Analytics → DebugView** during development to see events in real time (requires enabling debug mode on the device).

To enable debug mode on Android:

```
adb shell setprop debug.firebase.analytics.app com.yourdomain.morning_on_time
```

To enable debug mode on iOS:

In Xcode, add `-FIRDebugEnabled` as a launch argument in your scheme.

---

### Step 2: Register event parameters as custom dimensions

By default, Firebase shows event counts but does not break down by parameter values. You need to register parameters as custom dimensions first.

1. Go to **Analytics → Events**
2. Click on `journey_completed` → click **Manage custom definitions** (or go to **Custom definitions** in the left menu)
3. Click **Create custom dimension** and register:
   - Parameter name: `on_time` — Scope: Event — Description: "Whether the journey ended on time"
4. Repeat for:
   - Parameter name: `streak_length` (from `streak_updated`) — Scope: Event — register as **Custom metric** (numeric)
   - Parameter name: `streak_length_before_reset` (from `streak_broken`) — Scope: Event — register as **Custom metric** (numeric)

> Custom dimensions/metrics take up to 24 hours to start populating after registration.

---

### Step 3: Measure KPI 1 — On-Time Rate

#### Quick check (Firebase Console)

1. Go to **Analytics → Events** → click `journey_completed`
2. In the parameter breakdown, look at the `on_time` dimension
3. You'll see the count split between `true` and `false`
4. On-time rate = `true count / total count × 100`

#### Trend over time (Google Analytics 4)

Firebase data flows automatically into GA4. Open [analytics.google.com](https://analytics.google.com/).

1. Go to **Explore** → click **Blank** to create a new exploration
2. Set exploration type to **Free form**
3. Add dimensions: **Event name**, **on_time** (your custom dimension)
4. Add metrics: **Event count**
5. Add a filter: Event name = `journey_completed`
6. Set Rows to `on_time`, Values to `Event count`
7. Change the date range to the last 7/30 days

To see the trend:
1. Change exploration type to **Free form** with a **Line chart**
2. Set Rows to **Date**, Columns to `on_time`, Values to `Event count`
3. This shows on-time vs. late counts per day on a line chart

---

### Step 4: Measure KPI 2 — Journey Completion Rate

#### Using Funnel Analysis (GA4)

1. Go to **Explore** → click **Blank**
2. Change exploration type to **Funnel exploration**
3. Add funnel steps:
   - Step 1: Event = `journey_started`
   - Step 2: Event = `journey_completed`
4. Set the time constraint to "within the same day" (or within 4 hours for tighter accuracy)
5. The funnel shows:
   - How many journeys started
   - How many reached completion
   - The drop-off percentage (= abandonment rate)

#### Simple count comparison (Firebase Console)

1. Go to **Analytics → Events**
2. Note the count for `journey_started` and `journey_completed` over the same period
3. Completion rate = `journey_completed count / journey_started count × 100`

---

### Step 5: Measure KPI 3 — Average Streak Length

#### View streak distribution (GA4)

1. Go to **Explore** → create a new **Free form** exploration
2. Add dimension: **Event name**
3. Add metric: `streak_length_before_reset` (your registered custom metric)
4. Add a filter: Event name = `streak_broken`
5. The average of `streak_length_before_reset` across all events = your average streak at break

#### Histogram of streak lengths (GA4)

1. In a Free form exploration, set Rows to `streak_length_before_reset`, Values to **Event count**
2. This shows how many streaks broke at each length (e.g., 15 streaks broke at 1 day, 8 at 3 days, 2 at 14 days)
3. This distribution is more informative than the average alone

#### Track streak growth over time

1. Create a Free form exploration
2. Filter: Event name = `streak_updated`
3. Rows: **Date**, Values: `streak_length` (average)
4. This shows whether your user base's active streaks are growing over time

---

### Step 6 (Optional): BigQuery for advanced analysis

If you need more flexibility (SQL queries, custom dashboards), link Firebase to BigQuery:

1. In Firebase Console → **Project Settings** → **Integrations** → **BigQuery**
2. Click **Link** — this exports raw events daily to BigQuery (free tier: 1TB queries/month)

Example queries:

```sql
-- Weekly on-time rate
SELECT
  DATE_TRUNC(PARSE_DATE('%Y%m%d', event_date), WEEK) AS week,
  COUNTIF(
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'on_time') = 'true'
  ) AS on_time_count,
  COUNT(*) AS total,
  ROUND(
    COUNTIF(
      (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'on_time') = 'true'
    ) * 100.0 / COUNT(*), 1
  ) AS on_time_rate
FROM `your_project.analytics_NNNNN.events_*`
WHERE event_name = 'journey_completed'
GROUP BY week
ORDER BY week;
```

```sql
-- Average streak length at break, by month
SELECT
  DATE_TRUNC(PARSE_DATE('%Y%m%d', event_date), MONTH) AS month,
  ROUND(AVG(
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'streak_length_before_reset')
  ), 1) AS avg_streak_at_break
FROM `your_project.analytics_NNNNN.events_*`
WHERE event_name = 'streak_broken'
GROUP BY month
ORDER BY month;
```

```sql
-- Journey completion rate by week
WITH starts AS (
  SELECT DATE_TRUNC(PARSE_DATE('%Y%m%d', event_date), WEEK) AS week, COUNT(*) AS cnt
  FROM `your_project.analytics_NNNNN.events_*`
  WHERE event_name = 'journey_started'
  GROUP BY week
),
completions AS (
  SELECT DATE_TRUNC(PARSE_DATE('%Y%m%d', event_date), WEEK) AS week, COUNT(*) AS cnt
  FROM `your_project.analytics_NNNNN.events_*`
  WHERE event_name = 'journey_completed'
  GROUP BY week
)
SELECT
  s.week,
  s.cnt AS started,
  IFNULL(c.cnt, 0) AS completed,
  ROUND(IFNULL(c.cnt, 0) * 100.0 / s.cnt, 1) AS completion_rate
FROM starts s
LEFT JOIN completions c USING (week)
ORDER BY s.week;
```

You can visualize BigQuery results in **Looker Studio** (free) by connecting it as a data source and building a dashboard.

---

### Summary: Where to find each KPI

| KPI | Quick check | Trend analysis | Advanced |
|-----|------------|----------------|----------|
| On-time rate | Firebase Console → Events → `journey_completed` → `on_time` breakdown | GA4 Exploration: line chart by date with `on_time` split | BigQuery weekly on-time rate query |
| Journey completion rate | Compare `journey_started` vs `journey_completed` counts in Firebase Events | GA4 Funnel Exploration: `journey_started` → `journey_completed` | BigQuery weekly completion rate query |
| Average streak length | GA4 Exploration: average of `streak_length_before_reset` on `streak_broken` events | GA4 Exploration: average `streak_length` on `streak_updated` by date | BigQuery monthly avg streak query |
