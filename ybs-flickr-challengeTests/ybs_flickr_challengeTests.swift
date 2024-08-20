//
//  ybs_flickr_challengeTests.swift
//  ybs-flickr-challengeTests
//
//  Created by James Buckley on 18/08/2024.
//

import Combine
import XCTest
@testable import ybs_flickr_challenge

final class ybs_flickr_challengeTests: XCTestCase {
    
    var viewModel: MockGalleryViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        super.setUp()
        viewModel = MockGalleryViewModel()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }

    func testFetchImagesAndTagsSuccess() {
            viewModel.mockResponse = Just(MockData.mockFlickrResponse)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
            
            viewModel.mockTagsResponse = Just(["tag1", "tag2"])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
            
            viewModel.mockUserResponse = Just(MockData.mockUserResponse)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
            
            let expectation = XCTestExpectation(description: "Images and tags fetched successfully")
            

            viewModel.fetchImagesAndTags()
            

            viewModel.$images
                .dropFirst()
                .sink { images in
                    XCTAssertEqual(images.count, 1)
                   
                    expectation.fulfill()
                }
                .store(in: &cancellables)
            
            wait(for: [expectation], timeout: 5.0)
        }
        
        func testFetchImagesAndTagsFailure() {
   
            viewModel.mockResponse = Fail(error: URLError(.badServerResponse))
                .eraseToAnyPublisher()
            
            let expectation = XCTestExpectation(description: "Error fetching images and tags")
            

            viewModel.fetchImagesAndTags()
            

            viewModel.$inProgress
                .dropFirst()
                .sink { inProgress in
                    XCTAssertFalse(inProgress) 
                    expectation.fulfill()
                }
                .store(in: &cancellables)
            
            wait(for: [expectation], timeout: 5.0)
        }

}
