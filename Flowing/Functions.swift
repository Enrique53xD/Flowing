//
//  Functions.swift
//  Flowing
//
//  Created by Saúl González on 9/01/24.
//

import Foundation


func transforMinutes(minute: Int) -> String {
    var minutes = minute
    var hours = 0
    while minutes >= 60 {
        minutes -= 60
        hours += 1
    }
    return "\(String(format: "%02d", hours)):\(String(format: "%02d", minutes))"
}


func convertToMinutes(from timeString: String) -> Int {
    let components = timeString.components(separatedBy: ":")
    
    if components.count == 2,
       let hours = Int(components[0]),
       let minutes = Int(components[1]) {
        return hours * 60 + minutes
    }
    
    return 0 // Default value if the conversion fails
}



func formatTaskTime(start: Int, end: Int) -> String {
    if start==end {
        return "\(transforMinutes(minute: start))"
    } else {
        return "\(transforMinutes(minute: start)) - \(transforMinutes(minute: end))"
    }
}

func transformDate(date: Date) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    let dateString = dateFormatter.string(from: date)
    
    return dateString
}

func formatProgressive(preffix: String = "", suffix: String = "", progress: Any, goal: Any) -> String {
    if let progressInt = progress as? Int, let goalInt = goal as? Int {
        return "\(preffix)\(progressInt)\(suffix) / \(preffix)\(goalInt)\(suffix)"
    } else {
        let progressValue = (progress as? Double) ?? (Double("\(progress)") ?? progress)
        let goalValue = (goal as? Double) ?? (Double("\(goal)") ?? goal)
        return "\(preffix)\(progressValue)\(suffix) / \(preffix)\(goalValue)\(suffix)"
    }
}


