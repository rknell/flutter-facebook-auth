import UIKit
import Flutter
import FBSDKCoreKit // <--- ADD THIS LINE (first you need run  pod install)
import TwitterKit // <--- FOR LOGIN WITH TWITTER ADD THIS LINE (first you need run  pod install)


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)// <--- ADD THIS LINE
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    

    // <--- OVERRIDE THIS METHOD WITH THIS CODE
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
       
        if url.scheme != nil {
            let facebookAppId: String? = Bundle.main.object(forInfoDictionaryKey: "FacebookAppID") as? String
            if facebookAppId != nil && url.scheme!.hasPrefix("fb\(facebookAppId!)") && url.host ==  "authorize" {
                 print("is login by facebook")
                 return ApplicationDelegate.shared.application(app, open: url, options: options)
            } else if url.scheme!.contains("twitter") { // for login by twitter
               print("is login by twitter")
               return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
            }
        }
        
        return false

    }
}
