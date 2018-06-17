import OysterKit
import Foundation

// Welcome the player
let game = Game()
let interpreter = Interpreter()
print("Welcome to Bork brave Adventurer!\nType HELP for help.\n\n\(game.player.location)\n\nWhat do you want to do now? > ", terminator: "")

// Loop forever until they enter QUIT
while let userInput = readLine(strippingNewline: true), userInput != "QUIT" {
    // Provide help
    if userInput == "HELP" {
        print("You can type the following commands: \([Verb.INVENTORY, Verb.GO, Verb.PICKUP, Verb.DROP, Verb.ATTACK].list(article: Article.none))")
    } else {
        // Process their input
        do {
            let command = try ParsingDecoder().decode(Command.self, from: userInput , using: Bork.generatedLanguage)
            
            // Execute the command
            interpreter.interpret(command, inGame: game)
        } catch {
            print("\nI didn't understand '\(userInput)', try again. > ", terminator: "")
            continue
        }
    }
    
    // Prompt for next command
    print("\n\(game.player.location)\n\nWhat do you want to do now? > ", terminator: "")
}

// Wish them on their way
print ("Goodbye adventurer... for now.")

