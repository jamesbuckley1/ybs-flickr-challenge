//
//  GalleryViewModel.swift
//  ybs-flickr-challenge
//
//  Created by James Buckley on 18/08/2024.
//

import Combine
import SwiftUI

class GalleryViewModel: ObservableObject {
    @Published var searchQuery: [String] = ["Yorkshire"]
    @Published var images: [FlickrImageData] = []
    @Published var inProgress: Bool = false
    
    @Published var shouldPresentUserDetailView: Bool = false
    
    @Published var isRefreshing: Bool = false
    @Published var hasLoaded: Bool = false
    
    @Published var selectedPhoto: FlickrPhoto? = nil
    @Published var selectedTag: String? = nil
    
    @Published var tagMode: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    //var selectedTag: FlickrTag
    

    func fetch<T: Decodable>(url: URL, decodingType: T.Type) -> AnyPublisher<T, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: decodingType, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    

    func fetchImagesAndTags() {
//        if !isRefresh {
//            hasLoaded = false
//        }
        
       // if hasLoaded { return }

//        if !isRefresh {
//            inProgress = true
//        } else {
//            isRefreshing = true
//        }
        
        inProgress = true
        
        fetchImages(withTags: searchQuery)
            .flatMap { images in
                Publishers.MergeMany(images.map { image in
                    self.fetchImageTags(for: image.photo)
                        .map { tags -> FlickrImageData in
                            var updatedImage = image
                            updatedImage.tags = tags
                            return updatedImage
                        }
                        .replaceError(with: image) // Return original image data if tags fetching fails
                })
                .collect()
            }
            .handleEvents(receiveOutput: { imagesWithTags in
                print("Fetched Images with Tags: \(imagesWithTags)")
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching images and tags: \(error)")
                }
                self.inProgress = false
                self.hasLoaded = true
            }, receiveValue: { imagesWithTags in
                self.images = imagesWithTags
                
            })
            .store(in: &cancellables)
    }
    
    func fetchImages(withTags tagsArray: [String]) -> AnyPublisher<[FlickrImageData], Error> {
        guard let apiKey = Bundle.main.infoDictionary?["API Key"] as? String, !tagsArray.isEmpty else {
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        }
        
        let tags = searchQuery.joined(separator: ",")
        let tagModeString = tagMode ? "all" : "any" 
        
        let urlString = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&format=json&nojsoncallback=1&extras=url_m&tags=\(tags)&tag_mode=\(tagModeString)&per_page=20"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return fetch(url: url, decodingType: FlickrResponse.self)
            .flatMap { [weak self] response -> AnyPublisher<[FlickrImageData], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                return self.fetchUserNames(for: response.photos.photo)
            }
            .eraseToAnyPublisher()
    }

    func fetchImageTags(for photo: FlickrPhoto) -> AnyPublisher<[String], Error> {
        guard let apiKey = Bundle.main.infoDictionary?["API Key"] as? String else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        
        let urlString = "https://www.flickr.com/services/rest/?method=flickr.tags.getListPhoto&api_key=\(apiKey)&format=json&nojsoncallback=1&photo_id=\(photo.id)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: FlickrTagsResponse.self, decoder: JSONDecoder())
            .map { response in
                response.photo.tags.tag.map { $0.raw }
            }
            .eraseToAnyPublisher()
    }

    
    func fetchUserNames(for photos: [FlickrPhoto]) -> AnyPublisher<[FlickrImageData], Never> {
        let publishers = photos.map { photo in
            fetchUserInfo(userId: photo.owner)
                .map { response -> FlickrImageData in
                    FlickrImageData(id: photo.id, user: response.person, photo: photo)
                }
                .catch { _ in
                    Just(FlickrImageData(
                        id: photo.id,
                        user: FlickrUser(
                            id: "0",
                            nsid: "0",
                            iconserver: "0",
                            iconfarm: 0,
                            username: FlickrUser.Username(_content: "Unknown user")
                        ),
                        photo: photo
                    ))
                }
                .eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(publishers)
            .collect()
            .eraseToAnyPublisher()
    }
    

    func fetchUserInfo(userId: String) -> AnyPublisher<FlickrUserResponse, Error> {
        guard let apiKey = Bundle.main.infoDictionary?["API Key"] as? String else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        
        let urlString = "https://www.flickr.com/services/rest/?method=flickr.people.getInfo&api_key=\(apiKey)&format=json&nojsoncallback=1&user_id=\(userId)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return fetch(url: url, decodingType: FlickrUserResponse.self)
    }
    
//    func navigateToTagView(tag: FlickrTag) {
//        
//    }
//    
//    func navigateToUserView() {
//        shouldPresentUserDetailView = true
//    }
    
    func selectPhoto(_ photo: FlickrPhoto) {
            selectedPhoto = photo
        }
    
    func selectTag(tag: String) {
        selectedTag = tag
    }
}















