//
//  Github Tests.swift
//  Flowing
//
//  Created by Saúl González on 7/05/24.
//

import SwiftUI
import OctoKit

struct Github_Tests: View {
    //Environment Variables
    @Environment(\.colorScheme) var colorScheme
    @Binding var customTextColor: Bool
    @Binding var textColor: Color
    
    //State Variables
    @State var config: TokenConfiguration
    @Binding var login: String?
    @Binding var repos: [reposWithIssues]
    @State var showIssues: [String: Bool] = [:]
    @State private var sheetContentHeight = CGFloat(0)
    @State var customColor = false
    @State var mainColor = Color.primary
    @State var defaultColor = Color.primary
    
    var body: some View {
        VStack {
            // Display the login name
            Text(login ?? "...")
                .fontDesign(.rounded)
                .foregroundStyle(customTextColor ? textColor : Color.primary)
                .font(.title)
                .opacity(0.5)
                .fontWeight(.heavy)
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0)
                        .scaleEffect(phase.isIdentity ? 1 : 0.75)
                        .blur(radius: phase.isIdentity ? 0 : 10)
                }
                .frame(height: 40)
                .padding(.bottom)
            
            // Display the repositories and their issues
            ForEach(repos, id: \.self) { repo in
                VStack {
                    if !repo.issues.isEmpty {
                        // Display the repository name
                        Text(repo.name)
                            .fontDesign(.rounded)
                            .foregroundStyle(customTextColor ? textColor : Color.primary)
                            .font(.title2)
                            .opacity(showIssues[repo.name] ?? false ? 0.5 : 1.0)
                            .fontWeight(.heavy)
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                    .blur(radius: phase.isIdentity ? 0 : 10)
                            }
                            .frame(height: 20)
                            .onTapGesture {
                                withAnimation(.spring(bounce: 0.2)){
                                    showIssues[repo.name] = !(showIssues[repo.name] ?? false)
                                }
                            }
                        
                        // Display the issues of the repository
                        if showIssues[repo.name] ?? false {
                            ForEach(repo.issues.sorted(by: { $0.state!.rawValue > $1.state!.rawValue }), id: \.self) { issu in
                                IssueObj(login: login ?? "", repoName: repo.name, num: issu.number, config: config, textColor: customTextColor ? textColor : Color.primary, url: issu.htmlURL!, status: issu.state?.rawValue ?? "", name: issu.title ?? "", description: issu.body ?? "")
                                    .scrollTransition { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1 : 0)
                                            .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                            .blur(radius: phase.isIdentity ? 0 : 10)
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
}
