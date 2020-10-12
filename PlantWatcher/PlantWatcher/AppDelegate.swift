//
//  AppDelegate.swift
//  PlantWatcher
//
//  Created by Madeleine Malmsten on 11.10.20.
//  Copyright © 2020 Madeleine Malmsten. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem?
    var icon = "PlantWatcher..."
    var notificationSent = false

    override func awakeFromNib() {
        super.awakeFromNib()
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        func showNotification() -> Void {
            let notification = NSUserNotification()
            notification.title = "🌵 The plants seems to be thirsty"
            notification.informativeText = "It's time to refill the bucket!"
            notification.soundName = NSUserNotificationDefaultSoundName
            NSUserNotificationCenter.default.deliver(notification)
        }
        
        func setIcon() -> Void {
            let url = URL(string: "http://localhost:8080")!
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    let data = data
                    let dataStr = String(data: data!, encoding: .utf8) ?? "{}"
                    let dataObj = dataStr.data(using: .utf8)!
                    do {
                        if let json = try JSONSerialization.jsonObject(with: dataObj, options: []) as? [String: Any] {
                            if let should_refill = json["should_refill"] as? Bool, should_refill == true {
                                self.icon = "🌵"
                                if !self.notificationSent {
                                    showNotification()
                                    self.notificationSent = true
                                }
                            } else if let pump_status = json["pump_status"] as? String, pump_status == "on" {
                                self.icon = "💧"
                                if let pump_running_time = json["pump_running_time"] as? Int {
                                    self.icon = "💧 \(pump_running_time)min"
                                }
                            } else {
                                self.icon = "🌸"
                                self.notificationSent = false
                            }
                        }
                    } catch let error as NSError {
                        self.icon = error as? String ?? "Error"
                    }
            }).resume()
        }
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            setIcon()
            print(self.icon)
            self.statusItem?.button?.title = self.icon
        }
        
    }
}

