//
//  DailyLogApp.swift
//  DailyLog
//
//  Created by Chiwon Song on 10/2/23.
//

import Combine
import SwiftUI

@main
struct DailyLogApp: App {
    @Environment(\.scenePhase) var scenePhase

    let service = DiaryService(emotionService: EmotionService())

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            .environmentObject(service)
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    service.load()
                } else if newPhase == .inactive {
                    service.save()
                }
            }
        }
    }
}
