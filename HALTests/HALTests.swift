//
//  HALTests.swift
//  HALTests
//
//  Created by Colin Harris on 2/12/14.
//  Copyright (c) 2014 Colin Harris. All rights reserved.
//

import UIKit
import XCTest
import Alamofire

class HALTests: XCTestCase {
    
    let basicHalResponse: Dictionary<String, AnyObject> = [
        "message": "Hello",
        "_links": ["self": "http://example.org"],
        "_embedded": [
            "author": [
                "name": "Doctor Green",
                "_links": [
                    "self": "http://example.org/author/doctor_green"
                ]
            ]
        ]
    ]
    
    let embeddedObjects: Dictionary<String, AnyObject> = [
        "message": "Hello",
        "_links": ["self": "http://example.org"],
        "_embedded": [
            "items": [
                [
                    "title": "Thingymabob",
                    "description": "blah",
                    "_links": [
                        "self": "http://example.org/item/1"
                    ]
                ]
            ]
        ]
    ]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Alamofire.request(.GET, sampleApiUrl+"/reset")
            .responseJSON { (request, response, data, error) in
                let response = data as [String: AnyObject]
                let status = response["status"] as String
                NSLog("Reset sample API: %@", status);
            }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Unit Tests
    
    func testAttributes() {
        let halResource = HAL(response: basicHalResponse)
        XCTAssertEqual(halResource.attributes().count, 1)
        XCTAssertEqual(halResource.attribute("message") as String, "Hello")
    }

    func testLinks() {
        let halResource = HAL(response: basicHalResponse)
        XCTAssertEqual(halResource.links().count, 1)
        XCTAssertEqual(halResource.link("self") as String, "http://example.org")
    }
    
    func testTemplatedLink() {
        let response = [
            "_links": [
                "self": ["href": "http://example.org"],
                "item-search": [
                    "href": "http://example.org/items?q={search}",
                    "templated": true
                ]
            ]
        ]
        let halResource = HAL(response: response)
        XCTAssertEqual(halResource.link_url("item-search", params: ["search": "query_string"]), "http://example.org/items?q=query_string")
    }

    func testEmbeddedObject() {
        let halResource = HAL(response: basicHalResponse)
        XCTAssertEqual(halResource.embedded().count, 1)
        
        let author = halResource.embedded("author") as HAL
        XCTAssertEqual(author.attributes().count, 1)
        XCTAssertEqual(author.attribute("name") as String, "Doctor Green")
    }
    
    func testEmbeddedArray() {
        let halResource = HAL(response: embeddedObjects)
        XCTAssertEqual(halResource.embedded().count, 1)
        
        let items = halResource.embedded("items") as [HAL]
        XCTAssertEqual(items.count, 1)
        let item = items.first
        XCTAssertEqual(item?.attribute("title") as String, "Thingymabob")
    }
    
    // TODO: find a way to mock out Alamofire and write more unit tests rather than integration tests.
    

    // Integration Tests (see sample_api)

    let sampleApiUrl = "http://sample-hal-api.herokuapp.com"
    
    func testClassGet() {
        let success = expectationWithDescription("is successful")
        
        HAL.get(sampleApiUrl).then { (client) -> Void in
            XCTAssertEqual(client.attributes().count, 1)
            XCTAssertEqual(client.attribute("message") as String, "Hello")
            XCTAssertEqual(client.links().count, 2)
            XCTAssertEqual(client.link_url("self"), self.sampleApiUrl)
            XCTAssertEqual(client.link_url("items"), self.sampleApiUrl+"/items")
            XCTAssertEqual(client.embedded().count, 0)
            success.fulfill()
        }
        
        waitForExpectationsWithTimeout(3, handler: nil)
    }
    
