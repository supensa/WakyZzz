//
//  AlarmsViewController.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import UIKit
import AVFoundation
import UserNotifications

class AlarmsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AlarmCellDelegate, AlarmViewControllerDelegate {
  @IBOutlet weak var tableView: UITableView!
  
  var alarms = [Alarm]()
  var notificationsController = AlarmNotificationController()
  var audioPlayer = AVAudioPlayer()
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
    populateAlarms()
    askNotificationAuthorization()
    setupNotificationActions()
    setupAudioPlayer()
  }
  
  func setupAudioPlayer() {
    do {
      let path = Bundle.main.path(forResource: "evil", ofType: "caf")!
      let url = URL(fileURLWithPath: path)
      audioPlayer = try AVAudioPlayer(contentsOf: url)
      audioPlayer.prepareToPlay()
      
      let audioSession = AVAudioSession.sharedInstance()
      do {
        try audioSession.setCategory(.playback,
                                     mode: .default,
                                     options: [])
      } catch {
        print("Setting category to AVAudioSessionCategoryPlayback failed.")
      }
      
    } catch {
      print("Setting audio player failed")
    }
  }
  
  func setupNotificationActions() {
    let normalCategory = setupNormalCategory()
    let lastCategory = setupLastCategory()
    // Register the notification type.
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.setNotificationCategories([normalCategory, lastCategory])
  }
  
  func setupNormalCategory() -> UNNotificationCategory {
    // Define the custom actions.
    let snoozeAction = UNNotificationAction.init(identifier: kSnoozeAction,
                                            title: "Snooze",
                                            options: [])
    // Define the notification type
    return UNNotificationCategory(identifier: kNotificationNormalCategoryId,
                                  actions: [snoozeAction],
                                  intentIdentifiers: [],
                                  hiddenPreviewsBodyPlaceholder: "",
                                  options: .customDismissAction)
  }
  
  func setupLastCategory() -> UNNotificationCategory {
    // Define the custom actions.
    let snoozeAction = UNNotificationAction(identifier: kSnoozeAction,
                                            title: "Snooze",
                                            options: [.foreground])
    // Define the notification type
    return UNNotificationCategory(identifier: kNotificationHighCategoryId,
                                  actions: [snoozeAction],
                                  intentIdentifiers: [],
                                  hiddenPreviewsBodyPlaceholder: "",
                                  options: .customDismissAction)
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
    
    let delete = UITableViewRowAction(style: .destructive, title: "Delete") {
      (action, indexPath) in
      self.deleteAlarm(at: indexPath)
    }
    let edit = UITableViewRowAction(style: .normal, title: "Edit") {
      (action, indexPath) in
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
    let alarm = alarms.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .automatic)
    tableView.endUpdates()
    notificationsController.removeAll(alarmId: alarm.id)
  }
  
  func editAlarm(at indexPath: IndexPath) {
    editingIndexPath = indexPath
    presentAlarmViewController(alarm: alarm(at: indexPath))
  }
  
  func addAlarm(_ alarm: Alarm) {
    alarms.append(alarm)
    updateAlarms()
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
        notificationsController.register(alarmId: alarm.id,
                                         repeatDays: alarm.repeatDays,
                                         dateComponents: alarm.dateComponents)
      } else {
        notificationsController.removeAll(alarmId: alarm.id)
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
      notificationsController.reset(alarmId: alarm.id,
                                    repeatDays: alarm.repeatDays,
                                    dateComponents: alarm.dateComponents)
    }
    if let _ = editingIndexPath {
      updateAlarms()
    } else {
      addAlarm(alarm)
    }
    tableView.reloadData()
    editingIndexPath = nil
  }
  
  func updateAlarms() {
    alarms = alarms.sorted(by: { self.ascendingTimeOrdering(firstDate: $0.date, secondDate: $1.date) })
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

extension AlarmsViewController: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .sound])
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    
    guard let alarmId = response.notification.request.content.userInfo[kAlarmId] as? String
      else { return }
    
    let categoryIdentifier = response.notification.request.content.categoryIdentifier
    
    switch categoryIdentifier {
    case kNotificationNormalCategoryId:
      if response.actionIdentifier == kSnoozeAction {
        // Higher sound + different category
        // TODO: Change back to a minute
        let dateComponents = dateComponentsFromNow(seconds: 10)
        notificationsController.register(alarmId: alarmId, dateComponents: dateComponents, type: .high)
      }
      break
    case kNotificationHighCategoryId:
      if response.actionIdentifier == kSnoozeAction {
        activateEvilMode()
      }
      break
    default:
      break
    }
    
    // Always call the completion handler when done.
    completionHandler()
  }
  
  private func dateComponentsFromNow(seconds: Double) -> DateComponents {
    var calendar = Calendar.current
    calendar.timeZone = .current
    
    let oneMinuteLater: TimeInterval = seconds
    let newDate = Date(timeIntervalSinceNow: oneMinuteLater)
    
    return calendar.dateComponents([.hour, .minute, .second, .day, .month, .year],
                                   from: newDate)
  }
  
  func activateEvilMode() {
    playEvilSound()
    showKindnessAlert()
  }
  
  func playEvilSound() {
    // infinite loop
    audioPlayer.numberOfLoops = -1
    audioPlayer.play()
  }
  
  func showKindnessAlert() {
    let alert = UIAlertController.init(title: "Act of Kindness",
                                       message: "Please select an act of kindness",
                                       preferredStyle: .alert)
    
    let familyAction = UIAlertAction.init(title: Action.family.rawValue, style: .default) {
      (action) in
      let title = action.title!
      self.evilLogic(taskTitle: title)
    }
    let friendAction = UIAlertAction.init(title: Action.friend.rawValue, style: .default) {
      (action) in
      let title = action.title!
      self.evilLogic(taskTitle: title)
    }
    let coworkerAction = UIAlertAction.init(title: Action.coworker.rawValue, style: .default) {
      (action) in
      let title = action.title!
      self.evilLogic(taskTitle: title)
    }
    
    alert.addAction(familyAction)
    alert.addAction(friendAction)
    alert.addAction(coworkerAction)
    
    self.present(alert, animated: false, completion: nil)
  }
  
  func evilLogic(taskTitle: String) {
    stopEvilSound()
    chooseTaskStatus(taskTitle: taskTitle)
  }
  
  func stopEvilSound() {
    audioPlayer.currentTime = 0
    audioPlayer.stop()
    audioPlayer.prepareToPlay()
  }
  
  func chooseTaskStatus(taskTitle: String) {
    let alert = UIAlertController.init(title: "Act of Kindness",
                                       message: "When will you perform this act of kindness ?",
                                       preferredStyle: .alert)
    
    let laterAction = UIAlertAction.init(title: "Remind me later", style: .default) {
      (action) in
      ReminderNotificationController().register(taskTitle: taskTitle)
    }
    let completedAction = UIAlertAction.init(title: "Already completed", style: .default, handler: nil)
    
    alert.addAction(completedAction)
    alert.addAction(laterAction)
    
    self.present(alert, animated: false, completion: nil)
  }
}
