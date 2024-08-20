//
//  FlickrTagResponse.swift
//  ybs-flickr-challenge
//
//  Created by James Buckley on 20/08/2024.
//

struct FlickrTagsResponse: Decodable {
    let photo: FlickrPhotoTags
    
    struct FlickrPhotoTags: Decodable {
        let tags: FlickrTags
        
        struct FlickrTags: Decodable {
            let tag: [FlickrTag]
        }
    }
}
