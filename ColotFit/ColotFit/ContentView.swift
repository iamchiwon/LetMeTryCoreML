//
//  ContentView.swift
//  Colorizer
//
//  Created by Chiwon Song on 10/3/23.
//

import PhotosUI
import SwiftUI

struct ContentView: View {
    private let service = ColorService()

    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var processing = false
    @State private var origin: UIImage?
    @State private var converted: UIImage?

    var body: some View {
        ScrollView {
            VStack {
                if let origin = origin {
                    HStack {
                        Image(uiImage: origin)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .background(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1))
                        Spacer()
                    }
                }

                if let converted = converted {
                    Image(uiImage: converted)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width)
                        .background(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray, lineWidth: 1))
                } else {
                    ZStack {
                        Image(systemName: "photo.artframe")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color(UIColor.systemGray6))
                            .padding(80)
                            .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray, lineWidth: 1))

                        if processing {
                            ProgressView()
                        }
                    }
                }

                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Text("사진선택")
                            .padding(20)
                    }
            }
        }
        .padding()
        .navigationTitle("깔맞춤")
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    origin = uiImage
                    converted = nil
                    processing = true

                    service.colorize(image: uiImage) { result in
                        switch result {
                        case let .success(converted):
                            self.converted = converted
                        case let .failure(error):
                            print(error)
                        }
                        processing = false
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
