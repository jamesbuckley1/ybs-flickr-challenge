//
//  MockGalleryViewModel.swift
//  ybs-flickr-challengeTests
//
//  Created by James Buckley on 20/08/2024.
//

import Combine
import Foundation

class MockGalleryViewModel: GalleryViewModel {
    var mockResponse: AnyPublisher<FlickrResponse, Error>?
    var mockTagsResponse: AnyPublisher<[String], Error>?
    var mockUserResponse: AnyPublisher<FlickrUserResponse, Error>?
    
    override func fetch<T: Decodable>(url: URL, decodingType: T.Type) -> AnyPublisher<T, Error> {
        if decodingType == FlickrResponse.self {
            return mockResponse!.map { $0 as! T }.eraseToAnyPublisher()
        } else if decodingType == FlickrTagsResponse.self {
            return mockTagsResponse!.map { $0 as! T }.eraseToAnyPublisher()
        } else if decodingType == FlickrUserResponse.self {
            return mockUserResponse!.map { $0 as! T }.eraseToAnyPublisher()
        } else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
    }
}
