//
//  Alarm.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import Foundation
import UserNotifications

class Alarm {
  static let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  
  private(set) var id = "alarm_" + UUID().uuidString
  
  var date = Date()
  var repeatDays = [false, false, false, false, false, false, false]
  var enabled = true
  var isEvil = false
  
  private var snoozeCount = 0
  
  var dateComponents: DateComponents {
    var calendar = Calendar.current
    calendar.timeZone = .current
    return calendar.dateComponents([.hour, .minute, .second], from: self.date as Date)
  }
  
  var caption: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter.string(from: self.date)
  }
  
  var repeating: String {
    var captions = [String]()
    for i in 0 ..< repeatDays.count {
      if repeatDays[i] {
        captions.append(Alarm.daysOfWeek[i])
      }
    }
    return captions.count > 0 ? captions.joined(separator: ", ") : "One time alarm"
  }
  
  func setTime(hour: Int, minute: Int = 0, second: Int = 0) {
    var calendar = Calendar.current
    calendar.timeZone = .current
    
    var components = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year],
                                             from: date as Date)
    
    components.hour = (0..<24).contains(hour) ? hour : 0
    components.minute = (0..<60).contains(minute) ? minute : 0
    components.second = (0..<60).contains(second) ? second : 0
    
    if let date = calendar.date(from: components) {
      self.date = date
    }
  }
}
