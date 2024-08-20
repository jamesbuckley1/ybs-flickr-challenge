//
//  UserDetailViewModel.swift
//  ybs-flickr-challenge
//
//  Created by James Buckley on 20/08/2024.
//

import Combine
import SwiftUI

class UserDetailViewModel: ObservableObject {
    let user: FlickrUser
    @Published var photos: [FlickrPhoto] = []
    @Published var inProgress: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var hasLoaded: Bool = false
    @Published var selectedPhoto: FlickrPhoto? = nil
    private var cancellables = Set<AnyCancellable>()
    
    init(user: FlickrUser) {
        self.user = user
    }
    
    func fetch<T: Decodable>(url: URL, decodingType: T.Type) -> AnyPublisher<T, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: decodingType, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchUserPhotos(isRefresh: Bool = false) {
        if hasLoaded && !isRefresh { return }
        
        if !isRefresh {
            inProgress = true
        } else {
            isRefreshing = true
        }
        
        guard let apiKey = Bundle.main.infoDictionary?["API Key"] as? String else {
            print("API Key not found")
            return
        }
        
        let urlString = "https://www.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&api_key=\(apiKey)&format=json&nojsoncallback=1&user_id=\(user.id)&extras=url_m"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        fetch(url: url, decodingType: FlickrResponse.self)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    print("Error fetching user photos: \(error)")
                }
                self?.inProgress = false
                self?.isRefreshing = false
                self?.hasLoaded = true
            }, receiveValue: { [weak self] response in
                self?.photos = response.photos.photo
            })
            .store(in: &cancellables)
    }
    
    func selectPhoto(_ photo: FlickrPhoto) {
            selectedPhoto = photo
        }

        func deselectPhoto() {
            //selectedPhoto = nil
        }
}
