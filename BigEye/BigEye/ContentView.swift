//
//  ContentView.swift
//  BigEye
//
//  Created by Chiwon Song on 10/3/23.
//

import PhotosUI
import SwiftUI

struct ContentView: View {
    private let service = ReaderService()

    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var image: UIImage?

    var body: some View {
        ScrollView {
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width)
                        .background(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray, lineWidth: 1))
                        .padding(.bottom, 20)
                } else {
                    Image(systemName: "photo.artframe")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color(UIColor.systemGray6))
                        .padding(80)
                        .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray, lineWidth: 1))
                        .padding(.bottom, 20)
                }

                if let recognized = service.recognized {
                    Text(recognized)
                }

                if let message = service.message {
                    Text(message)
                        .foregroundStyle(.red)
                }
                
                if service.processing {
                    ProgressView()
                }
            }
            .padding()
        }
        .navigationTitle("왕눈이")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Image(systemName: "photo.badge.plus")
                    }
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    image = uiImage

                    service.recognaizeText(image: uiImage)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
