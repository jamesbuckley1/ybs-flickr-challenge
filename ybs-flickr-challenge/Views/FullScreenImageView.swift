//
//  FullScreenImageView.swift
//  ybs-flickr-challenge
//
//  Created by James Buckley on 21/08/2024.
//

import SwiftUI

struct FullScreenImageView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let minZoom: CGFloat = 1
    var image: FlickrPhoto
    
    @State var scale: CGFloat = 1
    @State private var imageScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            if let url = URL(string: image.imageUrl) {
                VStack {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(x: max(scale, minZoom), y: max(scale, minZoom))
                            .gesture(magnification)
                    } placeholder: {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                    Text(image.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    if let dateTaken = image.datetaken {
                        Text("Date Taken: \(dateTaken)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.top, 5)
                    }
                }
            }
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .imageScale(.large)
                            .frame(width: 44, height: 44, alignment: .center)
                    }
                    .padding(10)
                }
                Spacer()
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 50 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )
    }
    
    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                self.scale = scale
            }
    }
}

