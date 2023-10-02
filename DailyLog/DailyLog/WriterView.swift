//
//  WriterView.swift
//  DailyLog
//
//  Created by Chiwon Song on 10/2/23.
//

import SwiftUI

struct WriterView: View {
    @EnvironmentObject var service: DiaryService

    var id: String?
    var date = Date().dateString()
    @State private var text: String
    @State private var weather: Weather

    init(log: DayLog? = nil) {
        id = log?.id
        date = log?.date.dateString() ?? Date().dateString()
        text = log?.text ?? ""
        weather = log?.weather ?? .sunny
    }

    var body: some View {
        VStack {
            HStack {
                Text(date)
                Spacer()

                Text("오늘의 날씨: ").foregroundStyle(.gray)
                Picker("오늘의 날씨", selection: $weather) {
                    ForEach(Weather.allCases) { w in
                        Text(w.rawValue).tag(w)
                    }
                }
            }
            .padding(.horizontal)

            TextEditor(text: $text)
                .border(.gray)
                .padding(.horizontal)
        }
        .onDisappear(perform: {
            if let id = id {
                service.updateLog(id: id, text: text, weather: weather)
            } else {
                service.addLog(text: text, weather: weather)
            }

        })
    }
}

#Preview {
    WriterView()
}
