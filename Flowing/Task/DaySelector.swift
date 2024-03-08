import SwiftUI

struct DaySelector: View {
    
    @Binding var days: String
    @Binding var color: Color
    private let letters = "MTWTFSS"
    
    
    var body: some View {
        HStack {
            dayButtons
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.gray.opacity(0.3))
        )
    }
    
    private var dayButtons: some View {
        ForEach(Array(days.enumerated()), id: \.offset) { day in
            dayButton(day)
        }
    }
    
    private func dayButton(_ day: (offset: Int, element: Character)) -> some View {
        Button(action: {
            withAnimation {
                toggleBinaryAtIndex(day.offset)
            }
        }) {
            Text(String(letters[letters.index(letters.startIndex, offsetBy: day.offset)]))
                .fontWeight(.heavy)
                .font(.title2)
                .foregroundStyle(color)
        }
        .frame(width: 36, height: 36)
        .background(
            Circle()
                .frame(width: 42, height: 42)
                .foregroundStyle(String(day.element) == "0" ? Color.gray.opacity(0.0001) : Color.gray.opacity(0.5))
        )
    }
    
    private func toggleBinaryAtIndex(_ index: Int) {
        let currentIndex = days.index(days.startIndex, offsetBy: index)
        
        guard days.indices.contains(currentIndex) else { return }
        
        days = String(days.prefix(upTo: currentIndex)) +
            (days[currentIndex] == "0" ? "1" : "0") +
            String(days.suffix(from: days.index(after: currentIndex)))
    }
}
