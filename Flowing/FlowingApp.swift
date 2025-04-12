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
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(for: [taskItem.self, toDoItem.self, progressiveItem.self, settingsItem.self])
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Permission for push notifications denied.")
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
