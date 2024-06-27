//
//  EditIssue.swift
//  Flowing
//
//  Created by Saúl González on 13/05/24.
//

import SwiftUI
import SymbolPicker
import SwiftData
import OctoKit

struct EditIssue: View {
    // Environment variables
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) private var openURL
    
    // State variables
    @State var config: TokenConfiguration
    @State var login: String
    @State var repo: String
    @State var num: Int
    
    @State var color = Color.green
    @Binding var name: String
    @Binding var description: String
    @State var symbol = "smallcircle.filled.circle"
    @State var url: URL
    
    @State var deleted = false
    
    @State private var symbolPicking = false
    @FocusState private var descripting: Bool
    @FocusState private var naming: Bool
    
    @State var buttonOpacity = 1.0
    @State var buttonProgress = 0.0
    @State var hasPressed = false
    
    var body: some View {
        VStack{
            // Name TextField
            HStack{
                TextField("Name", text: $name)
                    .font(.title)
                    .fontDesign(.rounded)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(5)
                    .background(Color.gray.opacity(0.3))
                    .focused($naming)
                    .onTapGesture {
                        withAnimation{
                            naming = true
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
            }
            .padding(.horizontal)
            .padding(.vertical, 7)
            
            // Description TextField
            TextField("Description...", text: $description, axis: .vertical)
                .font(.title2)
                .fontDesign(.rounded)
                .padding(10)
                .frame(height: 150, alignment: .top)
                .background(Color.gray.opacity(0.3))
                .focused($descripting)
                .onTapGesture {
                    withAnimation{
                        descripting = true
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                .padding(.horizontal)
                .padding(.vertical, 7)
            
            HStack{
                if !naming && !descripting {
                    // Button
                    ZStack {
                        ZStack(alignment: .leading){
                            Rectangle().foregroundStyle(color)
                                .frame(width: buttonProgress, height: 60)
                            
                            Rectangle().foregroundStyle(color)
                                .frame(width: 330, height: 60)
                                .opacity(buttonOpacity)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                        
                        Text("Open on GitHub")
                            .fontDesign(.rounded)
                            .font(.title2)
                            .fontWeight(.heavy)
                            .frame(width: 330, height: 60)
                            .background(RoundedRectangle(cornerRadius: 12.5).foregroundStyle(color.opacity(0.01)))
                            .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                            .sensoryFeedback(.impact, trigger: deleted)
                            .onLongPressGesture(minimumDuration: 2, maximumDistance: 20, pressing: {
                                pressing in
                                self.hasPressed = pressing
                                if pressing {
                                    withAnimation{
                                        buttonOpacity = 0.5
                                    }
                                    withAnimation(.easeOut(duration: 2)){
                                        buttonProgress = 330
                                    }
                                }
                                if !pressing {
                                    withAnimation(.easeInOut){
                                        buttonOpacity = 1
                                        buttonProgress = 0
                                    }
                                }
                            }, perform: {deleted = true; openURL(url)})
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 7)
        }
        .scrollDisabled(true)
        .onDisappear{
            updateIssue()
        }
    }
    
    // Function to update the issue
    func updateIssue() {
        Octokit(config).patchIssue(owner: login, repository: repo, number: num, title: name, body: description) { response in
            switch response {
            case .success(_):
                print("edited")
            case .failure:
                print("")
            }
        }
    }
}
