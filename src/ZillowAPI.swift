//
//  ZillowAPI.swift
//  Puul
//
//  Created by Wheezy Salem on 8/1/23.
//

import Foundation

class ZillowAPI: ObservableObject {
    
    func getPropertiesByLocation(location: String) {
        let headers = [
            "X-RapidAPI-Key": "3a9af3868dmsh52b45a304525c23p1302a5jsna2194ff6b439",
            "X-RapidAPI-Host": "zillow-com1.p.rapidapi.com"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://zillow-com1.p.rapidapi.com/propertyExtendedSearch?location=" + location)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
            }
        })
        
        dataTask.resume()
    }
}
