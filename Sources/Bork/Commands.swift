//
//  Commands.swift
//  Bork
//
//  Created by SwiftStudies on 15/01/2018.
//

import Foundation

enum Verb : String, Decodable {
    case INVENTORY, GO, PICKUP, DROP, ATTACK
}

enum Noun : String, Decodable, CustomStringConvertible {
    case NORTH, SOUTH, KITTEN, SNAKE, CLUB, SWORD
    
    var description: String {
        return rawValue
    }
}

enum Adjective : String, Decodable, CustomStringConvertible {
    case FLUFFY, ANGRY, DEAD
    
    var description: String{
        return rawValue
    }
}

enum Preposition : String, Decodable {
    case WITH, USING
}

struct Subject : Decodable {
    let noun            : Noun
    let adjective       : Adjective?
}

struct Command : Decodable {
    let verb            : Verb
    let subject         : Subject?
    let preposition     : Preposition?
    let secondSubject   : Subject?

}

enum Conjunction : String, CustomStringConvertible {
    case and, or
    
    var description: String {
        return rawValue
    }
}

enum Article : String {
    case a, the,none = ""
    
    func  form(`for` text:String)->String{
        switch self{
        case .a where text.count > 0:
            if let firstLetter = text.unicodeScalars.first {
                if CharacterSet(charactersIn:"AEIOU").contains(firstLetter) {
                    return "an \(text.trimmingCharacters(in:.whitespaces))"
                }
                return "a \(text.trimmingCharacters(in: .whitespaces))"
            }
            fallthrough
        case .none:
            return text.description
        default:
            return "\(rawValue) \(text)"
        }
    }
}
