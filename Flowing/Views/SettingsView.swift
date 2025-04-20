//
//  SettingsView.swift
//  Flowing
//
//  Created by Saúl González on 22/05/24.
//

import SwiftUI
import SwiftData
import OctoKit
import UserNotifications
import UserNotificationsUI

struct SettingsView: View {
    //Environment Variables
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var timeVariables: freeTimesVariables
    
    @FocusState private var isFieldFocused: Bool
    
    //State Variables
    @Binding var personalization: personalizationVariables
    @Binding var objects: taskObjectVariables
    @State var notify = false
    @State private var defaultColor: Color = .primary
    @State var api: String = ""
    @State private var isKeyboardVisible = false // Track keyboard visibility
    
    @State var deleted = false
    @State var buttonOpacity = 1.0
    @State var buttonProgress = 0.0
    @State var hasPressed = false
    
    @State var beforeTask = "5"
    @State private var showSettingsAlert = false
    @State private var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined
    
    //Fetch Request
    @Query() private var settingsItems: [settingsItem]
    @Query(sort: [SortDescriptor(\taskItem.start), SortDescriptor(\taskItem.end), SortDescriptor(\taskItem.name)]) var taskItems: [taskItem]
    
    var body: some View {
        ScrollView {
            VStack {
                // MARK: - Personalization Section
                Group {
                    Text("Personalization")
                        .fontDesign(.rounded)
                        .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                        .font(.title)
                        .opacity(0.5)
                        .fontWeight(.heavy)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                .blur(radius: phase.isIdentity ? 0 : 10)
                        }
                        .frame(height: 40)
                    
                    // Toggle for custom home icon
                    Toggle(isOn: $personalization.customHome.animation(.bouncy)) {
                        Text("Home icon as active task")
                            .fontDesign(.rounded)
                            .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .onChange(of: personalization.customHome) {
                        settingsItems.first?.customHome = personalization.customHome
                        try? context.save()
                        timeVariables.update.toggle()
                    }
                    .frame(height: 60)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .scaleEffect(phase.isIdentity ? 1 : 0.75)
                            .blur(radius: phase.isIdentity ? 0 : 10)
                    }
                    
                    // Toggle for custom main color
                    Toggle(isOn: $personalization.customColor.animation(.bouncy)) {
                        Text("Custom main color")
                            .fontDesign(.rounded)
                            .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .onChange(of: personalization.customColor) {
                        settingsItems.first?.customMainColor = personalization.customColor
                        try? context.save()
                    }
                    .frame(height: 60)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .scaleEffect(phase.isIdentity ? 1 : 0.75)
                            .blur(radius: phase.isIdentity ? 0 : 10)
                    }
                    
                    // Color picker for main color
                    if personalization.customColor {
                        ColorPicker(selection: $personalization.mainColor.animation(.bouncy), supportsOpacity: false) {
                            Text("Main color")
                                .fontDesign(.rounded)
                                .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .onChange(of: personalization.mainColor) {
                            settingsItems.first?.mainColor = personalization.mainColor.toHex()!
                            try? context.save()
                        }
                        .frame(height: 60)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                .blur(radius: phase.isIdentity ? 0 : 10)
                        }
                    }
                    
                    // Toggle for custom text color
                    Toggle(isOn: $personalization.customTextColor.animation(.bouncy)) {
                        Text("Custom text color")
                            .fontDesign(.rounded)
                            .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .onChange(of: personalization.customTextColor) {
                        settingsItems.first?.customTextColor = personalization.customTextColor
                        try? context.save()
                    }
                    .frame(height: 60)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .scaleEffect(phase.isIdentity ? 1 : 0.75)
                            .blur(radius: phase.isIdentity ? 0 : 10)
                    }
                    
                    // Color picker for text color
                    if personalization.customTextColor {
                        ColorPicker(selection: $personalization.textColor.animation(.bouncy), supportsOpacity: false) {
                            Text("Text color")
                                .fontDesign(.rounded)
                                .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .onChange(of: personalization.textColor) {
                            settingsItems.first?.textColor = personalization.textColor.toHex()!
                            try? context.save()
                        }
                        .frame(height: 60)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                .blur(radius: phase.isIdentity ? 0 : 10)
                        }
                    }
                }
                
                // MARK: - Visibility Section
                Group {
                    Text("Visibility")
                        .fontDesign(.rounded)
                        .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                        .font(.title)
                        .opacity(0.5)
                        .fontWeight(.heavy)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                .blur(radius: phase.isIdentity ? 0 : 10)
                        }
                        .frame(height: 40)
                    
                    // Toggle for showing free times
                    Toggle(isOn: $personalization.showFreeTimes) {
                        Text("Show free times")
                            .fontDesign(.rounded)
                            .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .onChange(of: personalization.showFreeTimes) {
                        settingsItems.first?.showFreeTimes = personalization.showFreeTimes
                        try? context.save()
                        timeVariables.update.toggle()
                    }
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .scaleEffect(phase.isIdentity ? 1 : 0.75)
                            .blur(radius: phase.isIdentity ? 0 : 10)
                    }
                    .frame(height: 60)
                    
                    // Toggle for showing specific tasks
                    Toggle(isOn: $personalization.allTasks.animation(.bouncy)) {
                        Text("Show specific tasks")
                            .fontDesign(.rounded)
                            .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .onChange(of: personalization.allTasks) {
                        timeVariables.update.toggle()
                    }
                    .onChange(of: objects.days) {
                        timeVariables.update.toggle()
                    }
                    .frame(height: 60)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .scaleEffect(phase.isIdentity ? 1 : 0.75)
                            .blur(radius: phase.isIdentity ? 0 : 10)
                    }
                    
                    // Day selector for specific tasks
                    if personalization.allTasks {
                        DaySelector(days: $objects.days, color: personalization.customTextColor ? $personalization.textColor : $defaultColor, size: 39.5)
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                    .blur(radius: phase.isIdentity ? 0 : 10)
                            }
                    }
                    
                    // Toggle for notifications
                    Toggle(isOn: $personalization.notify.animation(.bouncy)) {
                        Text("Enable notifications")
                            .fontDesign(.rounded)
                            .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .onChange(of: personalization.notify) {
                        if personalization.notify {
                            // If user is trying to enable notifications, check permissions
                            UNUserNotificationCenter.current().getNotificationSettings { settings in
                                DispatchQueue.main.async {
                                    switch settings.authorizationStatus {
                                    case .authorized, .provisional:
                                        // We have permission, enable and schedule
                                        settingsItems.first?.notify = true
                                        try? context.save()
                                        setupNotificationsForUpcomingTasks(context, before: Int(beforeTask) ?? 5)
                                    case .denied:
                                        // We don't have permission, show settings alert
                                        personalization.notify = false
                                        showSettingsAlert = true
                                    case .notDetermined:
                                        // First time asking, request permission
                                        requestNotificationPermission()
                                    default:
                                        personalization.notify = false
                                    }
                                }
                            }
                        } else {
                            // User disabled notifications, cancel all scheduled notifications
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            settingsItems.first?.notify = false
                            try? context.save()
                        }
                    }
                    .frame(height: 60)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .scaleEffect(phase.isIdentity ? 1 : 0.75)
                            .blur(radius: phase.isIdentity ? 0 : 10)
                    }
                    
                    // Notification minutes setting
                    if personalization.notify {
                        HStack {
                            Text("Notification time")
                                .fontDesign(.rounded)
                                .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            TextField("5", text: $beforeTask)
                                .keyboardType(.numberPad)
                                .frame(width: 50, height: 28)
                                .multilineTextAlignment(.center)
                                .background(Color.gray.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .limitInputLength(value: $beforeTask, length: 2)
                                .fontWeight(.bold)
                            
                            Text("min")
                                .fontDesign(.rounded)
                                .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                                .font(.title3)
                        }
                        .onChange(of: beforeTask) { _, newValue in
                            if !newValue.isEmpty {
                                // Auto-reschedule when the value changes and is valid
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    rescheduleAllNotifications()
                                }
                            }
                        }
                        .frame(height: 60)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                .blur(radius: phase.isIdentity ? 0 : 10)
                        }
                    }
                }
                
                // MARK: - GitHub Section
                Group {
                    Text("GitHub")
                        .fontDesign(.rounded)
                        .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                        .font(.title)
                        .opacity(0.5)
                        .fontWeight(.heavy)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                .blur(radius: phase.isIdentity ? 0 : 10)
                        }
                        .frame(height: 40)
                    
                    // Toggle for showing GitHub settings
                    Toggle(isOn: $personalization.githubEnabled.animation(.bouncy)) {
                        Text("Enable GitHub Connection")
                            .fontDesign(.rounded)
                            .foregroundStyle(personalization.customTextColor ? personalization.textColor : Color.primary)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .onChange(of: personalization.githubEnabled) {
                        settingsItems.first?.githubEnabled = personalization.githubEnabled
                        try? context.save()
                        
                        timeVariables.updateGitHub.toggle()
                    }
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .scaleEffect(phase.isIdentity ? 1 : 0.75)
                            .blur(radius: phase.isIdentity ? 0 : 10)
                    }
                    .frame(height: 60)
                    
                    // Day selector for specific tasks
                    if personalization.githubEnabled {
                        
                        if personalization.githubApiKey == "" {
                            
                            SecureField("ApiKey", text: $api)
                                .font(.title)
                                .fontDesign(.rounded)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .padding(5)
                                .background(Color.gray.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                                .padding(.bottom, 13)
                                .animation(.easeOut, value: isFieldFocused)
                                .keyboardType(.default)
                                .focused($isFieldFocused) // This connects the field to our focus state
                                .onChange(of: isFieldFocused) { wasFocused, isFocused in
                                   
                                    if isFocused {
                                        withAnimation() {
                                            isKeyboardVisible = true
                                        }
                                    } else {
                                            withAnimation() {
                                                isKeyboardVisible = false
                                            }
                                        
                                    }
                                }
                                .onSubmit {
                                    personalization.githubApiKey = api
                                    settingsItems.first?.githubApiKey = personalization.githubApiKey
                                    try? context.save()
                                    timeVariables.updateGitHub.toggle()
                                    isFieldFocused = false // Dismiss the keyboard by removing focus
                                    withAnimation() {
                                        isKeyboardVisible = false
                                    }
                                }
                                .scrollTransition { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0)
                                        .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                        .blur(radius: phase.isIdentity ? 0 : 10)
                                }
                        } else {
                            ZStack {
                                ZStack(alignment: .leading) {
                                    Rectangle().foregroundStyle(Color.red)
                                        .frame(width: buttonProgress, height: 60)
                                    
                                    Rectangle().foregroundStyle(Color.red)
                                        .frame(width: 350, height: 60)
                                        .opacity(buttonOpacity)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                                
                                Text("DELETE API KEY")
                                    .font(.title2)
                                    .fontDesign(.rounded)
                                    .fontWeight(.heavy)
                                    .frame(width: 330, height: 60)
                                    .background(RoundedRectangle(cornerRadius: 12.5).foregroundStyle(Color.red.opacity(0.01)))
                                    .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                                    .sensoryFeedback(.impact, trigger: deleted)
                                    .onLongPressGesture(minimumDuration: 2, maximumDistance: 20, pressing: { pressing in
                                        self.hasPressed = pressing
                                        if pressing {
                                            withAnimation {
                                                buttonOpacity = 0.5
                                            }
                                            withAnimation(.easeOut(duration: 2)) {
                                                buttonProgress = 330
                                            }
                                        }
                                        if !pressing {
                                            withAnimation(.easeInOut) {
                                                buttonOpacity = 1
                                                buttonProgress = 0
                                            }
                                        }
                                    }, perform: {
                                        withAnimation(.bouncy){
                                            deleted = true
                                            api = ""
                                            personalization.githubApiKey = api
                                            settingsItems.first?.githubApiKey = personalization.githubApiKey
                                            try? context.save()
                                            
                                            timeVariables.updateGitHub.toggle()
                                        }
                                    })
                                    
                                    .padding(.top, 7)
                                    .padding(.bottom, 13)
                            }
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                    .blur(radius: phase.isIdentity ? 0 : 10)
                            }
                        }
                            
                    }
                }
            }
        }
        .padding(.horizontal)
        .scrollClipDisabled()
        .scrollIndicators(.hidden)
        .frame(height: isKeyboardVisible ? UIScreen.screenHeight+275 : UIScreen.screenHeight-150)
        //.frame(height: isKeyboardVisible ? UIScreen.screenHeight+275 : UIScreen.screenHeight-150)
        .offset(y: isKeyboardVisible ? 30 : 50)
        .dismissKeyboardOnTap() // Dismiss keyboard when tapping outside input fields
        .onAppear {
            checkNotificationStatus()
        }
        .alert(isPresented: $showSettingsAlert) {
            Alert(
                title: Text("Notifications Disabled"),
                message: Text("To enable notifications, you need to allow them in Settings."),
                primaryButton: .default(Text("Settings")) {
                    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(appSettings)
                    }
                },
                secondaryButton: .cancel() {
                    personalization.notify = false
                    settingsItems.first?.notify = false
                    try? context.save()
                }
            )
        }
        
    }
    
    // Hide keyboard when tapping outside the input field
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        isKeyboardVisible = false
    }
    
    // Check if notifications are already authorized
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationPermissionStatus = settings.authorizationStatus
                
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    personalization.notify = settingsItems.first?.notify ?? false
                case .denied, .notDetermined:
                    personalization.notify = false
                    if let settings = settingsItems.first, settings.notify {
                        settings.notify = false
                        try? context.save()
                    }
                @unknown default:
                    personalization.notify = false
                }
            }
        }
    }
    
    // Request notification permission
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            DispatchQueue.main.async {
                if success {
                    personalization.notify = true
                    settingsItems.first?.notify = true
                    try? context.save()
                    
                    // Schedule notifications for all tasks with current time setting
                    let minutesBefore = Int(beforeTask) ?? 5
                    setupNotificationsForUpcomingTasks(context, before: minutesBefore)
                } else {
                    // User denied permission during the request
                    personalization.notify = false
                    settingsItems.first?.notify = false
                    try? context.save()
                }
                
                // Update permission status
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    DispatchQueue.main.async {
                        notificationPermissionStatus = settings.authorizationStatus
                    }
                }
            }
        }
    }
    
    // Reschedule all notifications with the current time setting
    private func rescheduleAllNotifications() {
        guard personalization.notify else { return }
        
        let minutesBefore = Int(beforeTask) ?? 5
        
        // First cancel all existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Update the settings
        if let settings = settingsItems.first {
            settings.notify = true
            try? context.save()
        }
        
        // Schedule notifications for all tasks
        setupNotificationsForUpcomingTasks(context, before: minutesBefore)
    }
}
