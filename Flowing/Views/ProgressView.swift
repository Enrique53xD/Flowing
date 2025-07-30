//
//  ProgressView.swift
//  Flowing
//
//  Created for dedicated progress tracking
//

import SwiftUI
import SwiftData

struct ProgressView: View {
    //Environment Variables
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var context
    
    //State Variables
    @Binding var personalization: personalizationVariables
    @Binding var objects: taskObjectVariables
    @Binding var creation: creatingVariables
    
    //Fetch Request
    @Query(sort: \progressiveItem.name) private var progressiveItems: [progressiveItem]
    
    @State private var buttonSize = 1.0
    @State private var buttonOpacity = 1.0
    
    var body: some View {
        ScrollView {
            VStack {
                // Display Progressive Items
                ForEach(progressiveItems) { item in
                    ProgressiveObj(item: item, context: context, textColor: personalization.customTextColor ? personalization.textColor : Color.primary)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                .blur(radius: phase.isIdentity ? 0 : 10)
                        }
                }
                
                // Add Progressive Button
                Button(action: {
                    withAnimation(.bouncy) {
                        if creation.creatingSome {
                            creation.creatingSome.toggle()
                            creation.creatingProgressive.toggle()
                        }
                    }
                }, label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .fontWeight(.black)
                        .frame(width: 358, height: creation.creatingSome ? 60 : 0)
                        .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                        .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(personalization.customColor ? personalization.mainColor : Color.primary))
                        .padding()
                        .sensoryFeedback(.impact(intensity: creation.creatingProgressive ? 0 : 1), trigger: creation.creatingProgressive)
                })
                .padding(0)
                .opacity(creation.creatingSome ? 1 : 0)
                .scaleEffect(buttonSize)
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.8).onEnded({_ in 
                    withAnimation(.bouncy) {
                        creation.creatingSome.toggle()
                    }
                }))
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0)
                        .scaleEffect(phase.isIdentity ? 1 : 0.75)
                        .blur(radius: phase.isIdentity ? 0 : 10)
                }
                .sheet(isPresented: $creation.creatingProgressive, content: {
                    CreateProgressive(context: context)
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
        .animation(.bouncy, value: progressiveItems)
        .scrollClipDisabled()
        .scrollIndicators(.hidden)
        .frame(height: UIScreen.screenHeight-150)
        .offset(y: 50)
    }
}