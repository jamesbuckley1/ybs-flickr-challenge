//
//  MockData.swift
//  ybs-flickr-challengeTests
//
//  Created by James Buckley on 20/08/2024.
//

struct MockData {
    static let mockUser = FlickrUser(
        id: "1",
        nsid: "12345@N00",
        iconserver: "server",
        iconfarm: 1,
        username: FlickrUser.Username(_content: "MockUser")
    )
    
    static let mockPhoto = FlickrPhoto(
        id: "1",
        title: "Test Photo",
        farm: 1,
        server: "server",
        secret: "secret",
        owner: "12345@N00", 
        datetaken: "1-1-11"
    )
    
    static let mockImageData = FlickrImageData(
        id: "1",
        user: mockUser,
        photo: mockPhoto,
        tags: ["tag1", "tag2"]
    )
    
    static let mockFlickrResponse = FlickrResponse(
        photos: FlickrPhotos(
            photo: [mockPhoto]
        )
    )
    
    static let mockUserResponse = FlickrUserResponse(person: mockUser)
}
