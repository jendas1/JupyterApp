//
//  AppDelegate.swift
//  Jupyter
//
//  Created by Jan Studený on 06/10/15.
//  Copyright © 2015 Jan Studený. All rights reserved.
//

import Cocoa
import AppKit
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var menu: NSMenu!
    let menuItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength);
    let jupyter_notebook = Process()
    var serverRunning = false;
    func waitForJupyterStart(_ output : FileHandle) {
        while true {
            var line = "";
            while true {
                let char = NSString(data:output.readData(ofLength: 1),encoding:String.Encoding.utf8.rawValue)! as String
                if char == "\n" {
                    break;
                }
                else {
                    line += char;
                }
            }
            if line.contains("The Jupyter Notebook is running") {
                break;
            }
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let output_pipe = Pipe()
        jupyter_notebook.launchPath = "/usr/local/bin/python3"
        jupyter_notebook.currentDirectoryPath = NSHomeDirectory()
        jupyter_notebook.arguments = ["-m", "notebook", "--no-browser", "-y"]
        jupyter_notebook.environment = ["LC_ALL": "en_US.UTF-8"];
        let icon = NSImage(named: "menuBarIcon")!
        icon.isTemplate = true
        menuItem.image = icon
        menuItem.menu = menu
        jupyter_notebook.standardError = output_pipe;
        jupyter_notebook.launch()
        waitForJupyterStart(output_pipe.fileHandleForReading);
        serverRunning = true;
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        jupyter_notebook.terminate()
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        if filename.range(of: NSHomeDirectory()) == nil {
            return false;
        }
        let relative_filename = filename.replacingOccurrences(of: NSHomeDirectory() + "/", with: "")
        let escaped_filename = relative_filename.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        while !serverRunning {};
        NSWorkspace.shared().open(URL(string: "http://localhost:8888/notebooks/" + escaped_filename!)!)
        return true;
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    @IBAction func stopServer(_ sender: NSMenuItem) {
        jupyter_notebook.terminate()
    }
}

