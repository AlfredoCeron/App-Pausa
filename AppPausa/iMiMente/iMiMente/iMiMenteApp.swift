//
//  iMiMenteApp.swift
//  iMiMente
//
//  Created by AlfredoCeron on 01/04/25.
//

import SwiftUI

@main
struct iMiMenteApp: App {
    @StateObject private var diaryStore = DiaryStore()
    @StateObject private var taskStore = TaskStore()
    
    var body: some Scene {
        WindowGroup {
            Diario()
                .environmentObject(diaryStore)
                .environmentObject(taskStore)
        }
    }
}
