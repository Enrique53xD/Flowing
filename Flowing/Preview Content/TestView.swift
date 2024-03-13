//
//  TestView.swift
//  Flowing
//
//  Created by Saúl González on 13/03/24.
//

import SwiftUI

struct TestView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {withAnimation{}}, label: {
            
            Text("DELETE")
                .font(.title2)
                .fontWeight(.heavy)
                .frame(width: 300, height: 60)
                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                .background(RoundedRectangle(cornerRadius: 10).foregroundStyle(Color.red))
            
            
        })

    }
}

#Preview {
    TestView()
}
