//
//  AppDelegate.swift
//  Jupyter
//
//  Created by Jan Studený on 06/10/15.
//  Copyright © 2015 Jan Studený. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var menu: NSMenu!
    let menuItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength);
    let jupyter_notebook = NSTask()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        jupyter_notebook.launchPath = "/usr/local/bin/python3"
        jupyter_notebook.currentDirectoryPath = NSHomeDirectory()
        jupyter_notebook.arguments = ["-m", "notebook", "--no-browser", "-y"]
        jupyter_notebook.environment = ["LC_ALL": "en_US.UTF-8"];
        let icon = NSImage(named: "menuBarIcon")!
        icon.template = true
        menuItem.image = icon
        menuItem.menu = menu
        jupyter_notebook.launch()
    }
    
    func applicationWillTerminate(notification: NSNotification) {
        jupyter_notebook.terminate()
    }
    
    func application(sender: NSApplication, openFile filename: String) -> Bool {
        if filename.rangeOfString(NSHomeDirectory()) == nil {
            return false;
        }
        let relative_filename = filename.stringByReplacingOccurrencesOfString(NSHomeDirectory() + "/", withString: "")
        let escaped_filename = relative_filename.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://localhost:8888/notebooks/" + escaped_filename!)!)
        return true;
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
}

