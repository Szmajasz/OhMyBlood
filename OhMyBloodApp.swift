//
//  OhMyBloodApp.swift
//  OhMyBlood
//
//  Created by Szymon Szmajdziński on 07/02/2024.
//

import SwiftUI

@main
struct OhMyBloodApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            BloodPressureListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
