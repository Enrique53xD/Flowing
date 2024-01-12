//
//  EditTask.swift
//  Flowing
//
//  Created by Saúl González on 11/01/24.
//

import SwiftUI

struct EditTask: View {
    @State var color = Color.blue
    @State var name = "name"
    @State var start = 440
    @State var end = 441
    
    var body: some View {
        VStack{
            HStack{
                ColorPicker(selection: $color, label: {Text("")})
                    .labelsHidden()
                
                TextField("\(name)", text: $name)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                
            }
        }
    }
}

#Preview {
    EditTask()
}
