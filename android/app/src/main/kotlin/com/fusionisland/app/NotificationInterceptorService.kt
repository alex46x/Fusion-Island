package com.fusionisland.app

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class NotificationInterceptorService : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        if (sbn == null) return
        val packageName = sbn.packageName
        val title = sbn.notification.extras.getCharSequence("android.title")?.toString() ?: ""
        val text = sbn.notification.extras.getCharSequence("android.text")?.toString() ?: ""

        // Stream notification details to Flutter over EventChannel
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        super.onNotificationRemoved(sbn)
    }
}
