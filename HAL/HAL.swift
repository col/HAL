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
        return get("self")
    }
    
    public func get(key: String, params: [String: AnyObject] = [String: AnyObject]()) -> Promise<HAL> {
        var url = self.link_url(key, params: params)
        return HAL._loadRequest( Alamofire.request(.GET, url) )
    }
    
    public func post(params: [String: AnyObject]) -> Promise<HAL> {
        return post("self", params: params)
    }
    
    public func post(key: String, params: [String: AnyObject]) -> Promise<HAL> {
        var url = self.link_url(key)
        return HAL._loadRequest( Alamofire.request(.POST, url, parameters: params) )
    }
    
    public func put(params: [String: AnyObject]) -> Promise<HAL> {
        return put("self", params: params)
    }
    
    public func put(key: String, params: [String: AnyObject]) -> Promise<HAL> {
        var url = self.link_url(key)
        return HAL._loadRequest( Alamofire.request(.PUT, url, parameters: params) )
    }
    
    public func patch(params: [String: AnyObject]) -> Promise<HAL> {
        return patch("self", params: params)
    }
    
    public func patch(key: String, params: [String: AnyObject]) -> Promise<HAL> {
        var url = self.link_url(key)
        return HAL._loadRequest( Alamofire.request(.PATCH, url, parameters: params) )
    }
    
    public func delete() -> Promise<HAL> {
        return delete("self")
    }
    
    public func delete(key: String) -> Promise<HAL> {
        var url = self.link_url(key)
        return HAL._loadRequest( Alamofire.request(.DELETE, url) )
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
    
    public func link(key: String) -> AnyObject? {
        return _links[key]
    }
    
    public func isTemplated(key: String) -> Bool {
        var link: AnyObject = self.link(key)!
        if link is [String: AnyObject] {
            let templated = link["templated"]
            return templated as? Bool != nil
        }
        return false
    }
    
    public func link_url(key: String, params: [String: AnyObject] = [String: AnyObject]()) -> String {
        var link: AnyObject = self.link(key)!
        
        if link is String {
            return link as String
        } else if link is [String: AnyObject] {
            if self.isTemplated(key) {
                return ExpandURITemplate(link["href"] as String, values: params)
            } else {
                return link["href"] as String
            }
        }
        
        return ""
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


