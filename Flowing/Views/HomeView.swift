//
//  HomeView.swift
//  Flowing
//
//  Created by Saúl González on 20/05/24.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    //Environment Variables
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var context
    
    //State Variables
    @Binding var objects: taskObjectVariables
    @Binding var personalization: personalizationVariables
    @Binding var creation: creatingVariables
    
    //Fetch Request
    @Query(sort: [SortDescriptor(\taskItem.start), SortDescriptor(\taskItem.end), SortDescriptor(\taskItem.name)]) var taskItems: [taskItem]
    
    //Other Variables
    @State private var sheetContentHeight = CGFloat(0)
    @State private var buttonSize = 1.0
    @State private var buttonOpacity = 1.0
    
    //Environment Object
    @EnvironmentObject var timeVariables: freeTimesVariables
    
    //Helper Functions
    func updateAllTasks() {
        timeVariables.tasks = taskItems
        timeVariables.freeTimes = getFreeTimes(taskItems, days: objects.days, allTasks: personalization.allTasks)
        
        for free in timeVariables.freeTimes {
            timeVariables.tasks.append(taskItem(name: "fR33t1M3", color: "FFFFFF", desc: "u93fgbreiuwrg3", symbol: "clock", start: free.0, end: free.1, done: false, days: "1111111"))
        }
        
        timeVariables.tasks = timeVariables.tasks.sorted { $0.end < $1.end }
        timeVariables.tasks = timeVariables.tasks.sorted { $0.start < $1.start }

        withAnimation() {
            if let firstMatchingItem = taskItems.first(where: { (isToday($0.days) && checkCurrentTime(start: $0.start, end: $0.end)) || ($0.days == "0000000" && checkCurrentTime(start: $0.start, end: $0.end))}) {
                personalization.customIcon = firstMatchingItem.symbol
            } else {
                personalization.customIcon = "clock"
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            ForEach(timeVariables.tasks) { item in
                // Shows the tasks depending on the option to show specific t
                if personalization.allTasks ? isIncluded(item.days, objects.days) : isToday(item.days) {
                    if item.name == "fR33t1M3" && item.desc == "u93fgbreiuwrg3" {
                        if checkCurrentTime(start: item.start, end: item.end) && personalization.showFreeTimes {
                            // Display Free Times
                            Image(systemName: "clock")
                                .font(.title)
                                .fontWeight(.heavy)
                                .frame(width: 358, height: 60)
                                .foregroundStyle(personalization.customColor ? personalization.mainColor : Color.primary)
                                .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(personalization.customColor ? personalization.mainColor.opacity(0.3) : Color.primary.opacity(0.3)))
                                .padding(.horizontal)
                                .padding(.bottom, 5)
                                .scrollTransition { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0)
                                        .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                        .blur(radius: phase.isIdentity ? 0 : 10)
                                }
                        }
                    } else {
                        // Display Task Items
                        TaskObj(textColor: personalization.customTextColor ? personalization.textColor : Color.primary, item: item, context: context)
                            .clipped(antialiased: true)
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                    .blur(radius: phase.isIdentity ? 0 : 10)
                            }
                    }
                }
            }
            
            // Button to add a task
            Image(systemName: "plus")
                .font(.title)
                .scaleEffect(buttonSize)
                .fontWeight(.black)
                .frame(width: 358, height: 60)
                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(personalization.customColor ? personalization.mainColor.opacity(buttonOpacity) : Color.primary.opacity(buttonOpacity)))
                .scaleEffect(buttonSize)
                .padding()
                .sensoryFeedback(.impact(intensity: creation.creatingTask ? 0 : 1), trigger: creation.creatingTask)
                .onTapGesture{
                    
                    withAnimation(.bouncy) {
                        creation.creatingTask.toggle()
                    }
                }
                .onLongPressGesture(minimumDuration: 0.2, maximumDistance: 10.0, pressing: { pressing in
                        if pressing {
                            withAnimation(.bouncy) {
                                buttonOpacity = 0.5
                                buttonSize = 0.9
                            }
                        } else {
                            withAnimation(.bouncy) {
                                buttonOpacity = 1
                                buttonSize = 1
                            }
                        }
                    }) {
                        withAnimation(.bouncy) {
                            buttonOpacity = 1
                            buttonSize = 1
                        }
                    }
            

            .scrollTransition { content, phase in
                content
                    .opacity(phase.isIdentity ? 1 : 0)
                    .scaleEffect(phase.isIdentity ? 1 : 0.75)
                    .blur(radius: phase.isIdentity ? 0 : 10)
            }
            .onChange(of: timeVariables.update) {
                updateAllTasks()
            }
            .sheet(isPresented: $creation.creatingTask) {
                CreateTask(context: context)
                    .presentationDragIndicator(.visible)
                    .padding()
                    .background {
                        // This is done in the background otherwise GeometryReader tends to expand to all the space given to it like color or shape.
                        GeometryReader { proxy in
                            Color.clear
                                .task { sheetContentHeight = proxy.size.height }
                        }
                    }
                    .presentationDetents([.height(sheetContentHeight)])
            }
        }
        .environmentObject(timeVariables)
        .animation(.bouncy, value: timeVariables.tasks)
        .scrollClipDisabled()
        .scrollIndicators(.hidden)
        .frame(height: UIScreen.screenHeight-150)
        .offset(y: 50)
    }
}
