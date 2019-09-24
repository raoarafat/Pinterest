//
//  Photos.swift
//  Networking
//
//  Created by arafat on 9/21/19.
//  Copyright © 2019 Pinterest. All rights reserved.
//

import Foundation
public struct Photo : Codable {
	public let id : String?
	public let created_at : String?
	public let width : Int?
	public let height : Int?
	public let color : String?
	public let likes : Int?
	public let liked_by_user : Bool?
	public let user : User?
	public let current_user_collections : [String]?
	public let urls : Urls?
	public let categories : [Categories]?
	public let links : Links?

	public enum CodingKeys: String, CodingKey {

		case id = "id"
		case created_at = "created_at"
		case width = "width"
		case height = "height"
		case color = "color"
		case likes = "likes"
		case liked_by_user = "liked_by_user"
		case user = "user"
		case current_user_collections = "current_user_collections"
		case urls = "urls"
		case categories = "categories"
		case links = "links"
	}

	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
		width = try values.decodeIfPresent(Int.self, forKey: .width)
		height = try values.decodeIfPresent(Int.self, forKey: .height)
		color = try values.decodeIfPresent(String.self, forKey: .color)
		likes = try values.decodeIfPresent(Int.self, forKey: .likes)
		liked_by_user = try values.decodeIfPresent(Bool.self, forKey: .liked_by_user)
		user = try values.decodeIfPresent(User.self, forKey: .user)
		current_user_collections = try values.decodeIfPresent([String].self, forKey: .current_user_collections)
		urls = try values.decodeIfPresent(Urls.self, forKey: .urls)
		categories = try values.decodeIfPresent([Categories].self, forKey: .categories)
		links = try values.decodeIfPresent(Links.self, forKey: .links)
	}

}
