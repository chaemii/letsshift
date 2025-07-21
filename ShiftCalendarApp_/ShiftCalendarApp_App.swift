//
//  ShiftCalendarApp_App.swift
//  ShiftCalendarApp_
//
//  Created by cham on 7/21/25.
//

import SwiftUI

@main
struct ShiftCalendarApp_App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