    func testGet() {
        let success = expectationWithDescription("is successful")
        
        HAL.get(sampleApiUrl).then(body: { (client) -> Promise<HAL> in
            return client.get("items")
        }).then(body: { (collection) -> Void in
            XCTAssertEqual(collection.attributes().count, 0)
            XCTAssertEqual(collection.links().count, 1)
            XCTAssertEqual(collection.link_url("self"), self.sampleApiUrl+"/items")
            XCTAssertEqual(collection.embedded().count, 1)
            let items: [HAL] = collection.embedded("items") as [HAL]
            XCTAssertEqual(items.count, 0)
            success.fulfill()
        })
        
        waitForExpectationsWithTimeout(3, handler: nil)
    }

    func testPost() {
        let success = expectationWithDescription("is successful")
        
        HAL.get(sampleApiUrl).then(body: { (client) -> Promise<HAL> in
            let newItem = [
                "title": "New Item",
                "description": "Created via the unit tests!"
            ]
            return client.post("items", params: newItem)
        }).then(body: { (resource) -> Void in
            XCTAssertEqual(resource.attributes().count, 2)
            XCTAssertEqual(resource.attribute("title") as String, "New Item")
            XCTAssertEqual(resource.attribute("description") as String, "Created via the unit tests!")
            XCTAssertEqual(resource.links().count, 1)
            XCTAssertTrue(resource.link_url("self").hasPrefix(self.sampleApiUrl+"/items/"))
            success.fulfill()
        })
        
        waitForExpectationsWithTimeout(3, handler: nil)
    }
    
    func testPut() {
        let success = expectationWithDescription("is successful")
        
        HAL.get(sampleApiUrl).then(body: { (client) -> Promise<HAL> in
            let newItem = [
                "title": "New Item",
                "description": "Created via the unit tests!"
            ]
            return client.post("items", params: newItem)
        }).then(body: { (resource) -> Promise<HAL> in
            let updatedItem = [
                "title": "New Item2",
                "description": "Updated via the unit tests!"
            ]
            return resource.put(updatedItem);
        }).then(body: { (resource) -> Void in
            XCTAssertEqual(resource.attributes().count, 2)
            XCTAssertEqual(resource.attribute("title") as String, "New Item2")
            XCTAssertEqual(resource.attribute("description") as String, "Updated via the unit tests!")
            XCTAssertEqual(resource.links().count, 1)
            XCTAssertTrue(resource.link_url("self").hasPrefix(self.sampleApiUrl+"/items/"))
            success.fulfill()
        });
        
        waitForExpectationsWithTimeout(3, handler: nil)
    }
    
    func testPatch() {
        let success = expectationWithDescription("is successful")
        
        HAL.get(sampleApiUrl).then(body: { (client) -> Promise<HAL> in
            let newItem = [
                "title": "New Item",
                "description": "Created via the unit tests!"
            ]
            return client.post("items", params: newItem)
        }).then(body: { (resource) -> Promise<HAL> in
            let updatedItem = [
                "title": "New Item2",
                "description": "Updated via the unit tests!"
            ]
            return resource.patch(updatedItem);
        }).then(body: { (resource) -> Void in
            XCTAssertEqual(resource.attributes().count, 2)
            XCTAssertEqual(resource.attribute("title") as String, "New Item2")
            XCTAssertEqual(resource.attribute("description") as String, "Updated via the unit tests!")
            XCTAssertEqual(resource.links().count, 1)
            XCTAssertTrue(resource.link_url("self").hasPrefix(self.sampleApiUrl+"/items/"))
            success.fulfill()
        });
        
        waitForExpectationsWithTimeout(3, handler: nil)
    }
    
    func testDelete() {
        let success = expectationWithDescription("is successful")
        
        HAL.get(sampleApiUrl).then(body: { (client) -> Promise<HAL> in
            let newItem = [
                "title": "New Item",
                "description": "Created via the unit tests!"
            ]
            return client.post("items", params: newItem)
        }).then(body: { (resource) -> Promise<HAL> in
            return resource.delete();
        }).then(body: { (resource) -> Void in
            XCTAssertEqual(resource.attributes().count, 1)
            XCTAssertEqual(resource.attribute("message") as String, "Item deleted!")
            success.fulfill()
        });
        
        waitForExpectationsWithTimeout(3, handler: nil)
    }
    
}
