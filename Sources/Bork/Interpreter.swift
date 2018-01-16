//
//  Interpreter.swift
//  Bork
//
//  Created by SwiftStudies on 16/01/2018.
//

import Foundation

class Interpreter {
    /**
     Interpret the supplied command in the context of a particular game. Any messages will be
     created and printed directly, and if the action can be completed the impact on the game
     will be evaluated.
     */
    public func interpret(_ command:Command, inGame game:Game){
        switch command.verb {
        case .INVENTORY:
            game.player.carrying()
        case .GO:
            guard let subject = command.subject else {
                print("Where do you want to go?")
                return
            }
            game.player.go(subject)
        case .PICKUP:
            guard let subject = command.subject else {
                print("What do you want to pick up?")
                return
            }
            game.player.pickup(subject)
        case .DROP:
            guard let subject = command.subject else {
                print("What do you want to drop?")
                return
            }
            game.player.drop(subject)
        case .ATTACK:
            guard let victim = command.subject else {
                print("What do you want to attack?")
                return
            }
            
            guard let weapon = command.secondSubject else {
                print("What do you want to attack with?")
                return
            }

            game.player.attack(victim, with: weapon)
        }
    }
}

fileprivate extension Player {
    func pickup(_ subject:Subject){
        do {
            let itemIndex = try location.contents.index(of: subject)
            let item = location.contents[itemIndex]
            switch (item.name,item.is(.DEAD)) {
            case (.KITTEN, false):
                print("The kitten dodges you, making you look a fool")
                return
            case (.SNAKE, false):
                print("The snake bites you. Now you feel really stupid, and much deader.")
                exit(0)
            default:
                inventory.append(item)
                location.contents.remove(at: itemIndex)
                return
            }
        } catch {
            guard let descriptionError = error as? DescriptionError else {
                print("Um. \(error.localizedDescription). So that happened.")
                return
            }
            
            print("\(descriptionError.description) to PICKUP")
        }
    }
    
    func drop(_ subject:Subject){
        do {
            let itemIndex = try inventory.index(of: subject)
            let item = inventory.remove(at: itemIndex)
            
            location.contents.append(item)
        } catch {
            guard let descriptionError = error as? DescriptionError else {
                print("Um. \(error.localizedDescription). So that happened.")
                return
            }
            
            print("\(descriptionError.description) to DROP")
        }
    }
    
    func go(_ subject:Subject){
        do {
            let exit = try location.exits[location.exits.index(of: subject)]
            
            print("You go \(subject.noun)")
            location = exit.to
        } catch {
            guard let descriptionError = error as? DescriptionError else {
                print("Um. \(error.localizedDescription). So that happened.")
                return
            }
            
            print("\(descriptionError.description) to GO")
        }
    }
    
    func carrying(){
        print("You are carrying \(game.player.inventory.list(article: Article.a, ifEmpty: " a sense of entitlement, and little else."))")
    }
    
    func attack(_ victimSubject:Subject, with weaponSubject:Subject){
        let victim : Object
        do{
            victim = try location.contents[location.contents.index(of: victimSubject)]
        } catch {
            guard let descriptionError = error as? DescriptionError else {
                print("Um. \(error.localizedDescription). So that happened.")
                return
            }
            
            print("\(descriptionError.description) to ATTACK")
            return
        }
        let weapon : Object
        do{
            weapon = try inventory[inventory.index(of: weaponSubject)]
        } catch {
            guard let descriptionError = error as? DescriptionError else {
                print("Um. \(error.localizedDescription). So that happened.")
                return
            }
            
            print("\(descriptionError.description) to ATTACK with")
            return
        }
        
        switch (victim.name,weapon.name, victim.adjectives.contains(.DEAD)){
        case (Noun.KITTEN, Noun.CLUB, false):
            print("You swing at the kitten with the clumsy wooden club. It skips out the way, and mews defiantly")
        case (Noun.SNAKE, Noun.CLUB, false):
            print("You swing at the snake with the club, it darts out the way hissing.")
            if !victim.adjectives.contains(.ANGRY){
                victim.adjectives.append(.ANGRY)
            }
        case (_,_,true):
            print("You hit the lifeless corpse with the \(weapon.name). It is deader, and you need help I can't give you.")
        case (Noun.KITTEN,Noun.SWORD, false), (Noun.SNAKE, Noun.SWORD, false):
            print("You slice at the \(victim.name) with the blade, killing it")
            if victim.name == Noun.KITTEN {
                print("I hope you are pleased with yourself. No cake for you.")
            }
            if let index = victim.adjectives.index(of: .ANGRY){
                victim.adjectives.remove(at: index)
            }
            victim.adjectives.append(.DEAD)
        default:
            print("You swing the \(weapon.name). The \(victim.name) appears not care.")
        }
    }
}

