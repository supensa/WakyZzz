//
//  AppDelegateTest.swift
//  WakyZzzTests
//
//  Created by Spencer Forrest on 27/02/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

@testable import WakyZzz
import XCTest
import UserNotifications

class AppDelegateTest: XCTestCase {

    func testGivenPendingNotifications_WhenAppWillTerminate_ThenNotificationRemoved() {
      let reminderController = ReminderNotificationController()
      reminderController.register(taskTitle: "Notification1")
      reminderController.register(taskTitle: "Notification2")
      // Sleep for 0.1 sec
      usleep(100000)
      let application = UIApplication.shared
      let delegate = application.delegate!
      delegate.applicationWillTerminate!(application)
      let center = UNUserNotificationCenter.current()
      center.getPendingNotificationRequests {
        (requests) in
        XCTAssert(requests.count == 0)
      }
    }

}
