//
//  CharManager.swift
//  MarvelApp
//
//  Created by Hugo Adrián Meza Vega on 10/05/24.
//

import Foundation
import CoreData

class CharManager {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    //MARK: CRUD Methods
    
    func createChar(charId: UUID, name: String, descriptionChar: String, resourceURI: String, thumbnail: String) -> FavoriteChar? {
        let newFavChar = FavoriteChar(context: context)
        newFavChar.charId = UUID()
        newFavChar.name = name
        newFavChar.descriptionChar = descriptionChar
        newFavChar.resourceURI = resourceURI
        newFavChar.thumbnail = thumbnail
        do{
            try context.save()
            print("Char saved!!")
            return newFavChar
        }catch let error{
            print("Error: ", error)
            return nil
        }
    }
    
    func getCharacter(index: Int) -> FavoriteChar? {
        if let characters = try? self.context.fetch(FavoriteChar.fetchRequest()) {
            return characters[index]
        }else{
            return nil
        }
    }
    
    func getAllCharacters() -> [FavoriteChar] {
        if let charaters = try? self.context.fetch(FavoriteChar.fetchRequest()){
            return charaters
        }else{
            return []
        }
    }
    
    func getCharacterById(uuid: UUID) -> FavoriteChar? {
        let fetchRequest = FavoriteChar.fetchRequest()
        var predicate: NSPredicate?
        
        predicate = NSPredicate(format: "%K == %@", #keyPath(FavoriteChar.charId), uuid as CVarArg)
        
        fetchRequest.predicate = predicate
        
        do{
            let character = try context.fetch(fetchRequest)
            return character.first
        }catch let error{
            print("Error: ", error)
            return nil
        }
    }
    
    func getCharacterByName(name: String) -> FavoriteChar? {
        let fetchRequest = FavoriteChar.fetchRequest()
        var predicate: NSPredicate?
        predicate = NSPredicate(format: "%K == %@", #keyPath(FavoriteChar.name), name as CVarArg)
        fetchRequest.predicate = predicate
        do{
            let character = try context.fetch(fetchRequest)
            return character.first
        }catch let error{
            print("Error: ", error)
            return nil
        }
    }
    
    func deleteCharacter(char: FavoriteChar) -> Bool {
        self.context.delete(char)
        do{
            try context.save()
            return true
        }catch let error{
            print("Error: ", error)
            return false
        }
    }
    
    
}
