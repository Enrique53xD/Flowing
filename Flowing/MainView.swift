//
//  MainView.swift
//  Flowing
//
//  Created by Saúl González on 12/01/24.
//

import SwiftUI
import SwiftData
import WidgetKit

struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var context
    
    @Query(sort: [SortDescriptor(\taskItem.start), SortDescriptor(\taskItem.end), SortDescriptor(\taskItem.name)], animation: .bouncy) private var taskItems: [taskItem]
    @Query(animation: .bouncy) private var toDoItems: [toDoItem]
    @Query(animation: .bouncy) private var progressiveItems: [progressiveItem]
    @Query(animation: .bouncy) private var settingsItems: [settingsItm]
    
    
    @State var deg: Double = 0
    @State var menu: Int = 0
    @State var widgetRange = false
    @State var widgetName = false
    @State var mainColor = Color.primary
    @State var defaultColor = Color.primary
    @State var customColor = false
    @State var allTasks = false
    @State var settings: settingsItm?
    @State var creatingTask = false
    @State var creatingToDo = false
    @State var creatingProgressive = false
    @State var creatingSome = false
    @State var days: String = "0000000"
    @State private var sheetContentHeight = CGFloat(0)
    
    var body: some View {
        ZStack{
            MenuCircle(deg: $deg, color: customColor ? $mainColor : $defaultColor)
                .onAppear(){ withAnimation{ WidgetCenter.shared.reloadAllTimelines() }}
                .offset(y:-500)
                .onChange(of: deg) {
                
                    if (deg == 60) {
                        deg = -30
                    } else if (deg == -60)
                    {
                        deg = 30
                    }
                    
                    withAnimation(.bouncy){
                        
                        
                        
                        if (deg == 0){
                            menu = 0
                        }
                        else if (deg == 30){
                            menu = 1
                        }
                        
                        else if (deg == -30){
                            menu = 2
                        }
                    }
                    
                }
                .onAppear {
                    if settingsItems.isEmpty {
                        newSettings(context)
                    }
                    
                    if let firstSettings = settingsItems.first {
                        settings = firstSettings
                        customColor = settings!.customMainColor
                        widgetRange = settings!.widgetRange
                        widgetName = settings!.widgetName
                        mainColor = Color(hex: settings!.mainColor)!
                     
                    } else {
                        // Handle the case when settingsItems is still empty after calling newSettings
                        print("Error: settingsItems is still empty after calling newSettings")
                    }
                }
            
            if(menu == 0){
                ScrollView{
                    
                    
                    
                    ForEach(taskItems){ item in
                        
                        if !allTasks {
                            
                            if isToday(item.days) || item.days == "0000000"  {
                                
                                
                                TaskObj(item: item, context: context)
                                    .clipped(antialiased: true)
                                    .scrollTransition { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1 : 0)
                                            .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                            .blur(radius: phase.isIdentity ? 0 : 10)
                                        
                                    }
                            }
                        }
                        else {
                            if isIncluded(item.days, days) || days == "0000000" {

                                TaskObj(item: item, context: context)
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
                    
                    Button(action: { withAnimation{creatingTask.toggle()} }, label: {
                        
                        Text("+")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .frame(width: 358, height: 60)
                            .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                            .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(customColor ? mainColor : defaultColor))
                            .padding()
                            .sensoryFeedback(.impact(intensity: creatingTask ? 0 : 1), trigger: creatingTask)
                        
                    })
                    .sheet(isPresented: $creatingTask, content: {
                        CreateTask(context: context)
                            .presentationDragIndicator(.visible)
                            .padding()
                            .background {
                                //This is done in the background otherwise GeometryReader tends to expand to all the space given to it like color or shape.
                                GeometryReader { proxy in
                                    Color.clear
                                        .task {
                                            print("size = \(proxy.size.height)")
                                            sheetContentHeight = proxy.size.height
                                        }
                                }
                            }
                            .presentationDetents([.height(sheetContentHeight)])
                        
                    })
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .scaleEffect(phase.isIdentity ? 1 : 0.75)
                            .blur(radius: phase.isIdentity ? 0 : 10)
                        
                    }
                    
                    
                }
                .scrollClipDisabled()
                .scrollIndicators(.hidden)
                .frame(height: UIScreen.screenHeight-150)
                .offset(y: 50)
                
            } else if (menu == 1){
                ScrollView{
                    
                    ForEach(toDoItems) { item in
                        ToDoObj(item: item, context: context)
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                    .blur(radius: phase.isIdentity ? 0 : 10)
                            }
                    }
                    
                    ForEach(progressiveItems) { item in
                        ProgressiveObj(item: item, context: context)
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                    .blur(radius: phase.isIdentity ? 0 : 10)
                            }
                    }
                    
                    HStack {
                        if !creatingSome {
                            
                            Button(action: { withAnimation(.bouncy){creatingSome.toggle()} }, label: {
                                
                                Text("+")
                                    .font(.largeTitle)
                                    .fontWeight(.heavy)
                                    .frame(width: 358, height: 60)
                                    .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                                    .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(customColor ? mainColor : defaultColor))
                                   
                                    .sensoryFeedback(.impact(intensity: creatingSome ? 1 : 0), trigger: creatingSome)
                                
                            })
                            .sheet(isPresented: $creatingToDo){
                                CreateToDo(context: context)
                                    .padding()
                                    .background {
                                        //This is done in the background otherwise GeometryReader tends to expand to all the space given to it like color or shape.
                                        GeometryReader { proxy in
                                            Color.clear
                                                .task {
                                                    print("size = \(proxy.size.height)")
                                                    sheetContentHeight = proxy.size.height
                                                }
                                        }
                                    }
                                    .presentationDetents([.height(sheetContentHeight)])
                            }
                        } else {
                            Button(action: { if creatingSome{ withAnimation{creatingToDo.toggle()}} }, label: {
                                
                                Image(systemName: "checkmark.circle")
                                    .font(.largeTitle)
                                    .fontWeight(.heavy)
                                    .frame(width: 165, height: 60)
                                    .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                                    .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(customColor ? mainColor : defaultColor))
                                    
                                    .sensoryFeedback(.impact(intensity: creatingToDo ? 0 : 1), trigger: creatingToDo)
                                
                                
                            })
                            .simultaneousGesture(LongPressGesture(minimumDuration: 0.8).onEnded({_ in withAnimation(.bouncy){creatingSome.toggle()}}))
                            .sheet(isPresented: $creatingToDo, onDismiss: {withAnimation(.bouncy){creatingSome.toggle()}}){
                                CreateToDo(context: context)
                                    .presentationDragIndicator(.visible)
                                    .padding()
                                    .background {
                                        //This is done in the background otherwise GeometryReader tends to expand to all the space given to it like color or shape.
                                        GeometryReader { proxy in
                                            Color.clear
                                                .task {
                                                    print("size = \(proxy.size.height)")
                                                    sheetContentHeight = proxy.size.height
                                                }
                                        }
                                    }
                                    .presentationDetents([.height(sheetContentHeight)])
                            }
                            
                            Spacer()
                            
                            Button(action: { if creatingSome{ withAnimation{creatingProgressive.toggle()}} }, label: {
                                
                                Image(systemName: "circle.dotted")
                                    .font(.largeTitle)
                                    .fontWeight(.heavy)
                                    .frame(width: 165, height: 60)
                                    .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                                    .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(customColor ? mainColor : defaultColor))
                                   
                                    .sensoryFeedback(.impact(intensity: creatingProgressive ? 0 : 1), trigger: creatingProgressive)
                                
                                
                            })
                            .simultaneousGesture(LongPressGesture(minimumDuration: 0.8).onEnded({_ in withAnimation(.bouncy){creatingSome.toggle()}}))
                            .sheet(isPresented: $creatingProgressive, onDismiss: {withAnimation(.bouncy){creatingSome.toggle()}}){
                                CreateProgressive(context: context)
                                    .presentationDragIndicator(.visible)
                                    .padding()
                                    .background {
                                        //This is done in the background otherwise GeometryReader tends to expand to all the space given to it like color or shape.
                                        GeometryReader { proxy in
                                            Color.clear
                                                .task {
                                                    print("size = \(proxy.size.height)")
                                                    sheetContentHeight = proxy.size.height
                                                }
                                        }
                                    }
                                    .presentationDetents([.height(sheetContentHeight)])
                            }
                            
                        }
                    }
                    .padding()
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .scaleEffect(phase.isIdentity ? 1 : 0.75)
                            .blur(radius: phase.isIdentity ? 0 : 10)
                        
                    }
                }
                .scrollClipDisabled()
                .scrollIndicators(.hidden)
                .frame(height: UIScreen.screenHeight-150)
                .offset(y: 50)
            } else if (menu == 2){
                ScrollView{
                    
                    Group{
                        Toggle(isOn: $customColor.animation(.bouncy)) {
                            Text("Custom main color")
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
                        Toggle(isOn: $allTasks.animation(.bouncy)) {
                            Text("Show sprecific tasks")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                        }
                        .frame(height: 60)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                .blur(radius: phase.isIdentity ? 0 : 10)
                        }
                        
                        if allTasks{
                            DaySelector(days: $days, color: customColor ? $mainColor : $defaultColor, size: 39.5)
                                .scrollTransition { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0)
                                        .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                        .blur(radius: phase.isIdentity ? 0 : 10)
                                }
                            
                        }
                    }
                    
                    Toggle(isOn: $widgetRange.animation(.bouncy)) {
                        Text("Widget show time range")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                    }
                    .frame(height: 60)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .scaleEffect(phase.isIdentity ? 1 : 0.75)
                            .blur(radius: phase.isIdentity ? 0 : 10)
                    }
                    .onChange(of: widgetRange){
                        settingsItems.first?.widgetRange = widgetRange
                        try? context.save()
                        
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                    
                    Toggle(isOn: $widgetName.animation(.bouncy)) {
                        Text("Widget show name")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                    }
                    .frame(height: 60)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .scaleEffect(phase.isIdentity ? 1 : 0.75)
                            .blur(radius: phase.isIdentity ? 0 : 10)
                    }
                    .onChange(of: widgetName){
                        settingsItems.first?.widgetName = widgetName
                        try? context.save()
                        
                        WidgetCenter.shared.reloadAllTimelines()
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
}




