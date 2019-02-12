//
//  NotificationsController.swift
//  WakyZzz
//
//  Created by Spencer Forrest on 05/02/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationsController {
  
  var repeatDays: [Bool]!
  private var identifiers = Dictionary<String,[String]>()
  
  func isOneTimeAlarm() -> Bool {
    for i in 0 ..< repeatDays.count {
      if repeatDays[i] {
        return false
      }
    }
    return true
  }
  
  func reset(alarmId: String,
             repeatDays: [Bool],
             dateComponents: DateComponents,
             isWithHighSound: Bool = false) {
    self.removeAll(alarmId: alarmId)
    self.register(alarmId: alarmId,
                  repeatDays: repeatDays,
                  dateComponents: dateComponents,
                  isWithHighSound: isWithHighSound)
  }
  
  func register(alarmId: String,
                repeatDays: [Bool],
                dateComponents: DateComponents,
                isWithHighSound: Bool = false) {
    self.repeatDays = repeatDays
    let content = self.createNotificationContent()
    if self.isOneTimeAlarm() {
      let trigger = createNotificationTrigger(weekDay: nil, dateComponents: dateComponents)
      self.registerNotification(alarmId: alarmId, content: content, trigger: trigger)
    } else {
      for weekday in 0..<self.repeatDays.count {
        if self.repeatDays[weekday] {
          let trigger = createNotificationTrigger(weekDay: weekday, dateComponents: dateComponents)
          self.registerNotification(alarmId: alarmId, content: content, trigger: trigger)
        }
      }
    }
  }
  
  func removeAll(alarmId: String) {
    // Remove scheduled request with the system.
    if let array = self.identifiers[alarmId] {
      let notificationCenter = UNUserNotificationCenter.current()
      notificationCenter.removePendingNotificationRequests(withIdentifiers: array)
      notificationCenter.removeDeliveredNotifications(withIdentifiers: array)
      self.identifiers[alarmId] = nil
    }
  }
  
  private func createNotificationContent() -> UNMutableNotificationContent {
    let content = UNMutableNotificationContent()
    content.title = "WakyZzz"
    content.body = "Alarm"
    let named = UNNotificationSoundName(rawValue: "sound.caf")
    content.sound = UNNotificationSound(named: named)
    return content
  }
  
  private func createNotificationTrigger(weekDay: Int?, dateComponents: DateComponents) -> UNCalendarNotificationTrigger {
    var components = dateComponents
    var repeats = false
    if let weekDay = weekDay {
      components.weekday = weekDay + 1
      repeats = true
    }
    // Return the trigger as a repeating event.
    return UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
  }
  
  private func registerNotification(alarmId: String,
                                    content: UNNotificationContent,
                                    trigger: UNNotificationTrigger) {
    let notificationCenter = UNUserNotificationCenter.current()
    
    notificationCenter.getNotificationSettings {
      (settings) in
      // Do not schedule notifications if not authorized.
      guard settings.authorizationStatus == .authorized else {return}
      
      self.addRequest(alarmId: alarmId, content: content, trigger: trigger)
    }
  }
  
  private func addRequest(alarmId: String, content: UNNotificationContent, trigger: UNNotificationTrigger) {
    let identifier = "WakyZzz_" + UUID().uuidString
    let request = UNNotificationRequest.init(identifier: identifier,
                                             content: content,
                                             trigger: trigger)
    
    // Schedule the request with the system.
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.add(request) {
      (error) in
      if error == nil {
        if self.identifiers[alarmId] == nil {
          self.identifiers[alarmId] = [String]()
        }
        self.identifiers[alarmId]?.append(identifier)
      } else {
        // Handle any errors.
        print(error.debugDescription)
      }
    }
  }
}
