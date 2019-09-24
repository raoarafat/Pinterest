//
//  Cache.swift
//  Created on 9/22/19
//  Copyright © 2019 Pinterest. All rights reserved.

import Foundation

public final class Cache: NSObject {

    public static let shared = Cache()

    private var storage = NSCache<NSString, CacheResource>()

    private override init() {
        super.init()
        removeAll()
    }

    public func load(_ key: String) -> CacheResource? {
        guard let cacheResource = storage.object(forKey: key  as NSString) else { return nil }

        guard !cacheResource.isExpired else {
            removeBy(key)
            return nil
        }
        return cacheResource
    }

    public func save(_ key: String, path: String? = nil, data: Data, expiryDate: CacheExpiry? = nil) {
        let resource = CacheResource(
            key: key,
            url: path,
            value: data,
            expiryDate: expiryDate
        )
        storage.setObject(resource, forKey: resource.key as NSString)
    }

    public func removeBy(_ key: String) {
        storage.removeObject(forKey: key  as NSString)
    }

    public func removeAll() {
        storage.removeAllObjects()
    }
}

public enum CacheExpiry {
    case never
    case inSeconds(TimeInterval)
    case date(Date)
}

public class CacheResource: Codable {
    public let key: String
    public let remoteURL: String?
    public let value: Data?
    public let expiryDate: Date?

    public init(key: String, url: String? = nil, value: Data? = nil, expiryDate: CacheExpiry? = nil) {
        self.key = key
        remoteURL = url
        self.value = value
        self.expiryDate = expiryDate.doesNotExist ? nil :
            CacheResource.expiryDateForCacheExpiry(expiryDate ?? .never)
    }
}

extension CacheResource {
    static func expiryDateForCacheExpiry(_ expiry: CacheExpiry) -> Date {
        switch expiry {
        case .never:
            return Date.distantFuture
        case let .inSeconds(seconds):
            return Date().addingTimeInterval(seconds)
        case let .date(date):
            return date
        }
    }

    public var isExpired: Bool {
        guard let dateExpiry = expiryDate else { return false }
        return dateExpiry.timeIntervalSinceNow < 0
    }
}

public protocol OptionalString {}
extension String: OptionalString {}

extension Optional {
    public var exists: Bool {
        switch self {
        case .none:
            return false
        case .some:
            return true
        }
    }

    public var doesNotExist: Bool {
        return !exists
    }
}

extension Optional where Wrapped: OptionalString {
    public var isNilOrEmpty: Bool {
        return ((self as? String) ?? "").isEmpty
    }
}
