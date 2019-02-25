//
//  AlarmNotificationControllerUnitTest.swift
//  WakyZzzTests
//
//  Created by Spencer Forrest on 20/02/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//
@testable import WakyZzz
import XCTest
import UserNotifications

class AlarmNotificationControllerUnitTest: XCTestCase {
  
  let alarmId = "AlarmId"
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    resetNotificationCenter()
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    resetNotificationCenter()
  }
  
  func testGivenNewAlarmNotification_WhenRegisterMultipleNotification_ThenNotificationRegistered() {
    let controller = AlarmNotificationController()
    let repeatDays = [true, true, true, true, true, true, true]
    var components = registerTestAlarm(controller: controller, repeatDays: repeatDays)
    let center = UNUserNotificationCenter.current()
    
    center.getPendingNotificationRequests {
      (requests) in
      var weekday = 1
      for request in requests {
        XCTAssertNotNil(request)
        let triger = request.trigger as? UNCalendarNotificationTrigger
        XCTAssertNotNil(triger)
        let trigerComponents = triger?.dateComponents
        XCTAssertNotNil(trigerComponents)
        components.weekday = weekday
        XCTAssert(components == trigerComponents)
        weekday += 1
      }
    }
  }
  
  func testGivenNewAlarmNotification_WhenRegisterSingleNotification_ThenNotificationRegistered() {
    let controller = AlarmNotificationController()
    let components = registerTestAlarm(controller: controller, type: .high)
    let center = UNUserNotificationCenter.current()
    
    center.getPendingNotificationRequests {
      (requests) in
      let request = requests.first
      XCTAssertNotNil(request)
      let triger = request?.trigger as? UNCalendarNotificationTrigger
      XCTAssertNotNil(triger)
      let trigerComponents = triger?.dateComponents
      XCTAssertNotNil(trigerComponents)
      XCTAssert(components == trigerComponents)
    }
  }
  
  func testGivenRegisteredAlarmNotification_WhenUpdateNotification_ThenNotificationUpdated() {
    let controller = AlarmNotificationController()
    var components = registerTestAlarm(controller: controller, type: .high)
    let center = UNUserNotificationCenter.current()
    
    center.getPendingNotificationRequests {
      (requests) in
      let request = requests.first
      XCTAssertNotNil(request)
      let triger = request?.trigger as? UNCalendarNotificationTrigger
      XCTAssertNotNil(triger)
      let trigerComponents = triger?.dateComponents
      XCTAssertNotNil(trigerComponents)
      XCTAssert(components == trigerComponents)
    }
    
    // Sleep for 0.1 sec
    usleep(100000)
    
    components = registerTestAlarm(controller: controller, type: .normal)
    controller.update(alarmId: alarmId, dateComponents: components)
    
    // Sleep for 0.1 sec
    usleep(100000)
    
    center.getPendingNotificationRequests {
      (requests) in
      let request = requests.first
      XCTAssertNotNil(request)
      let triger = request?.trigger as? UNCalendarNotificationTrigger
      XCTAssertNotNil(triger)
      let trigerComponents = triger?.dateComponents
      XCTAssertNotNil(trigerComponents)
      XCTAssert(components == trigerComponents)
    }
  }
  
  func testGivenNewAlarmNotificationRegistered_WhenRemoveNotification_ThenNotificationRemoved() {
    let controller = AlarmNotificationController()
    let _ = registerTestAlarm(controller: controller)
    controller.removeAll(alarmId: alarmId)
    // Sleep for 0.1 sec
    usleep(100000)
    let center = UNUserNotificationCenter.current()
    center.getPendingNotificationRequests {
      (requests) in
      XCTAssert(requests.count == 0)
    }
    center.getDeliveredNotifications {
      (requests) in
      XCTAssert(requests.count == 0)
    }
  }
  
  private func registerTestAlarm(controller: AlarmNotificationController,
                                 repeatDays: [Bool] = [Bool](),
                                 type: SoundType = .normal) -> DateComponents {
    let date = Date(timeIntervalSinceNow: 60)
    let components = dateComponents(from: date)
    controller.register(alarmId: alarmId, repeatDays: repeatDays, dateComponents: components, type: type)
    // Sleep for 0.1 sec
    usleep(100000)
    return components
  }
  
  private func resetNotificationCenter() {
    let center = UNUserNotificationCenter.current()
    center.removeAllDeliveredNotifications()
    center.removeAllPendingNotificationRequests()
    // Sleep for 0.1 sec
    usleep(100000)
  }
  
  private func dateComponents(from date: Date) -> DateComponents {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone.current
    
    return calendar.dateComponents([.hour, .minute, .second], from: date)
  }
}
