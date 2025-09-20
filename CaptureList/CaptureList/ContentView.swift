//
//  ContentView.swift
//  Capturelist
//
//  Created by saya lee on 8/22/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainView()
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
