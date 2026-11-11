
# 友盟 SDK 混淆规则
-keep class com.umeng.** {*;}
-keep class com.uc.** {*;}
-keepclassmembers class * {
    public <init> (org.json.JSONObject);
}
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# HMS loads these vendor-only classes conditionally on supported Huawei devices.
-dontwarn com.huawei.android.os.BuildEx$VERSION
-dontwarn com.huawei.hianalytics.process.**
-dontwarn com.huawei.hianalytics.util.HiAnalyticTools
-dontwarn com.huawei.hms.availableupdate.UpdateAdapterMgr
-dontwarn com.huawei.libcore.io.**
