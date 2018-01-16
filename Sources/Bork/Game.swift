//
//  Game.swift
//  Bork
//
//  Created by SwiftStudies on 15/01/2018.
//

import Foundation

protocol Named : CustomStringConvertible{
    var name : Noun              { get }
    var adjectives : [Adjective] { get }
}

class Object : Named {
    let name        : Noun
    var adjectives  : [Adjective]
    
    init(name noun:Noun, adjectives:[Adjective] = []){
        self.name = noun
        self.adjectives = adjectives
    }
}

class Location : CustomStringConvertible{
    let details     : String
    var contents    : [Object]
    var exits       : [Connection]
    
    init(description:String, contents: [Object], exits:[Connection]){
        details = description
        self.contents = contents
        self.exits = exits
    }
    
    var description: String {
        var result = "You are in a \(details). "
        
        if !contents.isEmpty {
            result += "On the ground you see \(contents.list(article: .a)). "
        }
        
        if !exits.isEmpty {
            result += "Exits lead \(exits.list(article: .none)). "
        }
        
        return result
    }
}

class Connection : Named {
    var name : Noun
    var adjectives: [Adjective] = []
    var to   : Location
    
    init(name noun:Noun, to:Location){
        self.name = noun
        self.to = to
    }
 }

class Player {
    var inventory = [Object]()
    var location  : Location
    
    init(at location:Location) {
        self.location = location
    }
}

class Game {
    var locations   = [String : Location]()
    
    let player : Player
    
    init(){
        let southRoom = Location(description: "dark stone walled room, an icy chill exudes from the every dark corner", contents: [
            Object(name: Noun.KITTEN, adjectives: [Adjective.FLUFFY]),
            Object(name: Noun.CLUB)
            ], exits: [])
        
        let northRoom = Location(description: "dark dungeon, the walls drip with moisture absorbed from the surrounding soil", contents: [
            Object(name: Noun.SNAKE),
            Object(name: Noun.SWORD)
            ], exits: [])
        
        locations["southRoom"] = southRoom
        locations["northRoom"] = northRoom
        
        southRoom.exits.append(Connection(name: Noun.NORTH, to: northRoom))
        northRoom.exits.append(Connection(name: Noun.SOUTH, to: southRoom))

        player = Player(at: southRoom)
    }
}
