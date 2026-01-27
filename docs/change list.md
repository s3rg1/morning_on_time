1. I can't come back to the home screen when setting up the morning routine. Add a back or Cancel button.
2. I want you to persist locally the morning routine. When the user changes the time and press start the journery, times should be stored locally and used by the app. If I come back to the setup screen, I expedct to see the previously configured times.
Apply some changes to the home screen. Keep the days streak frame but simplify today's mission just adding below "Arrive at school on time" text the schedule shown on the bottom of the screen (planned wake up time, leave home, arrive by). 
Let's update the setup screen. Apply these constraints: Leave Home Time must be after Wake-up time. Latest Arrival Time must be after Leave Home Time. If the user changes the time invalidating others, the app will fix them automatically applying the constraints.
Is the app ready for i18n? If not, prepare it to be translated to multiple language. Additionally, add Spanish language support translating the copies to this language and ensure the app uses one language or another based on the device language. Use English as fallback


Add text to speech support because I want the app to talk to the user. I want the app to 


The "Going well" button and "Running Tights" are the buttons that the notifications must include for the user to state how things are going.

When the user updates the schedule setup, the previously planned notifications are removed and planned again based to the new schedule.
First notification is scheduled on Wake up time saying current message.
Every 8 minutes until there is less than 6 minutes to Leave home, schedule the Check-In Alarm. 
5 minutes before Leave home time there is a 3rd notification triggered called Leave Home Soon Alarm that says "In five minutes we must leave home, hurry up!!"
When Leave home time, there is a 4rd notification triggered called Leave Home Alarm that says "We leave home now or we'll be late."
2 minutes before Arrival by time, a 5th notification asks "Have we arrived on time?". This notification must have two buttons: "Yes, we have" or "No, we haven't". When the user taps on Yes, the streak counter adds +1 and register that day as achieved.


DONE! the app is localized to both Spain and English but text to speech is alwas in English. Localize also the speech text and ensure the TTS talks using the device configuration



