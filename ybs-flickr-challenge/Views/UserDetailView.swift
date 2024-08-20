//
//  UserDetailView.swift
//  ybs-flickr-challenge
//
//  Created by James Buckley on 20/08/2024.
//

import SwiftUI

struct UserDetailView: View {
    @ObservedObject var viewModel: UserDetailViewModel

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        
        
        VStack {
       
                    VStack {
                        AsyncImage(url: URL(string: viewModel.user.profileImageUrl)) { phase in
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

                        Text(viewModel.user.username._content)
                            .font(.title)
                            .padding(.top, 8)

                        Text("User ID: \(viewModel.user.id)")
                            .font(.subheadline)
                            .padding(.bottom, 16)
                    }

             
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
                            //onDismiss()
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


//#Preview {
//    UserDetailView()
//}
