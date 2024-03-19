//
//  MainView.swift
//  Flowing
//
//  Created by Saúl González on 12/01/24.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var context
    
    @Query(sort: [SortDescriptor(\taskItem.start), SortDescriptor(\taskItem.end), SortDescriptor(\taskItem.name)], animation: .default) private var taskItems: [taskItem]
    @Query(animation: .default) private var toDoItems: [toDoItem]
    @Query(animation: .default) private var progressiveItems: [progressiveItem]
    @Query(animation: .default) private var settingsItems: [settingsItem]
    
    
    @State var deg: Double = 0
    @State var menu: Int = 0
    @State var mainColor = Color.primary
    @State var defaultColor = Color.primary
    @State var customColor = false
    @State var allTasks = false
    @State var settings: settingsItem?
    @State var creatingTask = false
    @State var creatingToDo = false
    @State var creatingProgressive = false
    @State var creatingSome = false
    @State var days: String = "0000000"

    @State private var sheetContentHeight = CGFloat(0)
    
    var body: some View {
        ZStack{
            MenuCircle(deg: $deg, color: customColor ? $mainColor : $defaultColor)
                .offset(y:-500)
                .onChange(of: deg) {
                    if deg <= -60 { deg = 30}
                    else if deg >= 60 { deg = -30}
                    
                    withAnimation{
                        
                        
                        
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
                    
                    Button(action: {  withAnimation{creatingTask.toggle()}  }, label: {
                        
                        Text("+")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .frame(width: 360, height: 60)
                            .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                            .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(customColor ? mainColor : defaultColor))
                            .padding()
                            .sensoryFeedback(.increase, trigger: taskItems)
                       
                    })
                    .sheet(isPresented: $creatingTask, content: {
                        CreateTask(context: context)
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
                            
                            Button(action: { withAnimation{creatingSome.toggle()} }, label: {
                                
                                Text("+")
                                    .font(.largeTitle)
                                    .fontWeight(.heavy)
                                    .frame(width: 360, height: 60)
                                    .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                                    .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(customColor ? mainColor : defaultColor))
                                    .padding()
                                    .sensoryFeedback(.increase, trigger: taskItems)
                                
                                
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
                                    .frame(width: 160, height: 60)
                                    .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                                    .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(customColor ? mainColor : defaultColor))
                                    .padding()
                                    .sensoryFeedback(.increase, trigger: taskItems)
                                
                                
                            })
                            .simultaneousGesture(LongPressGesture(minimumDuration: 0.8).onEnded({_ in withAnimation{creatingSome.toggle()}}))
                            .sheet(isPresented: $creatingToDo, onDismiss: {withAnimation{creatingSome.toggle()}}){
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
                            
                            Spacer()
                            
                            Button(action: { if creatingSome{ withAnimation{creatingProgressive.toggle()}} }, label: {
                                
                                Image(systemName: "circle.dotted")
                                    .font(.largeTitle)
                                    .fontWeight(.heavy)
                                    .frame(width: 160, height: 60)
                                    .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                                    .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(customColor ? mainColor : defaultColor))
                                    .padding()
                                    .sensoryFeedback(.increase, trigger: taskItems)
                                
                                
                            })
                            .simultaneousGesture(LongPressGesture(minimumDuration: 0.8).onEnded({_ in withAnimation{creatingSome.toggle()}}))
                            .sheet(isPresented: $creatingProgressive, onDismiss: {withAnimation{creatingSome.toggle()}}){
                                CreateProgressive(context: context)
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
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .scaleEffect(phase.isIdentity ? 1 : 0.75)
                            .blur(radius: phase.isIdentity ? 0 : 10)
                        
                    }
                }
                .scrollClipDisabled()
                .frame(height: UIScreen.screenHeight-150)
                .offset(y: 50)
            } else if (menu == 2){
                ScrollView{
                    
                    Group{
                        Toggle(isOn: $customColor.animation()) {
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
                            ColorPicker(selection: $mainColor.animation(), supportsOpacity: false) {
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
                        Toggle(isOn: $allTasks.animation()) {
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
                }
                .padding(.horizontal)
                .scrollClipDisabled()
                .frame(height: UIScreen.screenHeight-150)
                .offset(y: 50)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 800)
        .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
            .onEnded({ value in
                if value.translation.width < -50 {
                    withAnimation{
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
                    withAnimation{
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




