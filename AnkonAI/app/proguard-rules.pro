# Add project specific ProGuard rules here.
# You can control the optimization level with -optimizations
# For TFLite
-keep class org.tensorflow.** { *; }
-keep class org.tensorflow.lite.** { *; }

# For Room
-keep class androidx.room.** { *; }
-keep class * extends androidx.room.RoomDatabase

# For Hilt
-keep class dagger.hilt.** { *; }
-keep class javax.inject.** { *; }