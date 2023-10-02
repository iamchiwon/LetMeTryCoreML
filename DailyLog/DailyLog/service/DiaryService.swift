//
//  DiaryService.swift
//  DailyLog
//
//  Created by Chiwon Song on 10/2/23.
//

import Foundation
import Observation

@Observable
class DiaryService: ObservableObject {
    private let STORAGE_KEY = "DailyLog_v1"
    private let emotionService: EmotionService

    init(emotionService: EmotionService) {
        self.emotionService = emotionService
    }

    var loading = false
    var logs: [DayLog] = []

    func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(logs) {
            UserDefaults.standard.setValue(data, forKey: STORAGE_KEY)
        }
    }

    func load() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let data = UserDefaults.standard.data(forKey: STORAGE_KEY),
           let loaded = try? decoder.decode([DayLog].self, from: data) {
            logs = loaded
        }
    }

    func addLog(text: String, weather: Weather) {
        guard !text.isEmpty else { return }
        let log = DayLog(id: UUID().uuidString,
                         text: text,
                         date: Date(),
                         weather: weather,
                         emotion: .normal)
        logs.insert(log, at: 0)
        updateEmotion(log: log)
    }

    func updateLog(id: String, text: String, weather: Weather) {
        guard !text.isEmpty else { return }
        guard var log = logs.first(where: { $0.id == id }) else { return }
        log.text = text
        log.weather = weather
        updateEmotion(log: log)
    }

    private func updateEmotion(log: DayLog) {
        Task {
            let emotion = emotionService.evaluate(text: log.text)

            var updated = log
            updated.emotion = emotion

            logs = logs.map { _log in
                guard _log.id == log.id else { return _log }
                return updated
            }
        }
    }
}
