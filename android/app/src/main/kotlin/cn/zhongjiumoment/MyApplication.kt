package cn.zhongjiumoment

import android.app.Application
import com.umeng.commonsdk.UMConfigure

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // 预初始化：不采集设备信息，不上报数据。
        // 正式初始化（UmengCommonSdk.initCommon）由 Dart 层在用户同意隐私政策后调用，
        // 此处禁止调用 UMConfigure.init，否则未同意时就会采集。
        UMConfigure.preInit(this, "6af189d16545637cd6451016", "Umeng")
    }
}
