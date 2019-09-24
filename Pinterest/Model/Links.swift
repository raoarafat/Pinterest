//
//  Links.swift
//  Networking
//
//  Created by arafat on 9/21/19.
//  Copyright © 2019 Pinterest. All rights reserved.
//

import Foundation

public struct Links : Codable {
	public let selfData : String?
	public let html : String?
	public let download : String?

	public enum CodingKeys: String, CodingKey {

		case selfData = "self"
		case html = "html"
		case download = "download"
	}

	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		selfData = try values.decodeIfPresent(String.self, forKey: .selfData)
		html = try values.decodeIfPresent(String.self, forKey: .html)
		download = try values.decodeIfPresent(String.self, forKey: .download)
	}

}
