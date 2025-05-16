//
//  SakoKelolaProdukApp.swift
//  SakoKelolaProduk
//
//  Created by Callista on 10/05/25.
//

import SwiftUI
import SwiftData

@main
struct SakoKelolaProdukApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Kategori.self,
            Produk.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView() // No environmentObject injection
        }
        .modelContainer(sharedModelContainer)
    }
}
