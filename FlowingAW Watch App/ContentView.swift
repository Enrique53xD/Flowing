import SwiftUI

struct ContentView: View {
    @StateObject var phoneConnection = PhoneConnection()
    
    var body: some View {
        ScrollView {
            ForEach(phoneConnection.tasks) { task in
                VStack {
                    CircleSymbol(symbol: task.symbol, color: task.color, done: task.done, desc: task.desc)
                        
                    Text(task.name)
                        .fontWeight(.heavy)
                        
                }
                
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0)
                        .scaleEffect(phase.isIdentity ? 1 : 0.75)
                        .blur(radius: phase.isIdentity ? 0 : 10)
                }
            }
        }
        .scrollClipDisabled()
        .padding()
        .onAppear {
            // Try to load tasks from UserDefaults when the view appears
            if let storedTasksData = UserDefaults.standard.data(forKey: "tasks") {
                do {
                    let decodedTasks = try JSONDecoder().decode([taskItem].self, from: storedTasksData)
                    phoneConnection.tasks = decodedTasks
                    print("Loaded \(decodedTasks.count) tasks from UserDefaults")
                } catch {
                    print("Error decoding stored tasks: \(error)")
                }
            }
        }
    }
}

// Extension to convert a Color variable to a hex
extension Color {
    func toHex() -> String? {
        let uic = UIColor(self)
        
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if a != Float(1.0) {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}

// Extension to convert hex to a Color variable
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}

struct CircleSymbol: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var buttonSize = 1.0
    @State private var buttonOpacity = 1.0
    @State var symbol: String
    @State var color: String
    @State var done: Bool
    @State var editing: Bool = false
    @State var desc: String
    
    @State var tapAction = {}
    @State var holdAction = {}
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 45)
                .frame(width: 80*buttonSize, height: 80*buttonSize)
                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                .opacity(buttonOpacity)
            
            Image(systemName: symbol)
                .font(.title)
                .fontWeight(.heavy)
                .foregroundStyle(
                    (colorScheme == .dark ? (done ? Color.black.opacity(0.5) : Color(hex: color)) : (done ? Color.white.opacity(0.5) : Color(hex: color))) ?? Color.clear
                )
                .background(
                    RoundedRectangle(cornerRadius: 45)
                        .frame(width: 80, height: 80)
                )
                .foregroundStyle(
                    (done ? Color(hex: color) : Color(hex: color)?.opacity(0.5)) ?? Color.clear
                )
                .alert(desc == "" ? "No description" : desc, isPresented: $editing) {
                           Button("OK", role: .cancel) { }
                       }
                .scaleEffect(buttonSize)
                .frame(width: 80, height: 80)
                .onTapGesture{
                        withAnimation(.bouncy) {
                            if !editing {
                                tapAction()
                            }
                        }
                    
                }
                .onLongPressGesture(minimumDuration: 0.2, maximumDistance: 10.0, pressing: { pressing in
                    withAnimation(.bouncy) {
                        buttonOpacity = pressing ? 0.5 : 1
                        buttonSize = pressing ? 0.9 : 1
                    }
                    
                }) {
                    withAnimation(.bouncy) {
                        buttonOpacity = 1
                        buttonSize = 1
                        editing.toggle()
                        holdAction()
                    }
                }
                

                .opacity(buttonOpacity)
                .sensoryFeedback(trigger: editing) { _, _  in
                    if editing {
                        return .impact
                    } else {
                        return .impact
                    }
                }
        }
    }
}


