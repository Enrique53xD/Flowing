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
                    .foregroundStyle(color.opacity(deg == -135 ? 1 : 0.5))
                    .font(deg == -135 ? .largeTitle : .title2)
                    .offset(y:150)
                    .rotationEffect(.degrees(120))
                
                Image(systemName: "checkmark.circle")
                    .fontWeight(.heavy)
                    .foregroundStyle(color.opacity(deg == -90 || deg == 45 ? 1 : 0.5))
                    .font(deg == -90 || deg == 45 ? .largeTitle : .title2)
                    .offset(y:150)
                    .rotationEffect(.degrees(deg == 45 || deg == -90 ? 90 : 75))
                
                Image(systemName: "gear")
                    .fontWeight(.heavy)
                    .foregroundStyle(color.opacity(deg == -45 || deg == 90 ? 1 : 0.5))
                    .font(deg == -45 || deg == 90 ? .largeTitle : .title2)
                    .offset(y:150)
                    .rotationEffect(.degrees(deg == -45 || deg == 90 ? 45 : deg > 0 ? 60 : 30))
                
                Image(systemName: "house")
                    .fontWeight(.heavy)
                    .foregroundStyle(color.opacity(deg == 0 ? 1 : 0.5))
                    .font(deg == 0 ? .largeTitle : .title2)
                    .offset(y:150)
                    .rotationEffect(.degrees(deg == 0 ? 0 : deg > 0 ? -15 : 15))
                
                Image(systemName: "checkmark.circle")
                    .fontWeight(.heavy)
                    .foregroundStyle(color.opacity(deg == -90 || deg == 45 ? 1 : 0.5))
                    .font(deg == -90 || deg == 45 ? .largeTitle : .title2)
                    .offset(y:150)
                    .rotationEffect(.degrees(deg == 45 || deg == -90 ? -45 : deg < 0 ? -60 : -30))
                
                Image(systemName: "gear")
                    .fontWeight(.heavy)
                    .foregroundStyle(color.opacity(deg == 90 || deg == -45 ? 1 : 0.5))
                    .font(deg == 90 || deg == -45 ? .largeTitle : .title2)
                    .offset(y:150)
                    .rotationEffect(.degrees(deg == -45 || deg == 90 ? -90 : -75))
                
                Image(systemName: "house")
                    .fontWeight(.heavy)
                    .foregroundStyle(color.opacity(deg == 135 ? 1 : 0.5))
                    .font(deg == 135 ? .largeTitle : .title2)
                    .offset(y:150)
                    .rotationEffect(.degrees(-120))
                
            }
   
            .rotationEffect(.degrees(deg))
            
            Rectangle()
                .fill(RadialGradient(colors: [mainColor.opacity(0), mainColor], center: UnitPoint(x: 0.5, y: 1.2), startRadius: 130, endRadius: 170))
                .frame(height: 260)
                .offset(y:50)
        }
  
    }
}
