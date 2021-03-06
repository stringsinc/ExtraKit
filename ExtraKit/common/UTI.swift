//
//  UTI.swift
//  ExtraKit
//
//  Created by rickb on 4/18/16.
//  Copyright © 2018 rickbdotcom LLC. All rights reserved.
//

import Foundation
#if os(OSX)
import CoreServices
#elseif os(iOS)
import MobileCoreServices
#endif

public extension String {

	func tag(withClass: CFString) -> String? {
		return UTTypeCopyPreferredTagWithClass(self as CFString, withClass)?.takeRetainedValue() as String?
	}
	
	func uti(withClass: CFString) -> String? {
		return UTTypeCreatePreferredIdentifierForTag(withClass, self as CFString, nil)?.takeRetainedValue() as String?
	}
	
	var utiMimeType: String? {
		return tag(withClass: kUTTagClassMIMEType)
	}
	
	var utiFileExtension: String? {
		return tag(withClass: kUTTagClassFilenameExtension)
	}
	
	var mimeTypeUTI: String? {
		return uti(withClass: kUTTagClassMIMEType)
	}

	var fileExtensionUTI: String? {
		return uti(withClass: kUTTagClassFilenameExtension)
	}

	func utiConforms(to: String) -> Bool {
		return UTTypeConformsTo(self as CFString, to as CFString)
	}
}
