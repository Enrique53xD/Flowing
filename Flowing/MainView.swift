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
    
    @Query(sort: \taskItem.start, animation: .default) private var taskItems: [taskItem]
    
    
    @State var deg: Double = 0
    @State var menu: Int = 0
    @State var mainColor = Color.primary
    @State var defaultColor = Color.primary
    @State var customColor = false
    @State var allTasks = false

    
    var body: some View {
        ZStack{
            MenuCircle(deg: $deg, color: customColor ? $mainColor : $defaultColor)
                
                .offset(y:-500)
            
            if(menu == 0){
                ScrollView{
                    
                    
                    
                    ForEach(taskItems){ item in
                        
                        TaskObj(item: item, context: context)
                            .clipped(antialiased: true)
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                    .blur(radius: phase.isIdentity ? 0 : 10)
                                
                            }
                    }
                    
                    Button(action: { withAnimation{newTask(context)} }, label: {
                        
                        Text("+")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .frame(width: 350, height: 60)
                            .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                            .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(customColor ? mainColor : defaultColor))
                            .padding()
                            .sensoryFeedback(.increase, trigger: taskItems)
                       
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
                    ToDoObj()
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                .blur(radius: phase.isIdentity ? 0 : 10)
                        }
                    ProgressiveObj()
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
                       
                            .frame(height: 60)
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                    .blur(radius: phase.isIdentity ? 0 : 10)
                            }
                        }
                    }
                    
                    Toggle(isOn: $allTasks) {
                        Text("Show all tasks")
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
                    
                }
                .padding(.horizontal)
                .scrollClipDisabled()
                .frame(height: UIScreen.screenHeight-150)
                .offset(y: 50)
            }
        }
        .frame(width: .infinity, height: 800)
        
        
        .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
            .onEnded({ value in
                if value.translation.width < -50 {
                    withAnimation{
                        deg += 45
                    }
                    
                    if (deg == 90) {
                        deg = -45
                    } else if (deg == -90)
                    {
                        deg = 45
                    }
                    
                    withAnimation{
                        if (deg == 0){
                            menu = 0
                        } 
                        else if (deg == 45){
                            menu = 1
                        }
                        
                        else if (deg == -45){
                            menu = 2
                        }
                    }
                    
                }
                
                if value.translation.width > 50 {
                    withAnimation{
                        deg -= 45
                    }
                    
                    if (deg == 90) {
                        deg = -45
                    } else if (deg == -90)
                    {
                        deg = 45
                    }
                    
                    withAnimation{
                        if (deg == 0){
                            menu = 0
                        }
                        else if (deg == 45){
                            menu = 1
                        }
                        
                        else if (deg == -45){
                            menu = 2
                        }
                    }
                }
                
            })
                 
        )
        
    }
    
    
    
    
}


#Preview {
    MainView()
}

