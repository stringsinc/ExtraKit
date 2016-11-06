#!/usr/bin/env xcrun --sdk macosx swift

import Foundation

var outputString = "// autogenerated by genswiftstrings.swift\n\nimport Foundation\n\n"

func generateStringsSourceFile(_ stringsPath: String) {
	let tmpPath = "/var/tmp/strings.plist"
	systemcommand(["/usr/bin/plutil", "-convert", "binary1", stringsPath, "-o", tmpPath])
	guard let stringsDict = NSDictionary(contentsOfFile: tmpPath)
	, stringsDict.count > 0 else {
		return
	}
	
	outputString += "enum Strings: String{\n\n"

	stringsDict.allKeys.forEach {
		outputString += "\tcase \($0)\n"
	}
	outputString += "}\n"
}

func systemcommand(_ args: [String]) {
	let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.launch()
    task.waitUntilExit()
}

func generateFormatStringsSourceFile(_ stringsDictPath: String) {
	guard let stringsDict = NSDictionary(contentsOfFile: stringsDictPath)
	, stringsDict.count > 0 else {
		return
	}
	
	outputString += "\nenum FormatStrings: String{\n\n"

	stringsDict.allKeys.forEach {
		outputString += "\tcase \($0)\n"
	}
	outputString += "}\n"
}

let outputPath = CommandLine.arguments[2]

generateStringsSourceFile(CommandLine.arguments[1])

if CommandLine.arguments.count >= 4 {
	generateFormatStringsSourceFile(CommandLine.arguments[3])
}

try! outputString.write(toFile: outputPath, atomically: true, encoding: String.Encoding.utf8)
