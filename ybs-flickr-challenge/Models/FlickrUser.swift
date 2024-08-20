//
//  FlickrUser.swift
//  ybs-flickr-challenge
//
//  Created by James Buckley on 20/08/2024.
//

struct FlickrUser: Decodable, Hashable {
    let id: String
    let nsid: String
    let iconserver: String
    let iconfarm: Int
    let username: Username

    var profileImageUrl: String {
        if iconserver == "0" {
            return "https://www.flickr.com/images/buddyicon.gif"
        } else {
            return "https://farm\(iconfarm).staticflickr.com/\(iconserver)/buddyicons/\(nsid).jpg"
        }
    }
    
    struct Username: Decodable, Hashable {
        let _content: String
    }
}
