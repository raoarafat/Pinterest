//
//  User.swift
//  Networking
//
//  Created by arafat on 9/21/19.
//  Copyright © 2019 Pinterest. All rights reserved.
//

import Foundation
public struct User : Codable {
	public let id : String?
	public let username : String?
	public let name : String?
	public let profile_image : Profile_image?
	public let links : Links?

	public enum CodingKeys: String, CodingKey {

		case id = "id"
		case username = "username"
		case name = "name"
		case profile_image = "profile_image"
		case links = "links"
	}

	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		username = try values.decodeIfPresent(String.self, forKey: .username)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		profile_image = try values.decodeIfPresent(Profile_image.self, forKey: .profile_image)
		links = try values.decodeIfPresent(Links.self, forKey: .links)
	}

}
