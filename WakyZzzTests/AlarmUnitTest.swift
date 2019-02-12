//
//  AlarmUnitTest.swift
//  WakyZzzTests
//
//  Created by Spencer Forrest on 25/01/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

import XCTest
@testable import WakyZzz

class AlarmUnitTest: XCTestCase {
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testGivenNoAlarm_WhenNewAlarm_ThenNewAlarmDate() {
  }
  
  func testGivenNewAlarm_WhenSetRepeatingDay_ThenGetRepeatingDaysString() {
    let alarm = Alarm()
    XCTAssert(alarm.repeating == "One time alarm")
    alarm.repeatDays[0] = true
    alarm.repeatDays[1] = true
    alarm.repeatDays[2] = true
    alarm.repeatDays[3] = true
    alarm.repeatDays[4] = true
    alarm.repeatDays[5] = true
    alarm.repeatDays[6] = true
    XCTAssert(alarm.repeating == "Sun, Mon, Tue, Wed, Thu, Fri, Sat")
  }
  
  func testGivenNewAlarm_WhenSetTime_ThenGetTime() {
    
  }
}
