//
//  FlickrImageData.swift
//  ybs-flickr-challenge
//
//  Created by James Buckley on 19/08/2024.
//

struct FlickrImageData: Identifiable, Equatable {
    let id: String
    let user: FlickrUser
    let photo: FlickrPhoto
    var tags: [String] = []
    
    static func == (lhs: FlickrImageData, rhs: FlickrImageData) -> Bool {
        return lhs.id == rhs.id &&
               lhs.user == rhs.user &&
               lhs.photo == rhs.photo &&
               lhs.tags == rhs.tags
    }
}
