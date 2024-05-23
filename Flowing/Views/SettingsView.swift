//
//  SettingsView.swift
//  Flowing
//
//  Created by Saúl González on 22/05/24.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    //Environment Variables
    @Environment(\.modelContext) private var context
    @EnvironmentObject var timeVariables: freeTimesVariables
    
    //State Variables
    @Binding var personalization: personalizationVariables
    @Binding var objects: taskObjectVariables
    @State private var defaultColor: Color = .primary
    
    //Fetch Request
    @Query() private var settingsItems: [settingsItem]
    
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
                        Text("Home icon is active task")
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
                }
            }
        }
        .padding(.horizontal)
        .scrollClipDisabled()
        .scrollIndicators(.hidden)
        .frame(height: UIScreen.screenHeight-150)
        .offset(y: 50)
    }
}

