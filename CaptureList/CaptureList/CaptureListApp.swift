//
//  CapturelistApp.swift
//  Capturelist
//
//  Created by saya lee on 8/22/25.
//

import SwiftUI

@main
struct CapturelistApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
