//
//  FlowingApp.swift
//  Flowing
//
//  Created by Saúl González on 9/01/24.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct FlowingApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  let container: ModelContainer

  init() {
    let schema = Schema(
      [ taskItem.self,
        toDoItem.self,
        progressiveItem.self,
        settingsItem.self ]
    )

    let config = ModelConfiguration(
      schema: schema,
      cloudKitDatabase: .automatic
    )

    do {
      container = try ModelContainer(
        for: schema,
        configurations: [config]
      )
    } catch {
      fatalError("Unresolved error initializing ModelContainer: \(error)")
    }
  }

  var body: some Scene {
    WindowGroup {
      MainView()
    }
    // hand your container into SwiftUI
    .modelContainer(container)
  }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        // Check if this is the first launch
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        
        if isFirstLaunch {
            // Mark that the app has been launched
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            
            // Request notification permissions
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    print("Notification permission granted")
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                        
                        // Auto-enable notifications in app settings
                        if let modelContainer = try? ModelContainer(for: taskItem.self, settingsItem.self, toDoItem.self, progressiveItem.self) {
                            let context = modelContainer.mainContext
                            
                            // Get the settings and enable notifications
                            let fetchDescriptor = FetchDescriptor<settingsItem>()
                            if let settings = try? context.fetch(fetchDescriptor).first {
                                settings.notify = true
                                try? context.save()
                                
                                // Schedule notifications for tasks
                                setupNotificationsForUpcomingTasks(context)
                            }
                        }
                    }
                } else {
                    print("Permission for push notifications denied.")
                }
            }
        } else {
            // Normal notification permission check for subsequent launches
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication){
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        // Add this code to reschedule notifications when app becomes active
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Get access to the model context
            if let modelContainer = try? ModelContainer(for: taskItem.self, settingsItem.self, toDoItem.self, progressiveItem.self) {
                let context = modelContainer.mainContext
                // Refresh notifications for upcoming tasks
                setupNotificationsForUpcomingTasks(context)
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(token)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Received notification while app is in foreground: \(notification.request.content.title)")
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Received notification response: \(response.notification.request.content.title)")
        
        // Add this code to reschedule notifications after a notification is tapped
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let modelContainer = try? ModelContainer(for: taskItem.self, settingsItem.self, toDoItem.self, progressiveItem.self) {
                let context = modelContainer.mainContext
                setupNotificationsForUpcomingTasks(context)
            }
        }
        
        completionHandler()
    }
}
