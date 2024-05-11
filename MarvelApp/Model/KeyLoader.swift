//
//  KeyLoader.swift
//  MarvelApp
//
//  Created by Rafael González on 01/05/24.
//

import Foundation

class KeyLoader{
    static let shared = KeyLoader()
    
    var privateKey = ""
    var publicKey = ""
    var ts = ""
    var hash = ""
    
//    init method load keys from file
    private init() {
        if let file = Bundle.main.url(forResource: "marvel", withExtension: "keys"){
            do{
                let data = try Data(contentsOf: file)
                let myKeys = try JSONDecoder().decode(Keys.self, from: data)
                privateKey = myKeys.privateKey
                publicKey = myKeys.publicKey
            }
            catch let error{
                print("Error: ", error)
            }
        }
    }
    
    //MARK: API params
    /*
     ts = timestamp
     apikey : public key
     hash : a md5 digest of the ts parameter, your private key and your public key (e.g. md5(ts+privateKey+publicKey)
     */
    
    func getAPIParams() -> (ts: String, hash: String, apiKey: String){
        ts = (Date().timeIntervalSince1970).asString
        return (ts,(ts+self.privateKey+self.publicKey).md5, self.publicKey)
    }
    
    func getQueryString() -> String {
        ts = (Date().timeIntervalSince1970).asString
        hash = (ts+self.privateKey+self.publicKey).md5
        print("ts="+ts+"&hash="+hash+"&apikey="+self.publicKey)
        return "ts="+ts+"&hash="+hash+"&apikey="+self.publicKey
    }
    
    func getQueryString(limit: Int, offset: Int) -> String {
        ts = (Date().timeIntervalSince1970).asString
        hash = (ts+self.privateKey+self.publicKey).md5
        return "ts="+ts+"&hash="+hash+"&apikey="+self.publicKey+"&limit="+String(limit)+"&offset="+String(offset)
    }
}

