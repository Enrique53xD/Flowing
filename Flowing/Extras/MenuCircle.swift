//
//  MenuCircle.swift
//  Flowing
//
//  Created by Saúl González on 13/02/24.
//

import SwiftUI

struct MenuCircle: View {
    // State and binding properties
    @State var mainColor = Color(UIColor.systemBackground)
    @Binding var deg: Double
    @Binding var personalization: personalizationVariables
    @State var color: Color = Color.primary
    
    var body: some View {
        ZStack {
            // Menu items
            Group {
                // Home icon
                Image(systemName: personalization.customHome ? personalization.customIcon : "house")
                    .fontWeight(.heavy)
                    .foregroundStyle(personalization.customColor ? personalization.mainColor.opacity(deg == -90 ? 1 : 0.5) : Color.primary.opacity(deg == -90 ? 1 : 0.5))
                    .font(deg == -90 ? .largeTitle : .title2)
                    .offset(y: 150)
                    .rotationEffect(.degrees(90))
                    .onTapGesture {
                        deg = 0
                    }
                
                // Checkmark icon
                Image(systemName: "checkmark.circle")
                    .fontWeight(.heavy)
                    .foregroundStyle(personalization.customColor ? personalization.mainColor.opacity(deg == -60 || deg == 30 ? 1 : 0.5) : Color.primary.opacity(deg == -60 || deg == 30 ? 1 : 0.5))
                    .font(deg == -60 || deg == 30 ? .largeTitle : .title2)
                    .offset(y: 150)
                    .rotationEffect(.degrees(60))
                    .onTapGesture {
                        if deg != -60 {
                            withAnimation(.bouncy) {
                                deg -= 30
                            }
                        }
                    }
                
                // Gear icon
                Image(systemName: "gear")
                    .fontWeight(.heavy)
                    .foregroundStyle(personalization.customColor ? personalization.mainColor.opacity(deg == -30 || deg == 60 ? 1 : 0.5) : Color.primary.opacity(deg == -30 || deg == 60 ? 1 : 0.5))
                    .font(deg == -30 || deg == 60 ? .largeTitle : .title2)
                    .offset(y: 150)
                    .rotationEffect(.degrees(30))
                    .onTapGesture {
                        if deg != -30 {
                            withAnimation(.bouncy) {
                                deg -= 30
                            }
                        }
                    }
                
                // Home icon (again)
                Image(systemName: personalization.customHome ? personalization.customIcon : "house")
                    .fontWeight(.heavy)
                    .foregroundStyle(personalization.customColor ? personalization.mainColor.opacity(deg == 0 ? 1 : 0.5) : Color.primary.opacity(deg == 0 ? 1 : 0.5))
                    .font(deg == 0 ? .largeTitle : .title2)
                    .offset(y: 150)
                    .rotationEffect(.degrees(0))
                    .onTapGesture {
                        withAnimation(.bouncy) {
                            deg = 0
                        }
                    }
                
                // Checkmark icon (again)
                Image(systemName: "checkmark.circle")
                    .fontWeight(.heavy)
                    .foregroundStyle(personalization.customColor ? personalization.mainColor.opacity(deg == -60 || deg == 30 ? 1 : 0.5) : Color.primary.opacity(deg == -60 || deg == 30 ? 1 : 0.5))
                    .font(deg == -60 || deg == 30 ? .largeTitle : .title2)
                    .offset(y: 150)
                    .rotationEffect(.degrees(-30))
                    .onTapGesture {
                        if deg != 30 {
                            withAnimation(.bouncy) {
                                deg += 30
                            }
                        }
                    }
                
                // Gear icon (again)
                Image(systemName: "gear")
                    .fontWeight(.heavy)
                    .foregroundStyle(personalization.customColor ? personalization.mainColor.opacity(deg == 60 || deg == -30 ? 1 : 0.5) : Color.primary.opacity(deg == 60 || deg == -30 ? 1 : 0.5))
                    .font(deg == 60 || deg == -30 ? .largeTitle : .title2)
                    .offset(y: 150)
                    .rotationEffect(.degrees(-60))
                    .onTapGesture {
                        if deg != 60 {
                            withAnimation(.bouncy) {
                                deg += 30
                            }
                        }
                    }
                
                // Home icon (again)
                Image(systemName: personalization.customHome ? personalization.customIcon : "house")
                    .fontWeight(.heavy)
                    .foregroundStyle(personalization.customColor ? personalization.mainColor.opacity(deg == 90 ? 1 : 0.5) : Color.primary.opacity(deg == 90 ? 1 : 0.5))
                    .font(deg == 90 ? .largeTitle : .title2)
                    .offset(y: 150)
                    .rotationEffect(.degrees(-90))
                    .onTapGesture {
                        deg = 0
                    }
            }
            .rotationEffect(.degrees(deg))
            
            // Background rectangle
            Rectangle()
                .fill(RadialGradient(colors: [Color.white.opacity(0), mainColor], center: UnitPoint(x: 0.5, y: 1.2), startRadius: 130, endRadius: 170))
                .frame(height: 260)
                .offset(y: 50)
                .allowsHitTesting(false)
        }
    }
}

