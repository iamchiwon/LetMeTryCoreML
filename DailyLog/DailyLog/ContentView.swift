//
//  ContentView.swift
//  DailyLog
//
//  Created by Chiwon Song on 10/2/23.
//

import Combine
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var service: DiaryService
    @State private var showingWriterView = false

    private var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack {
            if service.logs.isEmpty {
                NavigationLink(destination: WriterView()) {
                    Image(systemName: "doc.badge.plus")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                Text("오늘의 읽기를 써 보아요")
                    .foregroundStyle(.gray)
                    .padding()
            } else {
                List {
                    ForEach(service.logs) { log in
                        NavigationLink(destination: WriterView(log: log)) {
                            HStack {
                                Text("\(log.emotion.rawValue)")
                                    .font(Font.system(size: 24))
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(log.date.dateString())
                                        Text("\(log.weather.rawValue)")
                                        Spacer()
                                    }
                                    Text(log.text.prefix(30))
                                        .lineLimit(1)
                                        .foregroundStyle(.gray)
                                        .font(Font.system(size: 14))
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
        .navigationTitle("오늘의 일기")
        .navigationBarItems(trailing: NavigationLink(destination: WriterView()) {
            Image(systemName: "doc.badge.plus")
        })
    }
}

#Preview {
    ContentView()
}
