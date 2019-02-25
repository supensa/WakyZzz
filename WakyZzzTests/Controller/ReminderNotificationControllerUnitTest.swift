//
//  ReminderNotificationControllerUnitTest.swift
//  WakyZzzTests
//
//  Created by Spencer Forrest on 20/02/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//
@testable import WakyZzz
import XCTest
import UserNotifications

class ReminderNotificationControllerUnitTest: XCTestCase {
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    resetNotificationCenter()
  }
  
  override func tearDown() {
    resetNotificationCenter()
  }
  
  func testGivenNewReminderNotification_WhenRegisterNotification_ThenNotificationRegistered(){
    let center = UNUserNotificationCenter.current()
    let controller = ReminderNotificationController()
    let taskTitle = "TEST"
    controller.register(taskTitle: taskTitle)
    // Sleep for 0.1 sec
    usleep(100000)
    center.getPendingNotificationRequests {
      (notificationRequests) in
      let request = notificationRequests.first
      XCTAssertNotNil(request)
      let body = request?.content.body
      XCTAssertNotNil(body)
      XCTAssert(body == taskTitle)
    }
  }
  
  private func resetNotificationCenter() {
    // Sleep for 0.1 sec
    usleep(100000)
    let center = UNUserNotificationCenter.current()
    center.removeAllDeliveredNotifications()
    center.removeAllPendingNotificationRequests()
  }
}
