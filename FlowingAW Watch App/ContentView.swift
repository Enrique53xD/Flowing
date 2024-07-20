import SwiftUI

class publicVars: ObservableObject {
    @Published var time = 0
}

struct ContentView: View {
    @StateObject var phoneConnection = PhoneConnection()
    @State private var scrolledToUndone = false
    @State private var timer: Timer?
    @StateObject var vars = publicVars()
    
    var firstUndoneTaskId: String? {
        phoneConnection.tasks.first(where: { $0.end >= vars.time })?.id
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(phoneConnection.tasks) { task in
                    HStack {
                        CircleSymbol(symbol: task.symbol, color: task.color, end: task.end, desc: task.desc)
                            .environmentObject(vars)
                        
                        VStack(alignment: .leading) {
                            Text(task.name)
                                .lineLimit(2)
                                .fontDesign(.rounded)
                                .opacity((task.end < vars.time) ? 0.7 : 1)
                                .fontWeight(.heavy)
                            
                            Text("\(formatTaskTime(start: task.start, end: task.end))")
                                .fontWeight(.heavy)
                                .fontDesign(.rounded)
                                .font(.system(size: 11))
                                .opacity(0.7)
                        }
                    }
                    .id(task.id)
                    .listRowBackground(Color.clear)
                    .padding()
                    .padding([.top, .bottom], 5)
                }
            }
            .listStyle(.carousel)
            .onAppear {
                vars.time = minutesPassedToday()
                loadTasksFromUserDefaults()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    scrollToFirstUndoneTask(proxy: proxy)
                }
                
                timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                    withAnimation() {
                        vars.time = minutesPassedToday()
                    }
                }
            }
            .onDisappear{
                timer?.invalidate()
            }
            .onChange(of: firstUndoneTaskId) {
                scrolledToUndone = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    scrollToFirstUndoneTask(proxy: proxy)
                }
            }
        }
    }
    
    private func isDone(end: Int) -> Bool {
        if end < minutesPassedToday() {
            return true
        } else {
            return false
        }
    }
    
    private func minutesPassedToday() -> Int {
        // Get the current date and time
        let now = Date()

        // Get the start of today (midnight)
        let today = Calendar.current.startOfDay(for: now)

        // Calculate the time interval between the start of today and now
        let interval = now.timeIntervalSince(today)

        // Convert the interval to minutes
        let minutes = Int(interval / 60)

        return minutes
    }
    
    private func loadTasksFromUserDefaults() {
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
    
    private func scrollToFirstUndoneTask(proxy: ScrollViewProxy) {
        if let id = firstUndoneTaskId, !scrolledToUndone {
            withAnimation(.easeInOut(duration: 0.5)) {
                proxy.scrollTo(id, anchor: .center)
            }
            scrolledToUndone = true
        }
    }
}

func formatTaskTime(start: Int, end: Int) -> String {
    if start == end {
        return "\(transformMinutes(minute: start))"
    } else {
        return "\(transformMinutes(minute: start)) - \(transformMinutes(minute: end))"
    }
}

func transformMinutes(minute: Int) -> String {
    var minutes = minute
    var hours = 0
    
    while minutes >= 60 {
        minutes -= 60
        hours += 1
    }
    
    return "\(String(format: "%02d", hours)):\(String(format: "%02d", minutes))"
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
    @State var end: Int
    @State var editing: Bool = false
    @State var desc: String
    @EnvironmentObject var vars: publicVars
    
    @State var tapAction = {}
    @State var holdAction = {}
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 45)
                .frame(width: 70*buttonSize, height: 70*buttonSize)
                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                .opacity(buttonOpacity)
            
            Image(systemName: symbol)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundStyle(
                    (colorScheme == .dark ? ((end < vars.time) ? Color.black.opacity(0.5) : Color(hex: color)) : ((end < vars.time) ? Color.white.opacity(0.5) : Color(hex: color))) ?? Color.clear
                )
                .background(
                    RoundedRectangle(cornerRadius: 45)
                        .frame(width: 70, height: 70)
                )
                .foregroundStyle(
                    ((end < vars.time) ? Color(hex: color) : Color(hex: color)?.opacity(0.5)) ?? Color.clear
                )
                .alert(desc == "" ? "No description" : desc, isPresented: $editing) {
                           Button("OK", role: .cancel) { }
                       }
                .scaleEffect(buttonSize)
                .frame(width: 70, height: 70)
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


