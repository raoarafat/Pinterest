//
//  PhotoModel.swift
//  Pinterest
//
//  Created by arafat on 9/22/19.
//  Copyright © 2019 Pinterest. All rights reserved.
//

import UIKit
import Model
import Networking

struct CellViewModel {
    let image: UIImage
    let userName: String
    let likes: Int
}

class PhotoModel: NSObject {
    var photos = [Photo]()
    var cellViewModels: [CellViewModel] = []
    var fetchingMore = false

    var isLoading: Bool = false {
        didSet {
            showLoading?()
        }
    }
    var showLoading: (() -> Void)?
    var reloadData: (() -> Void)?
    var showError: ((Error) -> Void)?

    func loadmoreData() {
        fetchingMore = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.cellViewModels +=  self.cellViewModels
            self.reloadData?()
        }
    }
    func clearAll() {
        cellViewModels.removeAll()
        Cache.shared.removeAll()
        self.isLoading = false
        self.reloadData?()
        loadData()
    }
    func loadData() {
        HTTPClient.request(for: [Photo].self, url: .photos, method: .get) { [weak self] result in
            switch result {
            case let .success(photos):
                self?.photos = photos
                self?.prefetchPhoto()
            case let .failure(error):
                print("Error: \(error)")
            }
        }
    }

    func prefetchPhoto() {
        let downloadGroup = DispatchGroup()
        self.photos.forEach {
            let url = $0.urls?.small ?? ""
            let name = $0.user?.name ?? ""
            let likes = $0.likes ?? 0
            downloadGroup.enter()
            if let resource = Cache.shared.load(url),
                let data = resource.value,
                let image =  UIImage(data: data) {
                addCellModelData(image,
                                 name: name,
                                 likes: likes)
                downloadGroup.leave()
            } else {
                DownloadService().start(
                    url, type: .image,
                    onBackground: false,
                    completion: { [weak self]  _, data in
                        guard let data = data,
                            let image =  UIImage(data: data)  else {
                                let colorImage = UIColor.random.image(
                                    CGSize(width: 100, height: 200)
                                )
                                self?.addCellModelData(colorImage,
                                                       url: url,
                                                       data: colorImage.pngData(),
                                                       name: name,
                                                       likes: likes)

                                downloadGroup.leave()
                                return

                        }
                        self?.addCellModelData(image,
                                               url: url,
                                               data: data,
                                               name: name,
                                               likes: likes)
                        downloadGroup.leave()
                })
            }
        }

        downloadGroup.notify(queue: .main) {
            self.isLoading = false
            self.reloadData?()
        }
    }

    func addCellModelData(_ image: UIImage,
                          url: String? = nil,
                          data: Data? = nil,
                          name: String, likes: Int) {
        if let urlStr = url,
            let imageData = data {
            Cache.shared.save(urlStr,
                              data: imageData,
                              expiryDate: .never
            )
        }
        self.cellViewModels.append(
            CellViewModel(
                image: image,
                userName: name,
                likes: likes
            )
        )
    }
}
