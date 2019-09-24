//
//  PhotoListViewController.swift
//  Pinterest
//
//  Created by arafat on 9/22/19.
//  Copyright © 2019 Pinterest. All rights reserved.
//

import UIKit

class PhotoListViewController: UICollectionViewController {
    let photoModel = PhotoModel()
    private let refreshControl = UIRefreshControl()
    private var spinnerView: SpinnerViewController?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pinterest"
        if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        collectionView?.contentInset = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)

        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControl

        photoModel.showLoading = {
            if self.photoModel.isLoading {
                // self.activityIndicator.startAnimating()
                self.collectionView.alpha = 0.0
            } else {
                // self.activityIndicator.stopAnimating()
                self.collectionView.alpha = 1.0
            }
        }

        photoModel.showError = { error in
            print(error)
        }

        photoModel.reloadData = {
            self.photoModel.fetchingMore = true
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
            self.spinnerView?.willMove(toParent: nil)
            self.spinnerView?.view.removeFromSuperview()
            self.spinnerView?.removeFromParent()
        }
        createSpinnerView()
        photoModel.loadData()
        setupNavigationBar()
    }

    @objc func refreshTapped() {
        photoModel.clearAll()
        refreshControl.endRefreshing()
        createSpinnerView()
    }

    @objc
    private func didPullToRefresh(_ sender: Any) {
        refreshTapped()
    }

    func setupNavigationBar() {
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTapped))
        navigationItem.rightBarButtonItem = refresh

        let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0))
        imageView.imageFromUrl(urlString: "https://cdn4.iconfinder.com/data/icons/security-overcolor/512/agent-512.png")
        imageView.layer.cornerRadius = 20.0
        imageView.layer.masksToBounds = true
        let barButton = UIBarButtonItem(customView: imageView)

        navigationItem.leftBarButtonItem = barButton
    }

    func createSpinnerView() {
        let spinner = SpinnerViewController()
        spinnerView = spinner
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
    }
}

extension PhotoListViewController: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModel.cellViewModels.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath as IndexPath) as! PhotoCell
        cell.photo = photoModel.cellViewModels[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
        return CGSize(width: itemSize, height: itemSize)
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height,
            photoModel.fetchingMore, photoModel.cellViewModels.count > 0,   photoModel.cellViewModels.count < 80 {
            photoModel.loadmoreData()
        }
    }
}

extension PhotoListViewController: PinterestLayoutDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        return photoModel.cellViewModels[indexPath.item].image.size.height
    }
}

