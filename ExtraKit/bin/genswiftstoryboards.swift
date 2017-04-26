#!/usr/bin/env xcrun --sdk macosx swift

import Foundation

let outputPath = CommandLine.arguments[1]
let structName = CommandLine.arguments[2]

var tabs = 0

extension String {
	mutating func addLine(_ line: String = "") {
		
		if line.characters.last == "}" {
			tabs -= 1
		}
		if tabs > 0 {
			self += String(repeating: "\t", count: tabs)
		}

		self += "\(line)\n"

		if line.characters.last == "{" {
			tabs += 1
		}
	}
}

var outputString = ""

outputString.addLine("// autogenerated by genswiftstoryboards.swift")
outputString.addLine("")
outputString.addLine("import UIKit")
outputString.addLine("import ExtraKit")
outputString.addLine("")

func generateStoryboardIdentifierSourceFile(_ path: String) {
	do {
		let url = URL(fileURLWithPath: path)
		let doc = try XMLDocument(contentsOf: url, options: 0)
		
		var vcs = [XMLElement]()
		if let cs = try doc.nodes(forXPath:"//viewController") as? [XMLElement] {
			vcs.append(contentsOf: cs)
		}
		if let cs = try doc.nodes(forXPath:"//tableViewController") as? [XMLElement] {
			vcs.append(contentsOf: cs)
		}
		if let cs = try doc.nodes(forXPath:"//tabBarController") as? [XMLElement] {
			vcs.append(contentsOf: cs)
		}
		if let cs = try doc.nodes(forXPath:"//navigationController") as? [XMLElement] {
			vcs.append(contentsOf: cs)
		}
		guard vcs.count > 0 else {
			return
		}
		
		let ids: [(storyboardIdentifier: String, id: String, segues: [String])]! = vcs.flatMap { vc in
			if let storyboardIdentifier = vc.attribute(forName:"storyboardIdentifier")?.stringValue
			, let id = vc.attribute(forName:"id")?.stringValue {
				var segues = [String]()
				if let segueNodes = try? vc.nodes(forXPath:".//segue") {
					segueNodes.forEach {
						if let elem = ($0 as? XMLElement)
						,  let identifier = elem.attribute(forName:"identifier")?.stringValue
						, !identifier.isEmpty {
							segues.append(identifier)
						}
					}
				}
				return (storyboardIdentifier,id, segues)
			}
			return nil
		}
		guard ids.isEmpty == false else { return }
		
		let fileName = url.deletingPathExtension().lastPathComponent
		
		outputString.addLine("struct \(fileName) {")
		outputString.addLine()
		
		ids.forEach {
			outputString.addLine("struct \($0.storyboardIdentifier): StoryboardScene {")

			if !$0.segues.isEmpty {
				outputString.addLine("enum Segues: String, StoryboardSceneSegue {")
				$0.segues.forEach { segue in
					outputString.addLine("case \(segue)")
				}
				outputString.addLine("}")
			}
			outputString.addLine("let identifier = (\"\($0.storyboardIdentifier)\", \"\(fileName)\")")
			outputString.addLine("}")
		}

		outputString.addLine("}")
		outputString.addLine()
	} catch _ {

	}
}

outputString.addLine("struct \(structName) {")
outputString.addLine("")
CommandLine.arguments[3..<CommandLine.arguments.count].forEach {
	generateStoryboardIdentifierSourceFile($0)
}
outputString.addLine("}")

try! outputString.write(toFile:outputPath, atomically: true, encoding: String.Encoding.utf8)
