//
//  GalleryView.swift
//  ybs-flickr-challenge
//
//  Created by James Buckley on 18/08/2024.
//

import SwiftUI

struct GalleryView: View {
    @StateObject var viewModel = GalleryViewModel()
    
    let spacing: CGFloat = 20
    
    var body: some View {
        NavigationStack {
            VStack {

                TextField("Search Images", text: $viewModel.searchQuery, onCommit: {
                    viewModel.fetchImages()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(spacing)
                
        
                ScrollView {
                    VStack(spacing: spacing) {
                        ForEach(viewModel.images) { imageData in
                            VStack(spacing: 10) {
                                
                     
                                ImageProfileHeader(image: imageData.photo, user: imageData.user)
                                
                                
                                
                                
                                AsyncImage(url: URL(string: imageData.photo.imageUrl)) { phase in
                                    switch phase {
                                    case .empty:
                                        Color.gray
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 200)
                                    
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 200)
                                            .clipped()
                                 
                                    case .failure:
                                        Color.red
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 200)
                                
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                
                                
                                //.padding(.horizontal, spacing)
                            }
                            //.padding(.horizontal, spacing)
                        }
                    }
                    .padding(.vertical, spacing)
                }
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Search Images")
            .onAppear {
                viewModel.fetchImages()
            }
        }
    }
}

struct ImageProfileHeader: View {
    let image: FlickrPhoto
    let user: FlickrUser

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: image.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Color.gray
                        .frame(width: 40, height: 40)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipped()
                case .failure:
                    Color.red
                        .frame(width: 40, height: 40)
                @unknown default:
                    EmptyView()
                }
            }
            
            VStack(alignment: .leading) {
                Text(user.username._content) 
                    .font(.headline)
                Button(action: {
                    print("Button tapped for image: \(image.id)")
                }) {
                    Text("View Details")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.blue)
                        .cornerRadius(5)
                }
            }
            .padding(.leading, 10)
        }
    }
}

#Preview {
    GalleryView()
}
