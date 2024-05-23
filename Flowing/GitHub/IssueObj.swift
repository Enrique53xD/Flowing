//
//  IssueObj.swift
//  Flowing
//
//  Created by Saúl González on 13/05/24.
//


import SwiftUI
import SwiftData
import OctoKit

struct IssueObj: View {
    
    // MARK: - Environment and State Properties
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var login: String
    @State var repoName: String
    @State var num: Int
    @State var config: TokenConfiguration
    @State var textColor: Color
    @State var url: URL
    
    @State var status: String
    @State var name: String
    @State var description: String
    
    @State private var editing = false
    @State private var buttonOpacity = 1.0
    
    @State private var sheetContentHeight = CGFloat(0)
    
    // MARK: - Body View
    
    var body: some View {
        HStack {
            statusImageView
                .delaysTouches(for: 0.05) {
                    withAnimation {
                        if !editing {
                            toggleStatus()
                        }
                    }
                }
                .gesture(longPressGesture)
                .opacity(buttonOpacity)
                .sensoryFeedback(trigger: editing) { _,_  in
                    if editing == true {
                        return .impact
                    } else {
                        return .none
                    }
                }
                .sheet(isPresented: $editing, content: {
                    EditIssue(config: config, login: login, repo: repoName, num: num, color: status == "closed" ? Color.purple : Color.green, name: $name, description: $description, url: url)
                        .presentationDragIndicator(.visible)
                        .padding()
                        .background {
                            // This is done in the background otherwise GeometryReader tends to expand to all the space given to it like color or shape.
                            GeometryReader { proxy in
                                Color.clear
                                    .task {
                                        sheetContentHeight = proxy.size.height
                                    }
                            }
                        }
                        .presentationDetents([.height(sheetContentHeight)])
                })
            
            Text(name)
                .foregroundStyle(textColor)
                .fontDesign(.rounded)
                .font(.title2)
                .strikethrough(status == "closed", color: Color.purple)
                .opacity(status == "closed" ? 0.7 : 1)
                .fontWeight(.bold)
                .lineLimit(1)
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    // MARK: - Status Image View
    
    var statusImageView: some View {
        Image(systemName: status == "closed" ? "checkmark.circle" : "smallcircle.filled.circle")
            .font(.title)
            .fontWeight(.heavy)
            .foregroundStyle(
                (colorScheme == .dark ? (status == "closed" ? Color.black.opacity(0.5) : Color.green) : (status == "closed" ? Color.white.opacity(0.5) : Color.purple))
            )
            .background(
                RoundedRectangle(cornerRadius: 45)
                    .frame(width: 60, height: 60)
            )
            .foregroundStyle(
                (status == "closed" ? Color.purple : Color.green.opacity(0.5))
            )
            .frame(width: 60, height: 60)
    }
    
    // MARK: - Long Press Gesture
    
    var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.2)
            .onChanged({_ in
                withAnimation(.linear(duration: 0.1)){
                    buttonOpacity = 0.1
                }
                withAnimation(.linear(duration: 0.4)){
                    buttonOpacity = 1
                }
                
            })
            .onEnded(){_ in
                withAnimation{
                    editing.toggle()
                    
                }
            }
    }
    
    // MARK: - Toggle Status
    
    func toggleStatus() {
        if status == "open" {
            status = "closed"
            updateStatus(to: .closed)
        } else {
            status = "open"
            updateStatus(to: .open)
        }
    }
    
    // MARK: - Update Status
    
    func updateStatus(to state: Openness) {
        Octokit(config).patchIssue(owner: login, repository: repoName, number: num, state: state) { response in
            switch response {
            case .success(let issue):
                print(state == .open ? "opened" : "closed")
            case .failure:
                print("error")
            }
        }
    }
}
