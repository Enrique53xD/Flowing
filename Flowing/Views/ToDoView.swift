//
//  ToDoView.swift
//  Flowing
//
//  Created by Saúl González on 22/05/24.
//

import SwiftUI
import SwiftData

struct ToDoView: View {
    //Environment Variables
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var context
    
    //State Variables
    @Binding var personalization: personalizationVariables
    @Binding var objects: taskObjectVariables
    @Binding var creation: creatingVariables
    
    //Fetch Request
    @Query(sort: \toDoItem.name) private var toDoItems: [toDoItem]
    @Query(sort: \progressiveItem.name) private var progressiveItems: [progressiveItem]
    
    @State private var buttonSize = 1.0
    @State private var buttonOpacity = 1.0
    
    var body: some View {
        VStack {
            // Display ToDo Items
            ForEach(toDoItems) { item in
                ToDoObj(item: item, context: context, textColor: personalization.customTextColor ? personalization.textColor : Color.primary)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .scaleEffect(phase.isIdentity ? 1 : 0.75)
                            .blur(radius: phase.isIdentity ? 0 : 10)
                    }
            }
            
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
            
            // Buttons
            HStack {
                // Checkmark Button
                Button(action: {
                    if creation.creatingSome {
                        withAnimation(.bouncy) {
                            creation.creatingSome.toggle()
                            creation.creatingToDo.toggle()
                        }
                    }
                }, label: {
                    Image(systemName: "checkmark.circle")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .frame(width: creation.creatingSome ? 170 : 0, height: 60)
                        .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                        .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(personalization.customColor ? personalization.mainColor : Color.primary))
                })
                .padding(0)
                .frame(width: creation.creatingSome ? 170 : 0)
                .opacity(creation.creatingSome ? 1 : 0)
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.8).onEnded({_ in withAnimation(.bouncy){creation.creatingSome.toggle()}}))
                .sheet(isPresented: $creation.creatingToDo){
                    CreateToDo(context: context)
                        .presentationDragIndicator(.visible)
                        .padding()
                        .background {
                            //This is done in the background otherwise GeometryReader tends to expand to all the space given to it like color or shape.
                            GeometryReader { proxy in
                                Color.clear
                                    .task {
                                        objects.sheetContentHeight = proxy.size.height
                                    }
                            }
                        }
                        .presentationDetents([.height(objects.sheetContentHeight)])
                }
                
                if creation.creatingSome { Spacer() }
                
                // Plus Button

                    Image(systemName: "plus")
                        .font(.title)
                        .fontWeight(.black)
                        .frame(width: creation.creatingSome ? 0 : 358, height: 60)
                        .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                        .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(personalization.customColor ? personalization.mainColor.opacity(buttonOpacity) : Color.primary.opacity(buttonOpacity)))
                        .sensoryFeedback(.impact(), trigger: creation.creatingSome)
                        .opacity(creation.creatingSome ? 0 : 1)
                        .scaleEffect(buttonSize)
                        .onTapGesture{
                            withAnimation(.bouncy) {
                                creation.creatingSome.toggle()
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
                            }
                        }

                .padding(0)
                
                if creation.creatingSome { Spacer() }
                
                // Circle Dotted Button
                Button(action: {
                    if creation.creatingSome {
                        withAnimation(.bouncy){
                            creation.creatingSome.toggle()
                            creation.creatingProgressive.toggle()
                        }
                    }
                }, label: {
                    Image(systemName: "circle.dotted")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .frame(width: creation.creatingSome ? 170 : 0, height: 60)
                        .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                        .background(RoundedRectangle(cornerRadius: 45).foregroundStyle(personalization.customColor ? personalization.mainColor : Color.primary))
                })
                .padding(0)
                .frame(width: creation.creatingSome ? 170 : 0)
                .opacity(creation.creatingSome ? 1 : 0)
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.8).onEnded({_ in withAnimation(.bouncy){creation.creatingSome.toggle()}}))
                .sheet(isPresented: $creation.creatingProgressive){
                    CreateProgressive(context: context)
                        .presentationDragIndicator(.visible)
                        .padding()
                        .background {
                            //This is done in the background otherwise GeometryReader tends to expand to all the space given to it like color or shape.
                            GeometryReader { proxy in
                                Color.clear
                                    .task {
                                        objects.sheetContentHeight = proxy.size.height
                                    }
                            }
                        }
                        .presentationDetents([.height(objects.sheetContentHeight)])
                }
            }
            .padding(creation.creatingSome ? [.horizontal, .top] : [.top])
            .scrollTransition { content, phase in
                content
                    .opacity(phase.isIdentity ? 1 : 0)
                    .scaleEffect(phase.isIdentity ? 1 : 0.75)
                    .blur(radius: phase.isIdentity ? 0 : 10)
            }
        }
        .animation(.bouncy, value: toDoItems)
        .animation(.bouncy, value: progressiveItems)
    }
}
