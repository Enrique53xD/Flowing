//
//  Others.swift
//  Flowing
//
//  Created by Saúl González on 13/03/24.
//

import SwiftUI
import SwiftData


struct CircleSymbol: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var buttonSize = 1.0
    @State private var buttonOpacity = 1.0
    @Binding var symbol: String
    @Binding var color: String
    @Binding var done: Bool
    @Binding var editing: Bool
    
    @State var tapAction = {}
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 45)
                .frame(width: 60*buttonSize, height: 60*buttonSize)
                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                .opacity(buttonOpacity)
            
            Image(systemName: symbol)
                .font(.title)
                .fontWeight(.heavy)
                .foregroundStyle(
                    (colorScheme == .dark ? (done ? Color.black.opacity(0.5) : Color(hex: color)) : (done ? Color.white.opacity(0.5) : Color(hex: color))) ?? Color.clear
                )
                .background(
                    RoundedRectangle(cornerRadius: 45)
                        .frame(width: 60, height: 60)
                )
                .foregroundStyle(
                    (done ? Color(hex: color) : Color(hex: color)?.opacity(0.5)) ?? Color.clear
                )
                .scaleEffect(buttonSize)
                .frame(width: 60, height: 60)
                .onTapGesture{
                        withAnimation(.bouncy) {
                            if !editing {
                                tapAction()
                            }
                        }
                    
                }
                .onLongPressGesture(minimumDuration: 0.2, maximumDistance: 10.0, pressing: { pressing in
                    withAnimation(.bouncy) {
                        buttonOpacity = pressing ? 0.5 : 1
                        buttonSize = pressing ? 0.9 : 1
                    }
                    
                }) {
                    withAnimation(.bouncy) {
                        buttonOpacity = 1
                        buttonSize = 1
                        editing.toggle()
                    }
                }
                

                .opacity(buttonOpacity)
                .sensoryFeedback(trigger: editing) { _, _  in
                    if editing {
                        return .impact
                    } else {
                        return .none
                    }
                }
        }
    }
}

