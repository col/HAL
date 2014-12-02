//
//  HAL.swift
//  HAL
//
//  Created by Colin Harris on 2/12/14.
//  Copyright (c) 2014 Colin Harris. All rights reserved.
//

import Foundation
import Alamofire

public class HAL {
    
    var _attributes: [String: AnyObject] = [String: AnyObject]()
    var _links: [String: AnyObject] = [String: AnyObject]()
    var _embedded: [String: AnyObject] = [String: AnyObject]()
    
    internal init(response: [String: AnyObject]) {
        
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
    
    public class func get(url: String) -> Promise<HAL> {
        return HAL._loadRequest( Alamofire.request(.GET, url, parameters: nil) )
    }
    
    private class func _loadRequest(request: Alamofire.Request) -> Promise<HAL> {
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
    
    public func get() -> Promise<HAL> {
        return get("self", params: nil)
    }
    
    public func get(key: String, params: [String: AnyObject]? = nil) -> Promise<HAL> {
        var link = self.link(key)
        return HAL._loadRequest( Alamofire.request(.GET, link, parameters: params) )
    }
    
    public func post(params: [String: AnyObject]) -> Promise<HAL> {
        return post("self", params: params)
    }
    
    public func post(key: String, params: [String: AnyObject]) -> Promise<HAL> {
        var link = self.link(key)
        return HAL._loadRequest( Alamofire.request(.POST, link, parameters: params) )
    }
    
    public func put(params: [String: AnyObject]) -> Promise<HAL> {
        return put("self", params: params)
    }
    
    public func put(key: String, params: [String: AnyObject]) -> Promise<HAL> {
        var link = self.link(key)
        return HAL._loadRequest( Alamofire.request(.PUT, link, parameters: params) )
    }
    
    public func patch(params: [String: AnyObject]) -> Promise<HAL> {
        return patch("self", params: params)
    }
    
    public func patch(key: String, params: [String: AnyObject]) -> Promise<HAL> {
        var link = self.link(key)
        return HAL._loadRequest( Alamofire.request(.PATCH, link, parameters: params) )
    }
    
    public func delete() -> Promise<HAL> {
        return delete("self")
    }
    
    public func delete(key: String) -> Promise<HAL> {
        var link = self.link(key)
        return HAL._loadRequest( Alamofire.request(.DELETE, link) )
    }
    
    public func attributes() -> [String: AnyObject] {
        return _attributes
    }
    
    public func attribute(key: String) -> AnyObject! {
        return _attributes[key]
    }
    
    public func links() -> [String: AnyObject] {
        return _links
    }
    
    public func link(key: String) -> String {
        return _links[key] as String
    }
    
    public func embedded() -> [String: AnyObject] {
        return _embedded
    }
    
    public func embedded(key: String) -> AnyObject? {
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


