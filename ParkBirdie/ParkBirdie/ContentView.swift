//
//  ContentView.swift
//  ParkBirdie
//
//  Created by Chiwon Song on 10/2/23.
//

import Combine
import CoreLocation
import SwiftUI

struct ContentView: View {
    private let parkService = ParkService()
    private let birdService = BirdService()
    private var cancellable = Set<AnyCancellable>()

    @State private var image: UIImage?
    @State private var hasBird: Bool = false
    @State private var showingImagePicker = false

    var body: some View {
        ScrollView {
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width)
                        .background(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray, lineWidth: 1))
                } else {
                    Image(systemName: "bird")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color(UIColor.systemGray6))
                        .padding(80)
                        .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray, lineWidth: 1))
                }

                Button("  📷 사진찍기 🐤  ") {
                    showingImagePicker = true
                }
                .buttonStyle(.borderedProminent)

                HStack(spacing: 20) {
                    if let park = parkService.park {
                        Text(park.name)
                            .font(Font.system(size: 24, weight: .bold))
                    }

                    Image(systemName: "bird.circle.fill")
                        .resizable()
                        .foregroundColor(birdService.hasBird ? .green : Color(UIColor.systemGray4))
                        .frame(width: 50, height: 50)
                }
                .padding(40)
            }
        }
        .navigationTitle("찍새")
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $image)
        }
        .onChange(of: image) { _, newValue in
            guard let _ = newValue else { return }
            birdService.predict(uiImage: newValue)
        }
    }
}

#Preview {
    ContentView()
}
