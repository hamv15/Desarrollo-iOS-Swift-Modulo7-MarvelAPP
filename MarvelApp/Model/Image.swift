//
//  Image.swift
//  MarvelApp
//
//  Created by Juan Carlos Díaz Valenzuela on 03/05/24.
//

import Foundation

struct Image : Codable {
    let path : String
    let fileExtension : String
    
    var url : String {
        return path+"."+fileExtension
    }
    
    enum CodingKeys : String, CodingKey{
        case path = "path"
        case fileExtension = "extension"
    }
}
