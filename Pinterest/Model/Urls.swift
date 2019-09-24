//
//  Urls.swift
//  Networking
//
//  Created by arafat on 9/21/19.
//  Copyright © 2019 Pinterest. All rights reserved.
//

import Foundation
public struct Urls : Codable {
	public let raw : String?
	public let full : String?
	public let regular : String?
	public let small : String?
	public let thumb : String?

	public enum CodingKeys: String, CodingKey {

		case raw = "raw"
		case full = "full"
		case regular = "regular"
		case small = "small"
		case thumb = "thumb"
	}

	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		raw = try values.decodeIfPresent(String.self, forKey: .raw)
		full = try values.decodeIfPresent(String.self, forKey: .full)
		regular = try values.decodeIfPresent(String.self, forKey: .regular)
		small = try values.decodeIfPresent(String.self, forKey: .small)
		thumb = try values.decodeIfPresent(String.self, forKey: .thumb)
	}

}
