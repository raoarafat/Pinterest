//
//  Endpoint.swift
//  Networking
//
//  Created by arafat on 9/21/19.
//  Copyright © 2019 Pinterest. All rights reserved.
//

import Foundation

public enum Endpoint {
    case photos

    var baseUrl: String {
        return HTTPClient.baseUrl
    }

    var path: String {
        switch self {
        case .photos:
            return baseUrl + "/wgkJgazE"
        }
    }
}
