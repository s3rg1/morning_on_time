# Monthly History View

*Part of the [Morning On Time PRD](MorningOnTime.md) — Section 9 of Functional Requirements*

---

A calendar-based reporting feature that displays the user's historical performance across the month, showing which days were successful, failed, or skipped.

#### **Purpose**

* Provide visual overview of monthly on-time performance
* Allow parents and children to review progress over time
* Identify patterns (e.g., certain days consistently missed)
* Celebrate achievements with visual success markers
* Secondary/reporting feature - not part of daily workflow

#### **Access Method**

**Location:** App bar, top-right area of home screen

**Icon:** 📅 Calendar icon

**Position:** Between the hourglass icon (test button) and settings gear icon

**Interaction:** Single tap opens full-screen monthly calendar view

**Rationale:**
* Standard placement for secondary/reporting features
* Keeps home screen focused on daily mission and motivation
* Always accessible but not intrusive
* Matches existing app bar pattern (3 icons: test, calendar, settings)

#### **Calendar View Layout**

When opened, displays a full-screen monthly calendar with:

**Header:**
* Current month and year (e.g., "February 2026")
* Navigation arrows to switch months (← →)
* Close button (X) to return to home screen

**Calendar Grid:**
* Standard 7-column layout (Sun-Sat or Mon-Sun based on locale)
* Current month's dates displayed prominently
* Previous/next month dates shown in muted colors for context

**Date Markers:**

Each date is visually coded based on journey outcome:

| Status | Visual Indicator | Meaning |
|--------|-----------------|---------|
| Success | ✅ Green checkmark or filled circle | Arrived on time that day |
| Failure | ⌛ Red X or hollow circle | Missed deadline that day |
| Skipped | 🚫 Gray dash or strikethrough | Manually skipped via settings |
| No Journey | Empty/default | Inactive day (weekend) or no alarm scheduled |
| Future | Muted/grayed out | Date hasn't occurred yet |
| Today | Highlighted border | Current day (outcome pending or just occurred) |

**Tap Interaction (Optional):**
* Tapping a date shows detailed information in a tooltip/modal:
  - Date: "Monday, Feb 9, 2026"
  - Outcome: "✅ Success - arrived on time!"
  - Times: "Wake: 6:30 AM | Left: 7:45 AM | Arrived: 7:58 AM"
  - Streak at that time: "Streak was 5 days"

#### **Monthly Statistics (Optional Enhancement)**

Display summary metrics at bottom of calendar:

```
February 2026 Summary:
✅ On-time days: 15
⌛ Late days: 2
📊 Success rate: 88%
🔥 Best streak: 7 days
```

#### **Data Source**

* Reads from locally stored daily results (SharedPreferences or SQLite)
* Each successful/failed journey writes a date-stamped record
* Skipped dates read from settings `skipDates` set
* Active days pattern determines which dates have "No Journey" status

#### **Edge Cases**

1. **First Launch (No History):**
   - Shows current month with all dates empty
   - Message: "Start your journey to see your progress!"

2. **Partial Month:**
   - Only shows outcomes for dates that have occurred
   - Future dates remain muted/empty

3. **Month Navigation:**
   - Can view past months to see historical data
   - Future months show empty calendar with scheduled active days indicated

4. **Test Results:**
   - Test journey results appear in calendar like real results
   - Consider indicator to differentiate test days (e.g., 🧪 badge)

#### **Design Principles**

* **Secondary Feature:** Not needed for daily app function
* **Quick Access:** One tap from home screen (app bar icon)
* **Visual Clarity:** Color-coded status makes month performance obvious at a glance
* **Minimal Home Screen Impact:** Icon in app bar doesn't compete with motivational content
* **Historical Context:** Helps users understand long-term patterns and improvement

#### **Technical Implementation**

* **Storage:** Daily results stored with date keys (YYYY-MM-DD format)
* **Calendar Widget:** Use Flutter `table_calendar` package or custom grid
* **State Management:** Provider pattern to reactively update after each journey
* **Performance:** Load only current month's data initially; fetch other months on demand
* **Persistence:** Results survive app restarts and updates

#### **Future Enhancements**

1. **Export/Share:** Export monthly report as image to share with family
2. **Trends:** Multi-month view showing success rate over time (line chart)
3. **Goals:** Set monthly on-time target (e.g., "18/20 school days")
4. **Notes:** Add optional notes to dates (e.g., "Sick day" or "Early dismissal")
5. **Filtering:** Toggle to show only school days vs all days
