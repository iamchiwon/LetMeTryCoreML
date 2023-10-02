//
//  DayLog.swift
//  DailyLog
//
//  Created by Chiwon Song on 10/2/23.
//

import Foundation

enum Weather: String, CaseIterable, Identifiable, Codable {
    var id: String { rawValue }
    case sunny = "☀️"
    case cloudy = "☁️"
    case rainy = "🌧️"
    case snow = "⛄️"
}

enum Emotion: String, Codable {
    case happy = "🤩"
    case good = "😃"
    case normal = "😗"
    case bad = "😩"
    case sad = "😭"
}

struct DayLog: Identifiable, Codable {
    var id: String
    var text: String
    var date: Date
    var weather: Weather
    var emotion: Emotion
}

extension Date {
    func dateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월 d일"
        return dateFormatter.string(from: self)
    }
}
