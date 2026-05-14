//
//  Focus.swift
//  TomatoBar
//
//  Created by tar on 2026/5/14.
//

import Foundation
import AppKit

enum FocusError: Error {
    case fileNotFound
    case shortcutNotFound
    case processFailed
}

final class FocusManager {
    static let shared = FocusManager()
    private init() {}

    func shortcutExists(named name: String) -> Bool {
        let task = Process()
        let pipe = Pipe()

        task.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
        task.arguments = ["list"]
        task.standardOutput = pipe
        task.standardError = Pipe()

        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            return false
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        return output.components(separatedBy: "\n").contains(name)
    }

    func runShortcut(named name: String) throws {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
        task.arguments = ["run", name]
        task.standardError = Pipe()

        try task.run()
        task.waitUntilExit()

        if task.terminationStatus != 0 {
            throw FocusError.processFailed
        }
    }

    func installShortcutResource(named fileName: String) throws {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "shortcut") else {
            throw FocusError.fileNotFound
        }
        NSWorkspace.shared.open(url)
    }

    // High-level helpers
    func checkFocusOnShortcuts() -> Bool {
        return shortcutExists(named: "tomatoBarFocusOn") && shortcutExists(named: "tomatoBarFocusOff")
    }

    func checkFocusOffShortcuts() -> Bool {
        return shortcutExists(named: "tomatoBarFocusOff")
    }

    func installFocusOnShortcuts() throws {
        try installShortcutResource(named: "tomatoBarFocusOn")
    }

    func installFocusOffShortcuts() throws {
        try installShortcutResource(named: "tomatoBarFocusOff")
    }

    func focusOn() throws {
        if shortcutExists(named: "tomatoBarFocusOn") {
            try runShortcut(named: "tomatoBarFocusOn")
        } else {
            throw FocusError.shortcutNotFound
        }
    }

    func focusOff() throws {
        if shortcutExists(named: "tomatoBarFocusOff") {
            try runShortcut(named: "tomatoBarFocusOff")
        } else {
            throw FocusError.shortcutNotFound
        }
    }
}
