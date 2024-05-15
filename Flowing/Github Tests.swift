//
//  Github Tests.swift
//  Flowing
//
//  Created by Saúl González on 7/05/24.
//

import SwiftUI
import OctoKit


struct Github_Tests: View {
    @Binding var customTextColor: Bool
    @Binding var textColor: Color
    
    @State var config: TokenConfiguration
    @Binding var login: String?
    @Binding var repos: [reposWithIssues]
    
    @State var showIssues: [String: Bool] = [:]
    
    var body: some View {
        
        
        VStack {
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
                
           
            
                
            ForEach(repos, id: \.self) { repo in
                    VStack {
                        
                        
                            
                        if !repo.issues.isEmpty {
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
                                    withAnimation(.bouncy){
                                        showIssues[repo.name] = !(showIssues[repo.name] ?? false)
                                    }
                                }
                            
                            
                            
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
