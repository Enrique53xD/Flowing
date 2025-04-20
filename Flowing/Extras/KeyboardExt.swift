//
//  KeyboardExt.swift
//  Flowing
//
//  Created by Saúl González on 12/04/25.
//

import SwiftUI
import Combine

// View modifier to dismiss keyboard when tapping outside
struct DismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}

// Extension to make the modifier easier to use
extension View {
    func dismissKeyboardOnTap() -> some View {
        self.modifier(DismissKeyboardOnTap())
    }
    
    // Function to hide the keyboard that can be called programmatically
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
