import UIKit
import Flutter
import Firebase
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyBPrx_ld7IslbiyV1HtjDFytXKwU96pKu8")
    GeneratedPluginRegistrant.register(with: self)

    // Firebase notifications
    if #available(iOS 10.0, *) {
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
  }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
