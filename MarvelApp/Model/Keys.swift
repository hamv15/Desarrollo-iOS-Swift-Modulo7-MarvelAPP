//
//  Keys.swift
//  MarvelApp
//
//  Created by Rafael González on 01/05/24.
//

import Foundation

struct Keys : Codable {
    let privateKey : String
    let publicKey : String
    
//   init method
    init(privateKey: String, publicKey: String) {
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
    
//    CodingKey enum maps the struct properties and the names used in json file
    enum CodingKeys : String, CodingKey{
        case publicKey = "public_key"
        case privateKey = "private_key"
    }
}
