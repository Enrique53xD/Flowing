//
//  MainView.swift
//  Flowing
//
//  Created by Saúl González on 12/01/24.
//

import SwiftUI

struct MainView: View {
    @State var deg: Double = 0
    @State var menu: Int = 0
    @State var mainColor = Color(UIColor.systemBackground)

    
    var body: some View {
        ZStack{
            MenuCircle(deg: $deg, mainColor: $mainColor)
                
                .offset(y:-500)
            
            if(menu == 0){
                ScrollView{
                    
                    
                    ForEach(1...15, id: \.self){ _ in
                        
                        TaskObj()
                            .clipped(antialiased: true)
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                    .blur(radius: phase.isIdentity ? 0 : 10)
                                
                            }
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
                    Text("a")
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

