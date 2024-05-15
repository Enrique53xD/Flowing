//
//  MainView.swift
//  Flowing
//
//  Created by Saúl González on 12/01/24.
//

import SwiftUI
import SwiftData
import WidgetKit
import OctoKit

// Variables that i use so i can change them in another view
class freeTimesVariables : ObservableObject {
    
    @Published var tasks = [taskItem]()
    @Published var freeTimes = [(Int,Int)]()
    @Published var update = false
    
}

// MARK: Main View
struct MainView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var context
    
    @Query(sort: [SortDescriptor(\taskItem.start), SortDescriptor(\taskItem.end), SortDescriptor(\taskItem.name)]) private var taskItems: [taskItem]
    @Query(sort: \toDoItem.name) private var toDoItems: [toDoItem]
    @Query(sort: \progressiveItem.name) private var progressiveItems: [progressiveItem]
    @Query() private var settingsItems: [settingsItem]
    
    let config = TokenConfiguration("")
    @State private var login: String?
    @State private var repos = [reposWithIssues]()
    
    // MenuCircle variables
    @State var deg: Double = 0
    @State var menu: Int = 0
    
    // Personalization variables
    @State var settings: settingsItem?
    
    @State var customColor = false
    @State var mainColor = Color.primary
    @State var defaultColor = Color.primary
    
    @State var customTextColor = false
    @State var textColor = Color.primary
    
    @State var customHome = false
    @State var customIcon = "clock"
    
    @State var allTasks = false

    @State var showFreeTimes = false
    
    // Object variables
    @State var creatingTask = false
    @State var creatingToDo = false
    @State var creatingProgressive = false
    @State var creatingSome = false
    
    @State var days: String = "0000000"
    
    @State private var sheetContentHeight = CGFloat(0)
    
    @StateObject var timeVariables = freeTimesVariables()
    
    // Function to update the tasks so the free times update
    func updateAllTasks(){
        
        timeVariables.tasks = taskItems
        timeVariables.freeTimes = getFreeTimes(taskItems, days: days, allTasks: allTasks)
        
        for free in timeVariables.freeTimes{
            
            timeVariables.tasks.append(taskItem(name: "fR33t1M3", color: "FFFFFF", desc: "u93fgbreiuwrg3", symbol: "clock", start: free.0, end: free.1, done: false, days: "1111111"))
            
        }
        
        timeVariables.tasks = timeVariables.tasks.sorted { $0.end < $1.end }
        timeVariables.tasks = timeVariables.tasks.sorted { $0.start < $1.start }

        withAnimation(){
            
            if let firstMatchingItem = taskItems.first(where: { (isToday($0.days) && checkCurrentTime(start: $0.start, end: $0.end)) || ($0.days == "0000000" && checkCurrentTime(start: $0.start, end: $0.end))}) {
                customIcon = firstMatchingItem.symbol
            } else {
                customIcon = "clock"
            }
            
        }
        
    }
    
    var body: some View {
        
        ZStack{

            MenuCircle(deg: $deg, color: customColor ? $mainColor : $defaultColor, customHome: $customHome, customIcon: $customIcon)
                .offset(y:-500)
                .onAppear {
                    
                    

                    
                    withAnimation { WidgetCenter.shared.reloadAllTimelines() }
                    updateAllTasks()
                    
                    if settingsItems.isEmpty { newSettings(context) }
                    
                    if let firstSettings = settingsItems.first {
                        
                        settings = firstSettings
                        customColor = settings!.customMainColor
                        mainColor = Color(hex: settings!.mainColor)!
                        customTextColor = settings!.customTextColor
                        textColor = Color(hex: settings!.textColor)!
                        showFreeTimes = settings!.showFreeTimes
                        customHome = settings!.customHome
                     
                    } else {
                        
                        // Handle the case when settingsItems is still empty after calling newSettings
                        print("Error: settingsItems is still empty after calling newSettings")
                        
                    }
                    
                    refreshData()
                    
                    
                }
                .onChange(of: deg) {
                    if (deg == 60) { deg = -30 }
                    else if (deg == -60) { deg = 30 }
                    
                    withAnimation(.bouncy){
                        
                        if (deg == 0){ menu = 0 }
                        else if (deg == 30){ menu = 1 }
                        else if (deg == -30){ menu = 2 }
                        
                    }
                }

            // The home view where all tasks are shown
            if(menu == 0){
                
                ScrollView{

                    ForEach(timeVariables.tasks){ item in
                        
                        // Shows the tasks depending on the option to show specific t
                        if allTasks ? isIncluded(item.days, days) : isToday(item.days) {
                            
                            if item.name == "fR33t1M3" && item.desc == "u93fgbreiuwrg3" {
                                
                                if checkCurrentTime(start: item.start, end: item.end) && showFreeTimes {
                                    Image(systemName: "clock")
                                        .font(.title)
                                        .fontWeight(.heavy)
                                        .frame(width: 358, height: 60)
                                        .foregroundStyle(customColor ? mainColor : defaultColor)
                                        .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(customColor ? mainColor.opacity(0.3) : defaultColor.opacity(0.3)))
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
                                
                                TaskObj(item: item, context: context, textColor: customTextColor ? textColor : Color.primary)
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

                    //The button to add a task
                    Button(action: { withAnimation{creatingTask.toggle()} }, label: {
                        
                        Image(systemName: "plus")
                            .font(.title)
                            .fontWeight(.black)
                            .frame(width: 358, height: 60)
                            .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                            .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(customColor ? mainColor : defaultColor))
                            .padding()
                            .sensoryFeedback(.impact(intensity: creatingTask ? 0 : 1), trigger: creatingTask)
                        
                    })
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .scaleEffect(phase.isIdentity ? 1 : 0.75)
                            .blur(radius: phase.isIdentity ? 0 : 10)
                    }
                    .onChange(of: timeVariables.update){
                        
                            updateAllTasks()
                      
                    }
                    .sheet(isPresented: $creatingTask, content: {
                        CreateTask(context: context)
                            .presentationDragIndicator(.visible)
                            .padding()
                            .background {
                                //This is done in the background otherwise GeometryReader tends to expand to all the space given to it like color or shape.
                                GeometryReader { proxy in
                                    
                                    Color.clear
                                        .task { sheetContentHeight = proxy.size.height }
                                    
                                }
                            }
                            .presentationDetents([.height(sheetContentHeight)])
                    })
                
                }
                .environmentObject(timeVariables)
                .animation(.bouncy, value: timeVariables.tasks)
                .scrollClipDisabled()
                .scrollIndicators(.hidden)
                .frame(height: UIScreen.screenHeight-150)
                .offset(y: 50)
                
            } else if (menu == 1) {
                
                ScrollView{
                    
                    ForEach(toDoItems) { item in
                        
                        ToDoObj(item: item, context: context, textColor: customTextColor ? textColor : Color.primary)
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                    .blur(radius: phase.isIdentity ? 0 : 10)
                            }
                        
                    }
                    
                    ForEach(progressiveItems) { item in
                        
                        ProgressiveObj(item: item, context: context, textColor: customTextColor ? textColor : Color.primary)
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                    .blur(radius: phase.isIdentity ? 0 : 10)
                            }
                        
                    }
                    
                    HStack {
 
                        Button(action: { if creatingSome{ withAnimation(.bouncy){creatingSome.toggle(); creatingToDo.toggle()}} }, label: {
                            
                            Image(systemName: "checkmark.circle")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .frame(width: creatingSome ? 170 : 0, height: 60)
                                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                                .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(customColor ? mainColor : defaultColor))
                                .opacity(creatingSome ? 1 : 0)

                        })
                        .padding(0)
                        .frame(width: creatingSome ? 170 : 0)
                        .opacity(creatingSome ? 1 : 0)
                        .simultaneousGesture(LongPressGesture(minimumDuration: 0.8).onEnded({_ in withAnimation(.bouncy){creatingSome.toggle()}}))
                        .sheet(isPresented: $creatingToDo){
                            CreateToDo(context: context)
                                .presentationDragIndicator(.visible)
                                .padding()
                                .background {
                                    //This is done in the background otherwise GeometryReader tends to expand to all the space given to it like color or shape.
                                    GeometryReader { proxy in
                                        Color.clear
                                            .task {
                                                sheetContentHeight = proxy.size.height
                                            }
                                    }
                                }
                                .presentationDetents([.height(sheetContentHeight)])
                        }
                        
                        if creatingSome { Spacer() }
                        
                        Button(action: { withAnimation(.bouncy){creatingSome.toggle()} }, label: {
                            
                            Image(systemName: "plus")
                                .font(.title)
                                .fontWeight(.black)
                                .frame(width: creatingSome ? 0 : 358, height: 60)
                                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                                .opacity(creatingSome ? 0 : 1)
                                .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(customColor ? mainColor : defaultColor))
                            
                                .sensoryFeedback(.impact(), trigger: creatingSome)
                                .opacity(creatingSome ? 0 : 1)
                            
                        })
                        .opacity(creatingSome ? 0 : 1)
                        .padding(0)
                        
                        if creatingSome { Spacer() }
                        
                        Button(action: { if creatingSome{ withAnimation(.bouncy){creatingSome.toggle(); creatingProgressive.toggle()}} }, label: {
                            
                            Image(systemName: "circle.dotted")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .frame(width: creatingSome ? 170 : 0, height: 60)
                                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                                .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(customColor ? mainColor : defaultColor))
                                .opacity(creatingSome ? 1 : 0)
                 
                            
                            
                        })
                        .padding(0)
                        .frame(width: creatingSome ? 170 : 0)
                        .opacity(creatingSome ? 1 : 0)
                        .simultaneousGesture(LongPressGesture(minimumDuration: 0.8).onEnded({_ in withAnimation(.bouncy){creatingSome.toggle()}}))
                        .sheet(isPresented: $creatingProgressive){
                            CreateProgressive(context: context)
                                .presentationDragIndicator(.visible)
                                .padding()
                                .background {
                                    //This is done in the background otherwise GeometryReader tends to expand to all the space given to it like color or shape.
                                    GeometryReader { proxy in
                                        Color.clear
                                            .task {
                                                sheetContentHeight = proxy.size.height
                                            }
                                    }
                                }
                                .presentationDetents([.height(sheetContentHeight)])
                            
                            
                        }
                        
                    }
                    .padding(creatingSome ? [.horizontal, .vertical] : [.vertical])
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .scaleEffect(phase.isIdentity ? 1 : 0.75)
                            .blur(radius: phase.isIdentity ? 0 : 10)
                        
                    }
                    
                    Github_Tests(customTextColor: $customTextColor, textColor: $textColor, config: config, login: $login, repos: $repos)
                        
                    
                }
                .refreshable(action: {refreshData()})
                .animation(.bouncy, value: progressiveItems)
                .animation(.bouncy, value: toDoItems)
                .scrollClipDisabled()
                .scrollIndicators(.hidden)
                .frame(height: UIScreen.screenHeight-150)
                .offset(y: 50)
                
            } else if (menu == 2){
                
                ScrollView{
                    
                    // Personalization section
                    Group {
                        Text("Personalization")
                            .fontDesign(.rounded)
                            .foregroundStyle(customTextColor ? textColor : Color.primary)
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
                        
                        
                        Toggle(isOn: $customHome.animation(.bouncy)) {
                            Text("Home icon is active task")
                                .fontDesign(.rounded)
                                .foregroundStyle(customTextColor ? textColor : Color.primary)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                        }
                        .onChange(of: customHome){
                            settingsItems.first?.customHome = customHome
                            try? context.save()
                            updateAllTasks()
                        }
                        .frame(height: 60)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                .blur(radius: phase.isIdentity ? 0 : 10)
                        }
                        
                        Group{
                            Toggle(isOn: $customColor.animation(.bouncy)) {
                                Text("Custom main color")
                                    .fontDesign(.rounded)
                                    .foregroundStyle(customTextColor ? textColor : Color.primary)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                            }
                            .onChange(of: customColor){
                                settingsItems.first?.customMainColor = customColor
                                try? context.save()
                            }
                            .frame(height: 60)
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                    .blur(radius: phase.isIdentity ? 0 : 10)
                            }
                            
                            if customColor {
                                ColorPicker(selection: $mainColor.animation(.bouncy), supportsOpacity: false) {
                                    Text("Main color")
                                        .fontDesign(.rounded)
                                        .foregroundStyle(customTextColor ? textColor : Color.primary)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                .onChange(of: mainColor){
                                    settingsItems.first?.mainColor = mainColor.toHex()!
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
                        
                        Group{
                            Toggle(isOn: $customTextColor.animation(.bouncy)) {
                                Text("Custom text color")
                                    .fontDesign(.rounded)
                                    .foregroundStyle(customTextColor ? textColor : Color.primary)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                            }
                            .onChange(of: customTextColor){
                                settingsItems.first?.customTextColor = customTextColor
                                try? context.save()
                            }
                            .frame(height: 60)
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                    .blur(radius: phase.isIdentity ? 0 : 10)
                            }
                            
                            if customTextColor {
                                ColorPicker(selection: $textColor.animation(.bouncy), supportsOpacity: false) {
                                    Text("Text color")
                                        .fontDesign(.rounded)
                                        .foregroundStyle(customTextColor ? textColor : Color.primary)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                .onChange(of: textColor){
                                    settingsItems.first?.textColor = textColor.toHex()!
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
                    }
                    
                    // Visibility section
                    Group {
                        Text("Visibility")
                            .fontDesign(.rounded)
                            .foregroundStyle(customTextColor ? textColor : Color.primary)
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
                        
                        Toggle(isOn: $showFreeTimes, label: {
                            Text("Show free times")
                                .fontDesign(.rounded)
                                .foregroundStyle(customTextColor ? textColor : Color.primary)
                                .font(.title2)
                                .fontWeight(.bold)
                        })
                        .onChange(of: showFreeTimes){
                            settingsItems.first?.showFreeTimes = showFreeTimes
                            try? context.save()
                            updateAllTasks()
                        }
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                .blur(radius: phase.isIdentity ? 0 : 10)
                        }
                        .frame(height: 60)
                        
                        Group{
                            Toggle(isOn: $allTasks.animation(.bouncy)) {
                                Text("Show sprecific tasks")
                                    .fontDesign(.rounded)
                                    .foregroundStyle(customTextColor ? textColor : Color.primary)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                            }
                            .onChange(of: allTasks) {updateAllTasks()}
                            .onChange(of: days) {updateAllTasks()}
                            .frame(height: 60)
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                    .blur(radius: phase.isIdentity ? 0 : 10)
                            }
                            
                            if allTasks{
                                DaySelector(days: $days, color: customTextColor ? $textColor : $defaultColor, size: 39.5)
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
        .frame(maxWidth: .infinity, maxHeight: 800)
        
        // Used to move between menus
        .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
            .onEnded({ value in
                if value.translation.width < -50 {
                    
                    withAnimation(.bouncy){
                        deg += 30
                    }
                    
                    if (deg == 60) {
                        deg = -30
                    } else if (deg == -60)
                    {
                        deg = 30
                    }

                }
                
                if value.translation.width > 50 {
                    withAnimation(.bouncy){
                        deg -= 30
                    }
                    
                    if (deg == 60) {
                        deg = -30
                    } else if (deg == -60)
                    {
                        deg = 30
                    }
                    
                    
                    
                }
 
            })
                 
        )
        
    }
        
    func refreshData() {
        clearCache()
        withAnimation(.smooth){
            repos = []
        }
        Task {
            
            
            login = await getLogin(config)
            let temp = await getRepos(config, login ?? "")
            
            withAnimation(.smooth){
               
                repos = temp
            }
        }
        
    }
    
    func clearCache() {
      let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
      let fileManager = FileManager.default
      
      do {
        let directoryContents = try fileManager.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil, options: [])
        for file in directoryContents {
          do {
            try fileManager.removeItem(at: file)
          } catch let error {
            debugPrint("Error removing cache file: \(error)")
          }
        }
      } catch let error {
        debugPrint("Error fetching cache directory contents: \(error)")
      }
    }

}




