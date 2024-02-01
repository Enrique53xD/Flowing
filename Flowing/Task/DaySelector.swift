import SwiftUI



struct DaySelector: View {
    
    @Binding var days: [Day]
    @Binding var color: Color
    
    var body: some View {
        
        HStack {
            
            ForEach(days) { day in
                Button(action: {
                    withAnimation {
                        if let index = days.firstIndex(where: { $0.id == day.id }) {
                            days[index].isSelected.toggle()
                        }
                    }
                }, label: {
                    Text(day.name.prefix(1))
                        .fontWeight(.heavy)
                        .font(.title2)
                        .foregroundStyle(color)
                })
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .frame(width: 42, height: 42)
                        .foregroundStyle(day.isSelected == true ? Color.gray.opacity(0.5) : Color.gray.opacity(0))
                )
            }
            
        }
        
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.gray.opacity(0.3))
        )
    }
}


   