extension Named {
    /**
     Determines if the supplied `subject` matches the named object. If no adjectives are supplied in the
     `subject`, only the applied noun (name) will be checked. If an adjective is available it must match.
     
     - Parameter subject: The supplied description of a subject (noun/adjective combination)
     - Returns: `true` if `subject` matches the named entity, `false` otherwise
     - SeeAlso: `matchesExactly(subject:Subject)->Bool`
    */
    func matches(subject:Subject)->Bool{
        if name != subject.noun {
            return false
        }
        
        if let describedAs = subject.adjective {
            return adjectives.contains(describedAs)
        }
        
        return true
    }
    
    /**
     Determines if the supplied subject exactly matches (including existance and consistency of adjectives)
     the named object.
     
     - Parameter subject: The supplied description of the a subject
     - Returns: True if the subject, and all parts of the subject, are exactly equivalent to the named object
     - SeeAlso: `matches(subject:Subject)->Bool`
     */
    func matchesExactly(subject:Subject) -> Bool {
        if name != subject.noun {
            return false
        }
        
        if let describedAs = subject.adjective {
            return adjectives.contains(describedAs)
        }
        
        return adjectives.count == 0
    }
    
    func `is`(_ adjective:Adjective)->Bool {
        return adjectives.contains(adjective)
    }
    
    var description : String {
        if adjectives.isEmpty {
            return name.description
        }
        return "\(adjectives.concatenate(separator: ", ")) \(name)"
    }
}

enum DescriptionError : Error, CustomStringConvertible {
    /// A search resulted in no matches where matches were expected
    case notFound(subject:Subject)
    
    /// A search resulted in multiple matches, where a single match was expected
    case ambigious(description:Subject, matches:[Named])
    
    var description: String{
        switch self {
        case .notFound(let subject):
            return "There isn't a \(subject.adjective == nil ? "" : "\(subject.adjective!) ") \(subject.noun)"
        case .ambigious(_,let otherMatches):
            return "Did you mean \(otherMatches.list(article: .the, conjunction: .or))?"
        }
    }
}

extension Array {
    /**
     Creates a string containing the descriptions of each element joined by the supplied separator.
     
     ````
     print(["white","fluffy"].concatenate(", "))
     ````
     
     - Parameter separator: The string to be inserted between entries
     - Returns: The string concatenation of
    */
    func concatenate(separator:String)->String{
        return reduce(""){(result,element) in
            return result.count == 0 ? "\(element)" : "\(result)\(separator)\(element)"
        }
    }

    /**
     Creates a human readable _english_ list of items using the supplied article.
     
     - Parameter article: The required article (e.g. a/an, the) to prefix each noun with
     - Parameter conjunction: The conjunction to use to end the list (e.g. and/or)
     - Parameter ifEmpty: A string to use if there is nothing in the array
     - Parameter oxfordComma: If true an additional comma will be inserted before the list's final conjunction
     - Returns: The fully assembled list.
     */
    func list(article:Article, conjunction:Conjunction = .and,ifEmpty:String = "nothing", oxfordComma : Bool = false)->String{
        if isEmpty {
            return ifEmpty
        }
        var theList = ""
        for (index,element) in enumerated(){
            let elementString = "\(article.form(for: "\(element)"))"
            if index == 0 {
                theList = "\(elementString)"
            } else if index == count-1 {
                theList += "\(oxfordComma && index > 1 ? "," : "") \(conjunction) \(elementString)"
            } else {
                theList += ", \(elementString)"
            }
        }
        
        return theList
    }
}

extension Array where Element : Named {
    
    
    /**
     Returns all elements that match the `subject`
     
     - Parameter matching: The `Subject` that you are trying to find matches for
     - Returns: An array containing all matching elements
     */
    func elements(matching subject:Subject)->[Element]{
        return filter(){$0.matches(subject: subject)}
    }
    
    /**
     Returns the index of the best unambiguous match. An exception will be thrown if there are no matches,
     or if more than one element matches (that is, the subject is ambiguous).
     
     - Parameter ofMatching: The `Subject` being searched for
     - Returns: The index of the unambiguous (no other element matches) element
     */
    func index(of subject:Subject) throws ->Int{
        
        let allMatching = elements(matching: subject)
        
        switch allMatching.count {
        case 0:
            throw DescriptionError.notFound(subject: subject)
        case 1:
            for (index,element) in enumerated() {
                if element.matches(subject: subject) {
                    return index
                }
            }
            print("SERIOUS ERROR: After finding one match, index(of subject:Subject) failed to find that match.")
            throw DescriptionError.notFound(subject: subject)
        default:
            throw DescriptionError.ambigious(description: subject, matches: allMatching)
        }
    }
    

}
