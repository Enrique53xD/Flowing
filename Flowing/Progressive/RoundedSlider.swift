import SwiftUI

struct RoundedSlider: View {
    
    @State var normalHeight: CGFloat = 30
    @State var maxHeight: CGFloat = 60
    @State var currentHeight: CGFloat = 30
    @State var maxWidth: CGFloat = 300
    @State var cornerRadius: CGFloat = 45
    @State var color: Color = .blue
    @State var weightFont: Font = .title3
    
    @Binding var progress: CGFloat
    @Binding var goal: CGFloat
    @Binding var changing: Bool
    @Binding var done: Bool
    
    @State var sliderProgress: CGFloat = 0
    @State var sliderWidth: CGFloat = 0
    @State var lastDragValue: CGFloat = 0
    
    public func update(){
        sliderProgress = progress/goal
        sliderWidth = sliderProgress * maxWidth
        lastDragValue = sliderWidth
    }
    
    var body: some View {
        
        HStack {
            
            Button(action: { withAnimation{ if progress > 0 {progress-=1; update()} } }, label: {
                Image(systemName: "minus")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundStyle(color)
                    .background(RoundedRectangle(cornerRadius: 45) .frame(width: 60, height: 60)
                        .foregroundStyle(color.opacity(0.5)))
                    .frame(width: 60, height: 60)
                
                    .onAppear{if progress >= goal {done=true} else {done=false} }
            })
            
            Spacer()
            
            VStack{
                
                ZStack(alignment: .leading, content: {
                    
                    Rectangle()
                        .fill(color.opacity(0.2))
                    
                    Rectangle()
                        .fill(color.opacity(0.5))
                        .onAppear{
                            update()
                        }
                        .frame(width: sliderWidth)
                    
                })
                
                .frame(width: maxWidth, height: currentHeight, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    
                    Text("\(Int(progress))/\(Int(goal))")
                        .fontWeight(.heavy)
                        .font(weightFont)
                        .foregroundStyle(color)
                        .multilineTextAlignment(.center)
                    
                )
                
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged{ value in
                            
                            let translation = value.translation
                            
                            sliderWidth = translation.width + lastDragValue
                            
                            sliderWidth = sliderWidth > maxWidth ? maxWidth : sliderWidth
                            
                            sliderWidth = sliderWidth >= 0 ? sliderWidth : 0
                            
                            let current = sliderWidth / maxWidth
                            
                            sliderProgress = current <= 1.0 ? current : 1
                            
                            progress = goal * sliderProgress
                            
                            withAnimation{
                                currentHeight = maxHeight
                                weightFont = .title2
                            }
                            
                            
                        }
                        .onEnded{ value in
                            
                            sliderWidth = sliderWidth > maxWidth ? maxWidth : sliderWidth
                            
                            sliderWidth = sliderWidth >= 0 ? sliderWidth : 0
                            
                            lastDragValue = sliderWidth
                            
                            withAnimation{
                                currentHeight = normalHeight
                                weightFont = .title3
                            }
                            
                            
                        }
                    
                )
                
                .simultaneousGesture(LongPressGesture(minimumDuration: 1).onEnded({_ in withAnimation{changing.toggle()}}))
                
            }
            
            Spacer()
            
            Button(action: { withAnimation{ if progress < goal {progress+=1; update()} } }, label: {
                Image(systemName: "plus")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundStyle(color)
                    .background(RoundedRectangle(cornerRadius: 45) .frame(width: 60, height: 60)
                        .foregroundStyle(color.opacity(0.5)))
                    .frame(width: 60, height: 60)
                
                    .onAppear{if progress >= goal {done=true} else {done=false} }
            })
            
            
        }
        .padding(.horizontal)
        
        
        
    }
    
    
    
}


