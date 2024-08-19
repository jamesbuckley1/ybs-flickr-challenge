//
//  GalleryViewModel.swift
//  ybs-flickr-challenge
//
//  Created by James Buckley on 18/08/2024.
//

import Combine
import SwiftUI

class GalleryViewModel: ObservableObject {
    @Published var searchQuery: String = "Yorkshire"
    //@Published var images: [FlickrPhoto] = []
    @Published var images: [FlickrImageData] = []
    @Published var inProgress: Bool = false
    
    
    var selectedImage: Image?
    
    private var cancellables = Set<AnyCancellable>()

    func fetch<T: Decodable>(url: URL, decodingType: T.Type) -> AnyPublisher<T, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: decodingType, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func fetchImages() {
        guard let apiKey = Bundle.main.infoDictionary?["API Key"] as? String, !searchQuery.isEmpty else { return }
        

          
          let urlString = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&format=json&nojsoncallback=1&extras=url_m&per_page=20&text=\(searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&safe_search=1"
          
          guard let url = URL(string: urlString) else { return }
          
          inProgress = true
          
          fetch(url: url, decodingType: FlickrResponse.self)
              .flatMap { [weak self] response -> AnyPublisher<[FlickrImageData], Never> in
                  guard let self = self else { return Just([]).eraseToAnyPublisher() }
                  return self.fetchUserNames(for: response.photos.photo)
              }
              .sink(receiveCompletion: { [weak self] completion in
                  self?.inProgress = false
                  if case .failure(let error) = completion {
                      print("Error fetching images: \(error.localizedDescription)")
                  }
              }, receiveValue: { [weak self] imagesWithUsers in
                  self?.images = imagesWithUsers
              })
              .store(in: &cancellables)
      }

    func fetchUserNames(for photos: [FlickrPhoto]) -> AnyPublisher<[FlickrImageData], Never> {
        let publishers = photos.map { photo in
            fetchUserInfo(userId: photo.owner)
                .map { response -> FlickrImageData in
                    FlickrImageData(id: photo.id, user: response.person, photo: photo)
                }
                .catch { error -> Just<FlickrImageData> in
                    print("Error fetching user info for photo \(photo.id): \(error)")
                    return Just(FlickrImageData(id: photo.id, user: FlickrUser(id: "0", username:FlickrUser.Username(_content: "Unknown user")), photo: photo))
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
}




struct FlickrResponse: Codable {
    let photos: FlickrPhotos
}

struct FlickrPhotos: Codable {
    let photo: [FlickrPhoto]
}

struct FlickrPhoto: Codable, Identifiable {
    let id: String
    let title: String
    let farm: Int
    let server: String
    let secret: String
    let owner: String
    

    var imageUrl: String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_m.jpg"
    }
}








struct FlickrUserResponse: Decodable {
    let person: FlickrUser
}

struct FlickrUser: Decodable {
    let id: String
    let username: Username

    
    struct Username: Decodable {
        let _content: String
    }

}
