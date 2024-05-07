import SwiftUI
import SwiftData

struct RoundedSlider: View {
    
    var item: progressiveItem
    var context: ModelContext
    
    @State var normalHeight: CGFloat = 30
    @State var maxHeight: CGFloat = 60
    @State var currentHeight: CGFloat = 30
    @State var maxWidth: CGFloat = 300
    @State var cornerRadius: CGFloat = 45
    @State var color: Color = .blue
    @State var weightFont: Font = .title3
    
    @State var progressing: Bool = false
    
    @Binding var changing: Bool
    @Binding var done: Bool
    
    @State var sliderProgress: CGFloat = 0
    @State var sliderWidth: CGFloat = 0
    @State var lastDragValue: CGFloat = 0
    
    public func update(){
        sliderProgress = item.progress/item.goal
        sliderWidth = sliderProgress * maxWidth
        lastDragValue = sliderWidth
    }
    
    var body: some View {
        
        HStack {
            
            Button(action: { withAnimation{ if item.progress >= 1 {item.progress = (item.progress.rounded(.down)-1); update()} } }, label: {
                Image(systemName: "minus")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundStyle(color)
                    .background(RoundedRectangle(cornerRadius: 45) .frame(width: 60, height: 60)
                        .foregroundStyle(color.opacity(0.5)))
                    .frame(width: 60, height: 60)
                
                    .onAppear{
                       
                        if item.progress >= item.goal {done=true} else {done=false}
                    }
            })
            .buttonRepeatBehavior(.enabled)
            
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
                    
                    Text("\(Int(item.progress))/\(Int(item.goal))")
                        .fontWeight(.heavy)
                        .fontDesign(.rounded)
                        .font(weightFont)
                        .foregroundStyle(color)
                        .multilineTextAlignment(.center)
                    
                )
                
                .gesture(
                    DragGesture(minimumDistance: 1)
                        .onChanged{ value in
                            
                            progressing = true
                            
                            withAnimation(.easeIn(duration: 0.1)){
                                let translation = value.translation
                                
                                sliderWidth = translation.width + lastDragValue
                                
                                sliderWidth = sliderWidth > maxWidth ? maxWidth : sliderWidth
                                
                                sliderWidth = sliderWidth >= 0 ? sliderWidth : 0
                                
                                let current = sliderWidth / maxWidth
                                
                                sliderProgress = current <= 1.0 ? current : 1
                                
                                item.progress = item.goal * sliderProgress
                            }
                            
                            withAnimation(.bouncy){
                                currentHeight = maxHeight
                                weightFont = .title2
                            }
                            
                            
                        }
                        .onEnded{ value in
                            
                            progressing = false
                            
                            sliderWidth = sliderWidth > maxWidth ? maxWidth : sliderWidth
                            
                            sliderWidth = sliderWidth >= 0 ? sliderWidth : 0
                            
                            lastDragValue = sliderWidth
                            
                            withAnimation(.bouncy){
                                currentHeight = normalHeight
                                weightFont = .title3
                            }
                            
                            
                        }
                    
                )
                
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.8)
                    .onChanged({_ in
                    withAnimation(.bouncy){
                        
                        currentHeight = maxHeight
                        weightFont = .title2
                        
                        
                    }
                    
                })
                    .onEnded(){_ in
                        if !progressing {
                            withAnimation(.bouncy){
                                changing.toggle()
                                item.progress = item.progress.rounded(.down)
                            }
                        }
                    })
                
                .sensoryFeedback(.impact, trigger: changing)
                
            }
            
            Spacer()
            
            Button(action: { withAnimation{ if item.progress < item.goal {item.progress = (item.progress.rounded(.down)+1); update()} } }, label: {
                Image(systemName: "plus")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundStyle(color)
                    .background(RoundedRectangle(cornerRadius: 45) .frame(width: 60, height: 60)
                        .foregroundStyle(color.opacity(0.5)))
                    .frame(width: 60, height: 60)
                
                    .onAppear{if item.progress >= item.goal {done=true} else {done=false} }
            })
            .buttonRepeatBehavior(.enabled)
            
            
        }
        .padding(.horizontal)
        
        
        
    }
    
    
    
}


