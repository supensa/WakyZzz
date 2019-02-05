//
//  AlarmsViewController.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import UIKit
import UserNotifications

class AlarmsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AlarmCellDelegate, AlarmViewControllerDelegate {
  @IBOutlet weak var tableView: UITableView!
  
  var alarms = [Alarm]()
  var editingIndexPath: IndexPath?
  
  @IBAction func addButtonPress(_ sender: Any) {
    presentAlarmViewController(alarm: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    config()
  }
  
  func config() {
    tableView.delegate = self
    tableView.dataSource = self
    self.populateAlarms()
    self.askNotificationAuthorization()
  }
  
  func askNotificationAuthorization() {
    let center = UNUserNotificationCenter.current()
    // Request permission to display alerts and play sounds.
    center.requestAuthorization(options: [.alert, .sound]) {
      (granted, error) in
      // Enable or disable features based on authorization.
      if !granted {
        print(error.debugDescription)
      }
    }
  }
  
  func populateAlarms() {
    var alarm: Alarm
    // Weekdays 5am
    alarm = Alarm()
    alarm.setTime(hour: 5)
    for i in 1 ... 5 {
      alarm.repeatDays[i] = true
    }
    alarms.append(alarm)
    
    // Weekend 9am
    alarm = Alarm()
    alarm.setTime(hour: 9)
    alarm.enabled = false
    alarm.repeatDays[0] = true
    alarm.repeatDays[6] = true
    alarms.append(alarm)
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return alarms.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath) as! AlarmTableViewCell
    cell.delegate = self
    if let alarm = alarm(at: indexPath) {
      cell.populate(caption: alarm.caption, subcaption: alarm.repeating, enabled: alarm.enabled)
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    
    let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
      self.deleteAlarm(at: indexPath)
    }
    let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
      self.editAlarm(at: indexPath)
    }
    return [delete, edit]
  }
  
  func alarm(at indexPath: IndexPath) -> Alarm? {
    return indexPath.row < alarms.count ? alarms[indexPath.row] : nil
  }
  
  // TODO: Unit test
  func deleteAlarm(at indexPath: IndexPath) {
    tableView.beginUpdates()
//    alarms.remove(at: alarms.count)
    alarms.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .automatic)
    tableView.endUpdates()
  }
  
  func editAlarm(at indexPath: IndexPath) {
    editingIndexPath = indexPath
    presentAlarmViewController(alarm: alarm(at: indexPath))
  }
  
  func addAlarm(_ alarm: Alarm) {
    self.alarms.append(alarm)
    self.updateAlarms()
  }
  
  // TODO: Check if useful function ?
  func moveAlarm(from originalIndextPath: IndexPath, to targetIndexPath: IndexPath) {
    let alarm = alarms.remove(at: originalIndextPath.row)
    alarms.insert(alarm, at: targetIndexPath.row)
    tableView.reloadData()
  }
  
  func alarmCell(_ cell: AlarmTableViewCell, enabledChanged enabled: Bool) {
    if let indexPath = tableView.indexPath(for: cell),
      let alarm = self.alarm(at: indexPath) {
      if enabled {
        alarm.setOn()
      } else {
        alarm.setOff()
      }
      alarm.enabled = enabled
    }
  }
  
  func presentAlarmViewController(alarm: Alarm?) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let popupViewController = storyboard.instantiateViewController(withIdentifier: "DetailNavigationController") as! UINavigationController
    let alarmViewController = popupViewController.viewControllers[0] as! AlarmViewController
    alarmViewController.alarm = alarm
    alarmViewController.delegate = self
    present(popupViewController, animated: true, completion: nil)
  }
  
  func alarmViewControllerCancel() {
    self.editingIndexPath = nil
  }
  
  // TODO: Unit testing Edit order of Alarms according to time
  func alarmViewControllerDone(alarm: Alarm) {
    if alarm.enabled {
      alarm.reset()
    }
    if let _ = editingIndexPath {
      self.updateAlarms()
    } else {
      self.addAlarm(alarm)
    }
    self.tableView.reloadData()
    self.editingIndexPath = nil
  }
  
  func updateAlarms() {
    self.alarms = alarms.sorted(by: { self.ascendingTimeOrdering(firstDate: $0.date, secondDate: $1.date) })
  }
  
  private func ascendingTimeOrdering(firstDate: Date, secondDate: Date) -> Bool {
    var calendar = Calendar.current
    calendar.timeZone = .current
    
    var components = calendar.dateComponents([.hour, .minute, .second],
                                             from: firstDate as Date)
    let firstHour = components.hour!
    let firstMinute = components.minute!
    let firstSecond = components.second!
    
    components = calendar.dateComponents([.hour, .minute, .second],
                                         from: secondDate as Date)
    
    let secondHour = components.hour!
    let secondMinute = components.minute!
    let secondSecond = components.second!
    
    if firstHour == secondHour {
      if firstMinute == secondMinute {
        return firstSecond < secondSecond
      } else {
        return firstMinute < secondMinute
      }
    } else {
      return firstHour < secondHour
    }
  }
}

