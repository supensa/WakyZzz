//
//  ReminderNotificationController.swift
//  WakyZzz
//
//  Created by Spencer Forrest on 15/02/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

import Foundation
import UserNotifications

class ReminderNotificationController {
  
  func register(taskTitle: String) {
     // TODO: -Change Back to 1 hour
    let dateComponents = dateComponentFromNow(seconds: 60)
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    let content = createNotificationContent(taskTitle: taskTitle)
    
    registerNotification(content: content, trigger: trigger)
  }
  
  private func dateComponentFromNow(seconds: Double) -> DateComponents {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone.current
    
    let timeInterval: TimeInterval = seconds
    let newDate = Date(timeIntervalSinceNow: timeInterval)
    
    return calendar.dateComponents([.day, .month, .year, .hour, .minute, .second], from: newDate)
  }
  
  private func createNotificationContent(taskTitle: String) -> UNMutableNotificationContent {
    let content = UNMutableNotificationContent()
    content.title = "Act of Kindness Reminder"
    content.body = taskTitle
    content.sound = UNNotificationSound.default
    
    return content
  }
  
  private func registerNotification(content: UNNotificationContent,
                                    trigger: UNNotificationTrigger) {
    let notificationCenter = UNUserNotificationCenter.current()
    
    notificationCenter.getNotificationSettings {
      (settings) in
      // Do not schedule notifications if not authorized.
      if settings.authorizationStatus == .authorized {
        self.addRequest(content: content, trigger: trigger)
      }
    }
  }
  
  private func addRequest(content: UNNotificationContent,
                          trigger: UNNotificationTrigger) {
    let identifier = "WakyZzz_Reminder_" + UUID().uuidString
    let request = UNNotificationRequest.init(identifier: identifier,
                                             content: content,
                                             trigger: trigger)
    
    // Schedule the request with the system.
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.add(request)
  }
}
