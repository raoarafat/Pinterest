//
//  Custom.swift
//  Pinterest
//
//  Created by arafat on 9/22/19.
//  Copyright © 2019 Pinterest. All rights reserved.
//
import UIKit
import Networking

extension UIImageView {
    public func imageFromUrl(urlString: String) {
        if let resource = Cache.shared.load(urlString),
            let data = resource.value {
            return self.image = UIImage(data: data)
        } else {
            // if type is image and return type is also image it will return data type in closure
            // else return path which is store in document because might have large file size
            DownloadService().start(urlString, type: .image, completion: { _, data in
                if let data = data {
                    Cache.shared.save(
                        urlString,
                        data: data,
                        expiryDate: .never)
                    self.image = UIImage(data: data)
                } else {
                    self.backgroundColor = .random
                }
            })
        }
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }

    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
          return UIGraphicsImageRenderer(size: size).image { rendererContext in
              self.setFill()
              rendererContext.fill(CGRect(origin: .zero, size: size))
          }
      }
}
