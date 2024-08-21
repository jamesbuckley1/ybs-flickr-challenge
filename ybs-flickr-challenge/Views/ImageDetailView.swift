//
//  ImageDetailView.swift
//  ybs-flickr-challenge
//
//  Created by James Buckley on 18/08/2024.
//

import SwiftUI

struct ImageDetailView: View {
    let image: FlickrPhoto
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(.gray)
                .frame(height: 300)
                .cornerRadius(10)
            Text("Image Details")
                .font(.headline)
                .padding()
            Spacer()
        }
        .navigationTitle("Image Details")
        .padding()
    }
}

#Preview {
    ImageDetailView(
        image: FlickrPhoto(
            id: "id",
            title: "photo",
            farm: 0,
            server: "server",
            secret: "secret",
            owner: "owner",
            datetaken: nil)
    )
}
