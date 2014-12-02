//
//  HAL.swift
//  HAL
//
//  Created by Colin Harris on 2/12/14.
//  Copyright (c) 2014 Colin Harris. All rights reserved.
//

import Foundation
import Alamofire

class HAL {

    var _attributes: [String: AnyObject] = [String: AnyObject]()
    var _links: [String: AnyObject] = [String: AnyObject]()
    var _embedded: [String: AnyObject] = [String: AnyObject]()
    
    init(response: [String: AnyObject]) {
        
        if let links = response["_links"] as? [String: AnyObject] {
            self._links = links
        }
        
        if let embedded = response["_embedded"] as? [String: AnyObject] {
            self._embedded = embedded
        }
        
        self._attributes = response
        self._attributes.removeValueForKey("_links")
        self._attributes.removeValueForKey("_embedded")
    }
    
    class func get(url: String) -> Promise<HAL> {
        return HAL._loadRequest( Alamofire.request(.GET, url, parameters: nil) )
    }
    
    class func _loadRequest(request: Alamofire.Request) -> Promise<HAL> {
        return Promise<HAL> { (success, failure) in
            request.responseJSON { (request, response, data, error) in
                if( error != nil ) {
                    failure( error! )
                } else {
                    var client = HAL(response: data as Dictionary)
                    success( client )
                }
            }
            return
        }
    }

    func get() -> Promise<HAL> {
        return get("self", params: nil)
    }
    
    func get(key: String, params: [String: AnyObject]? = nil) -> Promise<HAL> {
        var link = self.link(key)
        return HAL._loadRequest( Alamofire.request(.GET, link, parameters: params) )
    }

    func post(params: [String: AnyObject]) -> Promise<HAL> {
        return post("self", params: params)
    }
    
    func post(key: String, params: [String: AnyObject]) -> Promise<HAL> {
        var link = self.link(key)
        return HAL._loadRequest( Alamofire.request(.POST, link, parameters: params) )
    }

    func put(params: [String: AnyObject]) -> Promise<HAL> {
        return put("self", params: params)
    }
    
    func put(key: String, params: [String: AnyObject]) -> Promise<HAL> {
        var link = self.link(key)
        return HAL._loadRequest( Alamofire.request(.PUT, link, parameters: params) )
    }

    func patch(params: [String: AnyObject]) -> Promise<HAL> {
        return patch("self", params: params)
    }
    
    func patch(key: String, params: [String: AnyObject]) -> Promise<HAL> {
        var link = self.link(key)
        return HAL._loadRequest( Alamofire.request(.PATCH, link, parameters: params) )
    }

    func delete() -> Promise<HAL> {
        return delete("self")
    }
    
    func delete(key: String) -> Promise<HAL> {
        var link = self.link(key)
        return HAL._loadRequest( Alamofire.request(.DELETE, link) )
    }
    
    func attributes() -> [String: AnyObject] {
        return _attributes
    }
    
    func attribute(key: String) -> AnyObject! {
        return _attributes[key]
    }
    
    func links() -> [String: AnyObject] {
        return _links
    }
    
    func link(key: String) -> String {
        return _links[key] as String
    }
    
    func embedded() -> [String: AnyObject] {
        return _embedded
    }
    
    func embedded(key: String) -> AnyObject? {
        let value: AnyObject? = _embedded[key]?
        if value != nil {
            if value is Array<[String: AnyObject]> {
                let values = value as Array<[String: AnyObject]>
                return values.map { (object) -> HAL in
                    return HAL(response: object)
                }
            }
            else {
                return HAL(response: value as Dictionary)
            }
        }
        return nil
    }
    
}


