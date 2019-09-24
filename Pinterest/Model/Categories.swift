//
//  Categories.swift
//  Networking
//
//  Created by arafat on 9/21/19.
//  Copyright © 2019 Pinterest. All rights reserved.
//

import Foundation
public struct Categories : Codable {
	public let id : Int?
	public let title : String?
	public let photoCount : Int?
	public let links : Links?

	public enum CodingKeys: String, CodingKey {

		case id = "id"
		case title = "title"
		case photoCount = "photo_count"
		case links = "links"
	}

	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		title = try values.decodeIfPresent(String.self, forKey: .title)
		photoCount = try values.decodeIfPresent(Int.self, forKey: .photoCount)
		links = try values.decodeIfPresent(Links.self, forKey: .links)
	}
}
