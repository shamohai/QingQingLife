package cn.zhongjiubatch

import android.app.Application
import com.umeng.commonsdk.UMConfigure

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // 预初始化：不采集设备信息，不上报数据，耗时极少
        UMConfigure.preInit(this, "6af189d16545637cd6451016", "Umeng")

        // 友盟统计与推送正式初始化
        UMConfigure.init(this, "6af189d16545637cd6451016", "Umeng", UMConfigure.DEVICE_TYPE_PHONE, "b297691c5a246570b611c62695b42e8f")
    }
}
