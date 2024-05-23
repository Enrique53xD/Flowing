//
//  CreateIssue.swift
//  Flowing
//
//  Created by Saúl González on 16/05/24.
//

import SwiftUI
import SymbolPicker
import SwiftData
import OctoKit

struct CreateIssue: View {
    // Environment variables
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) private var openURL
    
    // State variables
    @State var config: TokenConfiguration
    @State var login: String
    @State var repo: String = ""
    @State var repos: [String] = []
    @State var num: Int?
    
    @State var color = Color.green
    @State var name: String = ""
    @State var description: String = ""
    @State var symbol = "smallcircle.filled.circle"
    @State var url: URL?
    
    @State var deleted = false
    
    @State private var symbolPicking = false
    @FocusState private var descripting: Bool
    @FocusState private var naming: Bool
    
    @State var buttonOpacity = 1.0
    @State var buttonProgress = 0.0
    @State var hasPressed = false
    
    var body: some View {
        VStack {
            // Name TextField
            HStack {
                TextField("Name", text: $name)
                    .font(.title)
                    .fontDesign(.rounded)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(5)
                    .background(Color.gray.opacity(0.3))
                    .focused($naming)
                    .onTapGesture {
                        withAnimation {
                            naming = true
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
            }
            .padding(.horizontal)
            .padding(.vertical, 7)
            
            // Repo Picker
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .frame(height: 32)
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
                    .padding(.horizontal)
                
                Picker("Select a repo", selection: $repo) {
                    ForEach(repos, id: \.self) {
                        Text($0)
                            .font(.title2)
                            .fontDesign(.rounded)
                            .fontWeight(.bold)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 90)
                .padding(.horizontal, 6.5)
                .padding(.vertical, 7)
            }
            
            // Description TextField
            TextField("Description...", text: $description, axis: .vertical)
                .font(.title2)
                .fontDesign(.rounded)
                .padding(10)
                .frame(height: 150, alignment: .top)
                .background(Color.gray.opacity(0.3))
                .focused($descripting)
                .onTapGesture {
                    withAnimation {
                        descripting = true
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                .padding(.horizontal)
                .padding(.vertical, 7)
        }
        .scrollDisabled(true)
        .onAppear {
            // Fetch repositories on view appear
            Task {
                let tempRepos = try await Octokit(config).repositories()
                repo = tempRepos.first?.name ?? "null"
                for i in tempRepos {
                    print(i)
                    repos.append(i.name ?? "null")
                }
            }
        }
        .onDisappear {
            // Call createIssue() on view disappear
            createIssue()
        }
    }
    
    func createIssue() {
        if name != "" {
            // Create issue using Octokit
            Octokit(config).postIssue(owner: login, repository: repo, title: name, body: description) { response in
                switch response {
                case .success(let issue):
                    print("Issue created")
                case .failure:
                    print("Failed to create issue")
                }
            }
        }
    }
}



