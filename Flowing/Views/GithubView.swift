//
//  GithubView.swift
//  Flowing
//
//  Created by Saúl González on 7/05/24.
//

import SwiftUI
import OctoKit

struct GithubView: View {
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
                            .frame(height: 30)
                            .onTapGesture {
                                withAnimation(.spring(bounce: 0.2)){
                                    showIssues[repo.name] = !(showIssues[repo.name] ?? false)
                                }
                            }
                        
                        // Display the issues of the repository
                        if showIssues[repo.name] ?? false {
                            ForEach(Array(repo.issues.sorted(by: { $0.state!.rawValue > $1.state!.rawValue }).enumerated()), id: \.offset) { index, issue in
                                IssueObj(login: login ?? "",
                                         repoName: repo.name,
                                         num: issue.number,
                                         config: config,
                                         textColor: customTextColor ? textColor : Color.primary,
                                         url: issue.htmlURL!,
                                         status: issue.state?.rawValue ?? "",
                                         name: issue.title ?? "",
                                         description: issue.body ?? "")
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
            
            RoundedRectangle(cornerRadius: 5)
                .foregroundStyle(customColor ? mainColor : defaultColor)
                .opacity(0.5)
                .frame(height: 7)
                .padding([.top, .horizontal])
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0)
                        .scaleEffect(phase.isIdentity ? 1 : 0.75)
                        .blur(radius: phase.isIdentity ? 0 : 10)
                }
        }
    }
}
