//
//  Action.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import Foundation

class Action {
  var normalTitles = [
    "Snooze",
    "Stop"
  ]
  var kindTitles = [
    "Message a friend asking how they are doing",
    "Connect with a family member by expressing a kind thought"
  ]
  
  var actOfKindnessStatus: Act?
  private var snoozeCounter = 0
  
  func isEvilSnooze() -> Bool {
    self.snoozeCounter += 1
    let bool = self.snoozeCounter == 2
    if bool { self.snoozeCounter = 0 }
    return bool
  }
}

enum Act: String {
  case completed, promise
}
