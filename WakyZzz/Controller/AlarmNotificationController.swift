//
//  AlarmNotificationController.swift
//  WakyZzz
//
//  Created by Spencer Forrest on 05/02/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

import Foundation
import UserNotifications

enum SoundType {
  case normal, high
}

class AlarmNotificationController {
  
  // Register notification(s) for specific alarm
  func register(alarmId: String,
                repeatDays: [Bool] = [Bool](),
                dateComponents: DateComponents,
                type: SoundType = .normal) {
    
    let content = createNotificationContent(alarmId: alarmId, type: type)
    self.repeatDays = repeatDays
    if isOneTime() {
      registerSingleNotification(dateComponents: dateComponents,
                                 alarmId: alarmId,
                                 content: content,
                                 weekday: nil)
    } else {
      registerMultipleNotifications(dateComponents: dateComponents,
                                    alarmId: alarmId,
                                    content: content)
    }
  }
  
  // Update registered notifications for specific alarm
  func update(alarmId: String,
             repeatDays: [Bool] = [Bool](),
             dateComponents: DateComponents,
             type: SoundType = .normal) {
    self.removeAll(alarmId: alarmId)
    self.register(alarmId: alarmId,
                  repeatDays: repeatDays,
                  dateComponents: dateComponents,
                  type: type)
  }
  
  // Remove all notification for specific alarm
  func removeAll(alarmId: String) {
    // Remove scheduled request from Notification Center
    if let array = self.identifiers[alarmId] {
      let notificationCenter = UNUserNotificationCenter.current()
      notificationCenter.removePendingNotificationRequests(withIdentifiers: array)
      notificationCenter.removeDeliveredNotifications(withIdentifiers: array)
      self.identifiers[alarmId] = nil
    }
  }
  
  private var identifiers = Dictionary<String,[String]>()
  private var repeatDays = [Bool]()
  
  private func createNotificationContent(alarmId: String,
                                         type: SoundType) -> UNMutableNotificationContent {
    var fileName = ""
    var notificationCategoryId = ""
    
    switch type {
    case .normal:
      fileName = kNormalSoundFileName
      notificationCategoryId = kNotificationNormalCategoryId
    case .high:
      fileName = kHighSoundFileName
      notificationCategoryId = kNotificationHighCategoryId
    }
    
    let content = UNMutableNotificationContent()
    content.title = "WakyZzz"
    content.body = "Alarm"
    content.sound = notificationSound(fileName)
    content.categoryIdentifier = notificationCategoryId
    content.userInfo[kAlarmId] = alarmId
    
    return content
  }
  
  private func notificationSound(_ fileName: String) -> UNNotificationSound {
    let named = UNNotificationSoundName(rawValue: fileName)
    return UNNotificationSound(named: named)
  }
  
  private func isOneTime() -> Bool {
    var bool = true
    for i in 0 ..< repeatDays.count {
      if repeatDays[i] {
        bool = false
      }
    }
    return bool
  }
  
  private func registerMultipleNotifications(dateComponents: DateComponents,
                                             alarmId: String,
                                             content: UNMutableNotificationContent) {
    for weekday in 0..<self.repeatDays.count {
      if self.repeatDays[weekday] {
        registerSingleNotification(dateComponents: dateComponents,
                                   alarmId: alarmId,
                                   content: content,
                                   weekday: weekday)
      }
    }
  }
  
  private func registerSingleNotification(dateComponents: DateComponents,
                                          alarmId: String,
                                          content: UNMutableNotificationContent,
                                          weekday: Int?) {
    let trigger = createNotificationTrigger(weekday: weekday, dateComponents: dateComponents)
    self.registerNotification(alarmId: alarmId, content: content, trigger: trigger)
  }
  
  private func createNotificationTrigger(weekday: Int?,
                                         dateComponents: DateComponents) -> UNCalendarNotificationTrigger {
    var components = dateComponents
    var repeats = false
    if let weekday = weekday {
      components.weekday = weekday + 1
      repeats = true
    }
    // Return the trigger
    return UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
  }
  
  private func registerNotification(alarmId: String,
                                    content: UNNotificationContent,
                                    trigger: UNNotificationTrigger) {
    let notificationCenter = UNUserNotificationCenter.current()
    
    notificationCenter.getNotificationSettings {
      (settings) in
      // Do not schedule notifications if not authorized.
      if settings.authorizationStatus == .authorized {
        self.addRequest(alarmId: alarmId, content: content, trigger: trigger)
      }
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
        // Stock alarmId in dictionary with corresponding notification request identifier
        if self.identifiers[alarmId] == nil {
          self.identifiers[alarmId] = [String]()
        }
        self.identifiers[alarmId]?.append(identifier)
      }
    }
  }
}
