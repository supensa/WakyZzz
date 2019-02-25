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
  
  func testGivenNewAlarm_WhenSetRepeatingDay_ThenGetRepeatingDaysString() {
    let alarm = Alarm()
    XCTAssert(alarm.repeating == "One time alarm")
    alarm.repeatDays[0] = true
    alarm.repeatDays[1] = true
    alarm.repeatDays[2] = false
    alarm.repeatDays[3] = true
    alarm.repeatDays[4] = true
    alarm.repeatDays[5] = false
    alarm.repeatDays[6] = true
    XCTAssert(alarm.repeating == "Sun, Mon, Wed, Thu, Sat")
  }
  
  func testGivenNewAlarm_WhenSetTime_ThenGetTime() {
    let hour = 10
    let minute = 10
    let second = 05
    let alarm = Alarm()
    alarm.setTime(hour: hour, minute: minute, second: second)
    let date = alarm.date
    
    var calendar = Calendar.current
    calendar.timeZone = .current
    var components = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year],
                                             from: date)
    XCTAssert(components.hour == hour)
    XCTAssert(components.minute == minute)
    XCTAssert(components.second == second)
  }
  
  func testGivenNewAlarm_WhenSetTime_ThenGetCaption() {
    let hour = 10
    let minute = 10
    let second = 10
    let alarm = Alarm()
    alarm.setTime(hour: hour, minute: minute, second: second)
    XCTAssert(alarm.caption == "10:10")
  }
  
  func testGivenNewAlarm_WhenSetTime_ThenGetDateComponents() {
    let hour = 10
    let minute = 10
    let second = 10
    let alarm = Alarm()
    alarm.setTime(hour: hour, minute: minute, second: second)
    let date = alarm.date
    
    var calendar = Calendar.current
    calendar.timeZone = .current
    var components = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year],
                                             from: date)
    XCTAssert(components.hour == alarm.dateComponents.hour)
    XCTAssert(components.minute == alarm.dateComponents.minute)
    XCTAssert(components.second == alarm.dateComponents.second)
  }
  
  func testGivenNewAlarm_WhenSetWrongHour_ThenGetDefaultHour() {
    let hour = 25
    let minute = 12
    let second = 34
    let alarm = Alarm()
    alarm.setTime(hour: hour, minute: minute, second: second)
    let date = alarm.date
    
    var calendar = Calendar.current
    calendar.timeZone = .current
    var components = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year],
                                             from: date)
    XCTAssert(components.hour == 0)
    XCTAssert(components.minute == minute)
    XCTAssert(components.second == second)
  }
  
  func testGivenNewAlarm_WhenSetWrongMinute_ThenGetDefaultMinute() {
    let hour = 10
    let minute = 70
    let second = 05
    let alarm = Alarm()
    alarm.setTime(hour: hour, minute: minute, second: second)
    let date = alarm.date
    
    var calendar = Calendar.current
    calendar.timeZone = .current
    var components = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year],
                                             from: date)
    XCTAssert(components.hour == hour)
    XCTAssert(components.minute == 0)
    XCTAssert(components.second == second)
  }
  
  func testGivenNewAlarm_WhenSetWrongSecond_ThenGetDefaultSecond() {
    let hour = 10
    let minute = 10
    let second = 70
    let alarm = Alarm()
    alarm.setTime(hour: hour, minute: minute, second: second)
    let date = alarm.date
    
    var calendar = Calendar.current
    calendar.timeZone = .current
    var components = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year],
                                             from: date)
    XCTAssert(components.hour == hour)
    XCTAssert(components.minute == minute)
    XCTAssert(components.second == 0)
  }
}
