//
//  GalleryView.swift
//  ybs-flickr-challenge
//
//  Created by James Buckley on 18/08/2024.
//

import SwiftUI
import TagCloud

struct GalleryView: View {
    @StateObject var viewModel = GalleryViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    GallerySearchBar()
                    TagModeToggle(isOn: $viewModel.tagMode)
                    GalleryImageList()
                }
                LoadingOverlay()
            }
            .environmentObject(viewModel)
            .navigationTitle("Search Images")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(item: $viewModel.selectedPhoto) { photo in
                FullScreenImageView(image: photo)
            }
            .onAppear {
                if !viewModel.hasLoaded {
                    viewModel.fetchImagesAndTags()
                }
            }
        }
    }
}

struct GallerySearchBar: View {
    @EnvironmentObject var viewModel: GalleryViewModel

    var body: some View {
        HStack {
            TextField("Search Images", text: Binding(
                get: {
                    viewModel.searchQuery.joined(separator: " ")
                },
                set: { newValue in
                    viewModel.searchQuery = newValue.split(separator: " ").map { String($0) }
                }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .onSubmit {
                viewModel.fetchImagesAndTags()
            }
            Button("Search") {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                viewModel.fetchImagesAndTags()
            }
            .padding(.horizontal)
            .frame(height: 30)
            .background(.blue)
            .foregroundColor(.white)
            .font(.system(size: 14, weight: .bold))
            .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
    }
}

struct TagModeToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text("Search photos containing all tags")
        }
        .padding()
    }
}

struct GalleryImageList: View {
    @EnvironmentObject var viewModel: GalleryViewModel

    var body: some View {
        ScrollViewReader { reader in
            ScrollView {
                VStack {
                    ForEach(viewModel.images) { imageData in
                        GalleryImageCell(
                            imageData: imageData,
                            onImageTap: { selectedPhoto in
                                viewModel.selectPhoto(selectedPhoto)
                            },
                            onTagTap: { tag in
                                viewModel.searchQuery.removeAll()
                                viewModel.searchQuery.append(tag)
                                viewModel.fetchImagesAndTags()
                            }
                        )
                    }
                }
                .id("imageList")
            }
            .refreshable {
                viewModel.fetchImagesAndTags()
            }
            .onChange(of: viewModel.images) {
                withAnimation {
                    reader.scrollTo("imageList", anchor: .top)
                }
            }
        }
        //.frame(maxWidth: .infinity) maybe put back?? test
    }
}

struct GalleryImageCell: View {
    @State var showTags: Bool = false
    let imageData: FlickrImageData
    let onImageTap: (FlickrPhoto) -> ()
    let onTagTap: (String) -> ()

    var body: some View {
        VStack {
            Rectangle()
                .fill(.gray)
                .frame(height: 5)
            NavigationLink(destination: UserDetailView(
                viewModel: UserDetailViewModel(user: imageData.user)
            )) {
                ImageProfileHeader(image: imageData.photo, user: imageData.user)
            }
            AsyncImage(url: URL(string: imageData.photo.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Color.gray
                        .frame(width: UIScreen.main.bounds.width)
                        .frame(height: 200)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width, height: 200)
                        .clipped()
                        .contentShape(Rectangle().inset(by: 10))
                        .onTapGesture {
                            onImageTap(imageData.photo)
                        }
                case .failure:
                    Color.red
                        .frame(width: UIScreen.main.bounds.width)
                        .frame(height: 200)
                @unknown default:
                    EmptyView()
                }
            }
            VStack {
                if showTags {
                    TagCloudView(data: imageData.tags) { tag in
                        Button(tag) {
                            onTagTap(tag)
                        }
                        .padding(10)
                        .background(.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                }
                HStack {
                    Text(showTags ? "Hide Tags"  : "Show Tags")
                        .foregroundColor(.blue)
                        .font(.system(size: 14, weight: .bold))
                    Image(systemName: showTags ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                }
                .onTapGesture {
                    withAnimation {
                        showTags.toggle()
                    }
                }
            }
            .padding()
        }
    }
}

struct ImageProfileHeader: View {
    let image: FlickrPhoto
    let user: FlickrUser

    var body: some View {
        let imageSize: CGFloat = 60

        HStack {
            AsyncImage(url: URL(string: user.profileImageUrl)) { phase in
                switch phase {
                case .empty:
                    Color.gray
                        .frame(width: imageSize, height: imageSize)
                        .clipShape(Circle())
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageSize, height: imageSize)
                        .clipShape(Circle())
                case .failure:
                    Color.red
                        .frame(width: imageSize, height: imageSize)
                        .clipShape(Circle())
                @unknown default:
                    EmptyView()
                }
            }
            VStack(alignment: .leading) {
                Text(user.username._content)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(user.id)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .contentShape(Rectangle())
        .buttonStyle(PlainButtonStyle())
    }
}

struct LoadingOverlay: View {
    @EnvironmentObject var viewModel: GalleryViewModel

    var body: some View {
        if viewModel.inProgress {
            ZStack {
                Color.blue
                    .frame(width: 100, height: 100)
                    .cornerRadius(5)
                    .shadow(radius: 10)
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear.edgesIgnoringSafeArea(.all))
        }
    }
}

#Preview {
    GalleryView()
}
