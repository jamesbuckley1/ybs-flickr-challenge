//
//  FlickrPhoto.swift
//  ybs-flickr-challenge
//
//  Created by James Buckley on 20/08/2024.
//

struct FlickrPhoto: Decodable, Identifiable, Equatable {
    let id: String
    let title: String
    let farm: Int
    let server: String
    let secret: String
    let owner: String
    let datetaken: String?
    
    var imageUrl: String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_m.jpg"
    }
}
