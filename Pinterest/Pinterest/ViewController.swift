//
//  ViewController.swift
//  Pinterest
//
//  Created by arafat on 9/21/19.
//  Copyright © 2019 Pinterest. All rights reserved.
//

import UIKit
import Networking

class ViewController: UIViewController {

    @IBOutlet weak var testImage: UIImageView!

    let downloadService = DownloadService()
    override func viewDidLoad() {
        super.viewDidLoad()

        downloadService.start("http://www.pdf995.com/samples/pdf.pdf", progress: { progress in
            print("progress = \(progress)")
        }, completion: { url, _  in
            print(url ?? "")
        })
        downloadService.pause("http://www.pdf995.com/samples/pdf.pdf")

        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            self.downloadService.cancel("http://www.pdf995.com/samples/pdf.pdf")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.downloadService.resume("http://www.pdf995.com/samples/pdf.pdf")
        }

        let str: String = "https://images.unsplash.com/profile-1464495186405-68089dcd96c3?ixlib=rb-0.3.5\u{0026}q=80\u{0026}fm=jpg0026crop=faces\u{0026}fit=crop\u{0026}h=128\u{0026}w=128\u{0026}s=622a88097cf6661f84cd8942d851d9a2"

        downloadService.start(str, progress: { progress in
            print("progress = \(progress)")
        }, completion: { _, data in
            print(data)
        })



        testImage.imageFromUrl(urlString: str)

        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            self.testImage.imageFromUrl(urlString: str)
        }
    }
}
