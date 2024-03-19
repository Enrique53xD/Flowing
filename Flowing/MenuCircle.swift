//
//  MenuCircle.swift
//  Flowing
//
//  Created by Saúl González on 13/02/24.
//

import SwiftUI

struct MenuCircle: View {
    
    @Binding var deg: Double
    @State var mainColor = Color(UIColor.systemBackground)
    @Binding var color: Color
    
    
    var body: some View {
        ZStack{
            
            
            Group{
                
                
                
                Image(systemName: "house")
                    .fontWeight(.heavy)
                    .foregroundStyle(color.opacity(deg == -90 ? 1 : 0.5))
                    .font(deg == -90 ? .largeTitle : .title2)
                    .offset(y:150)
                    .rotationEffect(.degrees(90))
                    .onTapGesture {
                        deg = 0
                    }
                
                
                
                
                Image(systemName: "checkmark.circle")
                    .fontWeight(.heavy)
                    .foregroundStyle(color.opacity(deg == -60 || deg == 30 ? 1 : 0.5))
                    .font(deg == -60 || deg == 30 ? .largeTitle : .title2)
                    .offset(y:150)
                    .rotationEffect(.degrees(60))
                    .onTapGesture {
                        if deg != -60{
                            withAnimation{
                                deg -= 30
                            }
                        }
                        
                        
                    }
                
                
                
                
                Image(systemName: "gear")
                    .fontWeight(.heavy)
                    .foregroundStyle(color.opacity(deg == -30 || deg == 60 ? 1 : 0.5))
                    .font(deg == -30 || deg == 60 ? .largeTitle : .title2)
                    .offset(y:150)
                    .rotationEffect(.degrees(30))
                    .onTapGesture {
                        if deg != -30{
                            withAnimation{
                                deg -= 30
                            }
                        }
                    }
                
                
                
                
                Image(systemName: "house")
                    .fontWeight(.heavy)
                    .foregroundStyle(color.opacity(deg == 0 ? 1 : 0.5))
                    .font(deg == 0 ? .largeTitle : .title2)
                    .offset(y:150)
                    .rotationEffect(.degrees(0))
                    .onTapGesture {
                        withAnimation{
                            deg = 0
                        }
                    }
                
                
                
                
                
                Image(systemName: "checkmark.circle")
                    .fontWeight(.heavy)
                    .foregroundStyle(color.opacity(deg == -60 || deg == 30 ? 1 : 0.5))
                    .font(deg == -60 || deg == 30 ? .largeTitle : .title2)
                    .offset(y:150)
                    .rotationEffect(.degrees(-30))
                    .onTapGesture{
                        if deg != 30{
                            withAnimation{
                                deg += 30
                            }
                        }
                    }
                
                
                Image(systemName: "gear")
                    .fontWeight(.heavy)
                    .foregroundStyle(color.opacity(deg == 60 || deg == -30 ? 1 : 0.5))
                    .font(deg == 60 || deg == -30 ? .largeTitle : .title2)
                    .offset(y:150)
                    .rotationEffect(.degrees(-60))
                    .onTapGesture {
                        if deg != 60{
                            withAnimation{
                                deg += 30
                            }
                        }
                        
                        
                    }
                
                
                
                
                Image(systemName: "house")
                    .fontWeight(.heavy)
                    .foregroundStyle(color.opacity(deg == 90 ? 1 : 0.5))
                    .font(deg == 90 ? .largeTitle : .title2)
                    .offset(y:150)
                    .rotationEffect(.degrees(-90))
                    .onTapGesture {
                        deg = 0
                    }
                
            }
            
            .rotationEffect(.degrees(deg))
        
                
                Rectangle()
                    .fill(RadialGradient(colors: [mainColor.opacity(0), mainColor], center: UnitPoint(x: 0.5, y: 1.2), startRadius: 130, endRadius: 170))
                    .frame(height: 260)
                    .offset(y:50)
                    .allowsHitTesting(false)
            
        }
        
    }
}
