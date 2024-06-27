//
//  Customs.swift
//  Flowing
//
//  Created by Saúl González on 23/06/24.
//

import SwiftUI

struct ProgressCircle: View {
    let progress: Double
    var color: Color?
    var lineWidth: Double?
    
    var body: some View {
        ZStack {
            Circle()
                .stroke((color ?? Color.primary).opacity(0.5), lineWidth: (lineWidth ?? 30))
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke((color ?? Color.primary), style: StrokeStyle(lineWidth: (lineWidth ?? 30), lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

struct tries: View {
    @State var coso = 0.0
    
    var body: some View {
        
        Button(action: {withAnimation(.easeInOut(duration: 1)){coso = 0.75}}, label: {Text("AAA")})
        
        ProgressCircle(progress: coso)
            .frame(width: 200, height: 200)

    }
}

#Preview {
    tries()
}
