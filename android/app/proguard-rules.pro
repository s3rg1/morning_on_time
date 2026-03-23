## flutter_local_notifications — prevent R8 from stripping Gson type info
-keep class com.dexterous.** { *; }

## Gson TypeToken — R8 strips generic signatures needed at runtime
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
