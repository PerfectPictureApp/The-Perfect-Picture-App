import UIKit

@UIApplicationMain
@objc class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let welcomeVC = WelcomeViewController()
        window?.rootViewController = welcomeVC
        window?.makeKeyAndVisible()
        print("AppDelegate: Launched with WelcomeViewController!")
        return true
    }
}
