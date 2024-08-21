//
//  UserDetailView.swift
//  ybs-flickr-challenge
//
//  Created by James Buckley on 20/08/2024.
//

import SwiftUI

struct UserDetailView: View {
    @StateObject var viewModel: UserDetailViewModel
    
    let columns = Array.init(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        VStack {
            UserProfileHeader(user: viewModel.user)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(viewModel.photos) { photo in
                        AsyncImage(url: URL(string: photo.imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                Color.gray
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(5)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(5)
                                    .onTapGesture {
                                        viewModel.selectPhoto(photo)
                                    }
                            case .failure:
                                Color.red
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(5)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
                .padding(.top, 10)
            }
            .refreshable {
                viewModel.fetchUserPhotos(isRefresh: true)
            }
        }
        .padding()
        .navigationTitle("User Details")
        .onAppear {
            viewModel.fetchUserPhotos()
        }
        .fullScreenCover(item: $viewModel.selectedPhoto) { photo in
            FullScreenImageView(image: photo)
        }
    }
}

struct UserProfileHeader: View {
    let user: FlickrUser
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: user.profileImageUrl)) { phase in
                switch phase {
                case .empty:
                    Color.gray
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                case .failure:
                    Color.red
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                @unknown default:
                    EmptyView()
                }
            }
            .padding(.top)
            Text(user.username._content)
                .font(.title)
                .padding(.top, 8)
            Text("User ID: \(user.id)")
                .font(.subheadline)
                .padding(.bottom, 16)
        }
    }
}
