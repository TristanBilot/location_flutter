import UIKit
import Flutter
import Firebase
import FirebaseMessaging
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    // Firebase notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    GMSServices.provideAPIKey("AIzaSyBPrx_ld7IslbiyV1HtjDFytXKwU96pKu8")
    var flutter_native_splash = 1
    UIApplication.shared.isStatusBarHidden = false

    GeneratedPluginRegistrant.register(with: self)
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      Auth.auth().setAPNSToken(deviceToken, type: .prod)
//    print(deviceToken.reduce("", {$0 + String(format: "%02X", $1)}))
      
      Messaging.messaging().apnsToken = deviceToken
      super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(_ application: UIApplication,
      didReceiveRemoteNotification notification: [AnyHashable : Any],
      fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    Messaging.messaging().appDidReceiveMessage(notification)
      if Auth.auth().canHandleNotification(notification) {
        completionHandler(.noData)
        return
      }
  }

  override func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
      if Auth.auth().canHandle(url) {
        return true
      }
      return false;
    }
}
