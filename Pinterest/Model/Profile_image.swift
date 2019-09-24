//
//  Profile_image.swift
//  Networking
//
//  Created by arafat on 9/21/19.
//  Copyright © 2019 Pinterest. All rights reserved.
//

import Foundation
public struct Profile_image : Codable {
	public let small : String?
	public let medium : String?
	public let large : String?

	public enum CodingKeys: String, CodingKey {

		case small = "small"
		case medium = "medium"
		case large = "large"
	}

	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		small = try values.decodeIfPresent(String.self, forKey: .small)
		medium = try values.decodeIfPresent(String.self, forKey: .medium)
		large = try values.decodeIfPresent(String.self, forKey: .large)
	}

}
