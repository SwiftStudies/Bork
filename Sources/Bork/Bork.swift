// 
// STLR Generated Swift File
// 
// Generated: 2018-06-20 01:20:46 +0000
// 
#if os(macOS)
import Cocoa
#elseif os(iOS)
import UIKit
#else
import Foundation
#endif
import OysterKit

// 
// Bork Parser
// 
enum Bork : Int, Token {

	// Convenience alias
	private typealias T = Bork

	case _transient = -1, `verb`, `noun`, `adjective`, `preposition`, `subject`, `secondSubject`, `command`

	func _rule(_ annotations: RuleAnnotations = [ : ])->Rule {
		switch self {
		case ._transient:
			return CharacterSet(charactersIn: "").terminal(token: T._transient)
		// verb
		case .verb:
			return ScannerRule.oneOf(token: T.verb, ["INVENTORY", "GO", "PICKUP", "DROP", "ATTACK"],[RuleAnnotation.custom(label: "pin") : RuleAnnotationValue.set].merge(with: annotations))
		// noun
		case .noun:
			return ScannerRule.oneOf(token: T.noun, ["NORTH", "SOUTH", "KITTEN", "SNAKE", "CLUB", "SWORD"],[RuleAnnotation.custom(label: "pin") : RuleAnnotationValue.set].merge(with: annotations))
		// adjective
		case .adjective:
			return ScannerRule.oneOf(token: T.adjective, ["FLUFFY", "ANGRY", "DEAD"],[RuleAnnotation.custom(label: "pin") : RuleAnnotationValue.set].merge(with: annotations))
		// preposition
		case .preposition:
			return ScannerRule.oneOf(token: T.preposition, ["WITH", "USING"],[RuleAnnotation.custom(label: "pin") : RuleAnnotationValue.set].merge(with: annotations))
		// subject
		case .subject:
			return [
					[
									T.adjective._rule([RuleAnnotation.custom(label: "pin") : RuleAnnotationValue.set]),
									CharacterSet.whitespaces.terminal(token: T._transient),
									].sequence(token: T._transient).optional(producing: T._transient),
					T.noun._rule([RuleAnnotation.custom(label: "pin") : RuleAnnotationValue.set]),
					].sequence(token: T.subject, annotations: annotations.isEmpty ? [ : ] : annotations)
		// secondSubject
		case .secondSubject:
			return [
					[
									T.adjective._rule([RuleAnnotation.custom(label: "pin") : RuleAnnotationValue.set]),
									CharacterSet.whitespaces.terminal(token: T._transient),
									].sequence(token: T._transient).optional(producing: T._transient),
					T.noun._rule([RuleAnnotation.custom(label: "pin") : RuleAnnotationValue.set]),
					].sequence(token: T.secondSubject, annotations: annotations.isEmpty ? [ : ] : annotations)
		// command
		case .command:
			return [
					T.verb._rule([RuleAnnotation.custom(label: "pin") : RuleAnnotationValue.set]),
					[
									CharacterSet.whitespaces.terminal(token: T._transient),
									T.subject._rule(),
									[
													CharacterSet.whitespaces.terminal(token: T._transient),
													T.preposition._rule([RuleAnnotation.custom(label: "pin") : RuleAnnotationValue.set]),
													CharacterSet.whitespaces.terminal(token: T._transient),
													T.secondSubject._rule(),
													].sequence(token: T._transient).optional(producing: T._transient),
									].sequence(token: T._transient).optional(producing: T._transient),
					].sequence(token: T.command, annotations: annotations.isEmpty ? [ : ] : annotations)
		}
	}


	// Create a language that can be used for parsing etc
	public static var generatedLanguage : Parser {
		return Parser(grammar: [T.command._rule()])
	}

	// Convient way to apply your grammar to a string
	public static func parse(source: String) throws -> HomogenousTree {
		return try AbstractSyntaxTreeConstructor().build(source, using: generatedLanguage)
	}
}
