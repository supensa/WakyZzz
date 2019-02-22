//
//  AlarmsViewControllerUnitTest.swift
//  WakyZzzTests
//
//  Created by Spencer Forrest on 21/02/2019.
//  Copyright © 2019 Olga Volkova OC. All rights reserved.
//

@testable import WakyZzz
import XCTest

class AlarmsViewControllerUnitTest: XCTestCase {
  
  var storyboard = UIStoryboard(name: "Main", bundle: nil)
  var alarmsViewController = AlarmsViewController()
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    alarmsViewController = storyboard.instantiateViewController(withIdentifier: "AlarmsViewController") as! AlarmsViewController
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testGivenAlarms_WhenLookForAlarmFromIndexPath_ThenGetAlarm() {    
    var ids = [String]()
    var alarms = [Alarm]()
    
    let random = Int.random(in: 0...10)
    
    for _ in 0...random {
      let alarm = Alarm()
      ids.append(alarm.id)
      alarms.append(alarm)
    }
    
    alarmsViewController.alarms = alarms
    
    for row in 0...random {
      let indexPath = IndexPath(row: row, section: 0)
      let alarm = alarmsViewController.alarm(at: indexPath)
      let id = ids[row]
      XCTAssertNotNil(alarm)
      XCTAssert(id == alarm?.id)
    }
  }
  
  func testGivenAlarms_WhenDeleteAlarmFrom_ThenAlarmDeleted() {
    var alarms = [Alarm]()
    let random = Int.random(in: 0...10)
    
    for _ in 0...random {
      let alarm = Alarm()
      alarms.append(alarm)
    }
    
    let tableView = UITableView.init()
    alarmsViewController.alarms = alarms
    alarmsViewController.tableView = tableView
    
    let row = Int.random(in: 0...random)
    let indexPath = IndexPath(row: row, section: 0)
    let alarmTest = alarmsViewController.alarms[row]
    alarmsViewController.deleteAlarm(at: indexPath)
    
    var isAlarmMissing = true
    
    for alarm in alarmsViewController.alarms {
      if alarm.id == alarmTest.id {
        isAlarmMissing = true
      }
    }
    
    XCTAssert(isAlarmMissing)
  }
  
  func testGivenAlarms_WhenEditButtonPressedAlarmFrom_ThenGetCorrespondingIndexPathSaved() {
    var alarms = [Alarm]()
    let random = Int.random(in: 0...10)
    
    for _ in 0...random {
      let alarm = Alarm()
      alarms.append(alarm)
    }
    
    alarmsViewController.alarms = alarms
    
    let row = Int.random(in: 0...random)
    let indexPath = IndexPath(row: row, section: 0)
    
    alarmsViewController.editAlarm(at: indexPath)
    
    XCTAssert(alarmsViewController.editingIndexPath == indexPath)
  }
  
  func testGivenAlarm_WhenAddingAlarm_ThenAddedInArray() {
    let alarm = Alarm()
    alarmsViewController.alarms = [Alarm]()
    alarmsViewController.addAlarm(alarm)
    XCTAssert(alarmsViewController.alarms.count == 1)
  }
  
  func testGivenEditingIndexPath_WhenAlarmViewControllerDone_ThenIndexPathIsNil() {
    let row = Int.random(in: 0...10)
    let indexPath = IndexPath(row: row, section: 0)
    let alarm = Alarm()
    let tableView = UITableView()
    
    alarmsViewController.tableView = tableView
    alarmsViewController.editingIndexPath = indexPath
    
    XCTAssertNotNil(alarmsViewController.editingIndexPath)
    alarmsViewController.alarmViewControllerDone(alarm: alarm)
    XCTAssertNil(alarmsViewController.editingIndexPath)
  }
  
  func testGivenNilEditingIndexPath_WhenAlarmViewControllerDone_ThenIndexPathIsNil() {
    let alarm = Alarm()
    let tableView = UITableView()
    
    alarmsViewController.tableView = tableView
    alarmsViewController.editingIndexPath = nil
    
    XCTAssertNil(alarmsViewController.editingIndexPath)
    alarmsViewController.alarmViewControllerDone(alarm: alarm)
    XCTAssertNil(alarmsViewController.editingIndexPath)
  }
  
  func testGivenAlarms_WhenSorting_ThenSorted() {
    var alarms = [Alarm]()
    
    let random = Int.random(in: 0...10)
    
    for _ in 0...random {
      let alarm = Alarm()
      let hour = Int.random(in: 0...23)
      let minute = Int.random(in: 0...59)
      let second = Int.random(in: 0...59)
      alarm.setTime(hour: hour, minute: minute, second: second)
      alarms.append(alarm)
    }
    
    alarmsViewController.alarms = alarms
    alarmsViewController.updateAlarms()
    
    var isSorted = true
    var previousAlarm = alarmsViewController.alarms.first!
    
    for alarm in alarmsViewController.alarms {
      if previousAlarm.date > alarm.date {
        isSorted = false
      }
      previousAlarm = alarm
    }
    
    XCTAssert(isSorted)
  }
  
  func testWhenPlayEvilSound_ThenEvilSoundIsPlaying() {
    alarmsViewController.setupAudioPlayer()
    alarmsViewController.playEvilSound()
    XCTAssert(alarmsViewController.audioPlayer.isPlaying)
    XCTAssert(alarmsViewController.audioPlayer.numberOfLoops == -1)
    alarmsViewController.audioPlayer.stop()
  }
  
  func testGivenEvilSoundPlaying_WhenStopEvilSound_ThenEvilSoundStops() {
    alarmsViewController.setupAudioPlayer()
    alarmsViewController.playEvilSound()
    XCTAssert(alarmsViewController.audioPlayer.isPlaying)
    alarmsViewController.stopEvilSound()
    XCTAssert(alarmsViewController.audioPlayer.currentTime == 0)
    XCTAssert(alarmsViewController.audioPlayer.isPlaying == false)
  }
}
