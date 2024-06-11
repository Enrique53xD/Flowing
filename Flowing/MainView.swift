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

// MARK: - Main View
struct MainView: View {
    
    //Environment Variables
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var context
    
    //Query Variables
    @Query(sort: [SortDescriptor(\taskItem.start), SortDescriptor(\taskItem.end), SortDescriptor(\taskItem.name)]) var taskItems: [taskItem]
    @Query(sort: \toDoItem.name) private var toDoItems: [toDoItem]
    @Query(sort: \progressiveItem.name) private var progressiveItems: [progressiveItem]
    @Query() private var settingsItems: [settingsItem1]
    
    //GitHub Variables
    @State private var login: String?
    @State private var repos = [reposWithIssues]()
    
    //MenuCircle Variables
    @State var deg: Double = 0
    @State var menu: Int = 0
    
    //Personalization Variables
    @State var settings: settingsItem1?
    @State var personalization = personalizationVariables()
    
    //Object Variables
    @State var creation = creatingVariables()
    @State var objects = taskObjectVariables()
    @StateObject var timeVariables = freeTimesVariables()
    
    var body: some View {
        
        ZStack {
            
            // MARK: - MenuCircle View
            MenuCircle(deg: $deg, personalization: $personalization)
                .offset(y:-500)
                .onAppear {
                    withAnimation { WidgetCenter.shared.reloadAllTimelines() }
                    updateAllTasks()
                    
                    if settingsItems.isEmpty { newSettings(context) }
                    
                    if let firstSettings = settingsItems.first {
                        settings = firstSettings
                        personalization.customColor = settings!.customMainColor
                        personalization.mainColor = Color(hex: settings!.mainColor)!
                        personalization.customTextColor = settings!.customTextColor
                        personalization.textColor = Color(hex: settings!.textColor)!
                        personalization.showFreeTimes = settings!.showFreeTimes
                        personalization.customHome = settings!.customHome
                        personalization.githubEnabled = settings!.githubEnabled
                        personalization.githubApiKey = settings!.githubApiKey
                        
                        if settings!.githubEnabled {
                            refreshData()
                        }
                    } else {
                        print("Error: settingsItems is still empty after calling newSettings")
                    }
                    
                    
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
                .onChange(of: timeVariables.updateGitHub) {
                    refreshData()
                }
            
            // MARK: - Home View
            if(menu == 0){
                HomeView(objects: $objects, personalization: $personalization, creation: $creation)
                    .environmentObject(timeVariables)
            }
            // MARK: - To-Do View
            else if (menu == 1) {
                ScrollView{
                    
                    if personalization.githubEnabled {
                        GithubView(customTextColor: $personalization.customTextColor, textColor: $personalization.textColor, config: TokenConfiguration(personalization.githubApiKey), login: $login, repos: $repos, customColor: personalization.customColor, mainColor: personalization.mainColor, defaultColor: Color.primary)
                            .padding(.bottom, 10)
                    }
                    
                    ToDoView(personalization: $personalization, objects: $objects, creation: $creation)
                   
                    if login != nil && login != "" && login != "Error" && personalization.githubEnabled {
                        Button(action: {  withAnimation(.bouncy){
                            if creation.creatingSome {
                                creation.creatingSome.toggle()
                                creation.creatingIssue.toggle()
                            }
                        } }, label: {
                            Image(systemName: "smallcircle.filled.circle")
                                .font(.title)
                                .fontWeight(.black)
                                .frame(width: 358, height: creation.creatingSome ? 60 : 0)
                                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                                .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(personalization.customColor ? personalization.mainColor : Color.primary))
                                .padding()
                                .sensoryFeedback(.impact(intensity: creation.creatingIssue ? 0 : 1), trigger: creation.creatingIssue)
                                
                        })
                        .padding(0)
                        .opacity(creation.creatingSome ? 1 : 0)
                        .simultaneousGesture(LongPressGesture(minimumDuration: 0.8).onEnded({_ in withAnimation(.bouncy){creation.creatingSome.toggle()}}))
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                .blur(radius: phase.isIdentity ? 0 : 10)
                        }
                        .sheet(isPresented: $creation.creatingIssue, content: {
                            CreateIssue(config: TokenConfiguration(personalization.githubApiKey), login: login ?? "")
                                .presentationDragIndicator(.visible)
                                .padding()
                                .background {
                                    GeometryReader { proxy in
                                        Color.clear
                                            .task { objects.sheetContentHeight = proxy.size.height }
                                    }
                                }
                                .presentationDetents([.height(objects.sheetContentHeight)])
                        })
                    }
                }
                .refreshable(action: {refreshData()})
                
                .animation(.bouncy, value: progressiveItems)
                .animation(.bouncy, value: toDoItems)
                .scrollClipDisabled()
                .scrollIndicators(.hidden)
                .frame(height: UIScreen.screenHeight-150)
                .offset(y: 50)
            }
            // MARK: - Settings View
            else if (menu == 2){
                SettingsView(personalization: $personalization, objects: $objects)
                    .environmentObject(timeVariables)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: 800)
        .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
            .onEnded({ value in
                if value.translation.width < -50 {
                    withAnimation(.bouncy){
                        deg += 30
                    }
                    if (deg == 60) {
                        deg = -30
                    } else if (deg == -60) {
                        deg = 30
                    }
                }
                if value.translation.width > 50 {
                    withAnimation(.bouncy){
                        deg -= 30
                    }
                    if (deg == 60) {
                        deg = -30
                    } else if (deg == -60) {
                        deg = 30
                    }
                }
            })
        )
    }
    
    // MARK: - Function to Update Tasks
    func updateAllTasks(){
        timeVariables.tasks = taskItems
        timeVariables.freeTimes = getFreeTimes(taskItems, days: objects.days, allTasks: personalization.allTasks)
        
        for free in timeVariables.freeTimes{
            timeVariables.tasks.append(taskItem(name: "fR33t1M3", color: "FFFFFF", desc: "u93fgbreiuwrg3", symbol: "clock", start: free.0, end: free.1, done: false, days: "1111111"))
        }
        
        timeVariables.tasks = timeVariables.tasks.sorted { $0.end < $1.end }
        timeVariables.tasks = timeVariables.tasks.sorted { $0.start < $1.start }

        withAnimation(){
            if let firstMatchingItem = taskItems.first(where: { (isToday($0.days) && checkCurrentTime(start: $0.start, end: $0.end)) || ($0.days == "0000000" && checkCurrentTime(start: $0.start, end: $0.end))}) {
                personalization.customIcon = firstMatchingItem.symbol
            } else {
                personalization.customIcon = "clock"
            }
        }
    }
    
    // MARK: - Refresh Data Function
    func refreshData() {
        clearCache()
        withAnimation(.smooth){
            repos = []
        }
        Task {
            login = await getLogin(TokenConfiguration(personalization.githubApiKey))
            let temp = await getRepos(TokenConfiguration(personalization.githubApiKey), login ?? "")
            withAnimation(.smooth){
                repos = temp
            }
        }
    }
    
    // MARK: - Clear Cache Function
    func clearCache() {
        let cache = URLCache.shared
        cache.removeAllCachedResponses()

        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
}
