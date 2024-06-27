import AppIntents
import WidgetKit

enum WidgetOption: String, CaseIterable, AppEnum {
    case option1 = "Nothing"
    case option2 = "Name"
    case option3 = "Time Range"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Widget Option"
    static var caseDisplayRepresentations: [WidgetOption : DisplayRepresentation] = [
        .option1: "Nothing",
        .option2: "Name",
        .option3: "Time Range"
    ]
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Widget Option"
    static var description = IntentDescription("Choose an option for the widget")

    @Parameter(title: "Top Text", default: .option1)
    var topText: WidgetOption
    
    @Parameter(title: "Bottom Text", default: .option1)
    var bottomText: WidgetOption
    
    @Parameter(title: "Progress Ring", default: false)
    var pRing: Bool
}
