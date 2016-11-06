#!/usr/bin/env xcrun --sdk macosx swift

import Foundation

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

let outputPath = CommandLine.arguments[1]

var outputString = ""
outputString.addLine("// autogenerated by genswiftimages.swift\n")
outputString.addLine("import UIKit")
outputString.addLine("")

if CommandLine.arguments.count > 2 {
	outputString.addLine("enum Images: String {")
	outputString.addLine("")

	CommandLine.arguments[2..<CommandLine.arguments.count].forEach {
		let url = NSURL(fileURLWithPath: $0)
		outputString.addLine("case \(url.deletingPathExtension!.lastPathComponent.replacingOccurrences(of: "-", with:"__"))")
	}
	outputString.addLine("")
	outputString.addLine("var image: UIImage? {")
	outputString.addLine("return UIImage(named: rawValue.replacingOccurrences(of: \"__\", with:\"-\"))")
	outputString.addLine("}")
	outputString.addLine("}")
}
try! outputString.write(toFile: outputPath, atomically: true, encoding: String.Encoding.utf8)
