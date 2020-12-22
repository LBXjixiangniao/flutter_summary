import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let router = PlatformRouterImp.init();
        var flutterEngine:FlutterEngine!;
        FlutterBoostPlugin.sharedInstance().startFlutter(with: router, onStart: { (engine) in
            flutterEngine = engine;
        });
        GeneratedPluginRegistrant.register(with: self)
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        let viewController = FlutterViewController.init(engine: flutterEngine, nibName: nil, bundle: nil);
        let navi = UINavigationController.init(rootViewController: viewController)
        navi.setNavigationBarHidden(true, animated: false)
        self.window.rootViewController = navi
        self.window.makeKeyAndVisible()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
