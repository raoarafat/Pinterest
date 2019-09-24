//
//  NetworkingTests.swift
//  NetworkingTests
//
//  Created by arafat on 9/21/19.
//  Copyright © 2019 Pinterest. All rights reserved.
//

import XCTest
@testable import Networking
import Model

class NetworkingTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testApi() {
       let promise = expectation(description: "Completion handler invoked")
        HTTPClient.request(for: [Photo].self, url: .photos, method: .get) { result in
                            switch result {
                            case let .success(photos):
                                 XCTAssertEqual(photos[0].id, "4kQA1aQK8-Y")
                                  promise.fulfill()
                            case let .failure(error):
                                   XCTFail("Error: \(error)")
                            }
                        }

        wait(for: [promise], timeout: 10)
    }

    func testPerformance() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
