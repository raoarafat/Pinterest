//
//  DownloadService.swift
//  Networking
//
//  Created by arafat on 9/21/19.
//  Copyright © 2019 Pinterest. All rights reserved.
//

import Foundation
import MobileCoreServices

public enum DownloadType {
    case image, other
}

public class Download {
    var isDownloading = false
    var progress: Float = 0
    var resumeData: Data?
    var task: URLSessionDownloadTask?
    var downloadUrl: URL
    var type: DownloadType

    public init(downloadUrl: URL, type: DownloadType) {
        self.downloadUrl = downloadUrl
        self.type = type
    }
}

public typealias Progress = ((Float) -> Void)
public typealias Completion = ((URL?, Data?) -> Void)

final public class DownloadService: NSObject {

    private let documentsPath = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first!
    private var activeDownloads: [URL: (progress: Progress?, completion: Completion, file: Download)] = [ : ]
    private var onBackground: Bool = true
    private lazy var downloadsSession: URLSession = {
        URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: self,
            delegateQueue: nil
        )
    }()

    private func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }

    public func cancel(_ url: String) {
        guard let downloadUrl = URL(string: url),
            let download = activeDownloads[downloadUrl]?.file else {
                return
        }
        download.task?.cancel()
        activeDownloads[downloadUrl] = nil
    }

    public func pause(_ url: String) {
        guard let downloadUrl = URL(string: url),
            let download = activeDownloads[downloadUrl]?.file,
            download.isDownloading
            else {
                return
        }

        download.task?.cancel(byProducingResumeData: { data in
            download.resumeData = data
        })

        download.isDownloading = false
    }

    public func resume(_ url: String) {
        guard let downloadUrl = URL(string: url),
            let download = activeDownloads[downloadUrl]?.file else {
                return
        }

        if let resumeData = download.resumeData {
            download.task = downloadsSession.downloadTask(withResumeData: resumeData)
        } else {
            download.task = downloadsSession.downloadTask(with: download.downloadUrl)
        }

        download.task?.resume()
        download.isDownloading = true
    }

    public func start(_ urlString: String,
                      type: DownloadType = .other,
                      progress: Progress? = nil,
                      onBackground: Bool = false,
                      completion: @escaping Completion) {
        guard let downloadUrl = URL(string: urlString) else {
            return onMain { completion(nil, nil) }
        }
        let download = Download(downloadUrl: downloadUrl, type:  type)
        let task = downloadsSession.downloadTask(with: downloadUrl)
        download.task = task
        download.task?.resume()
        download.isDownloading = true
        activeDownloads[download.downloadUrl] = (progress, completion, download)
    }
}

extension DownloadService: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {
        guard let sourceURL = downloadTask.originalRequest?.url,
            let download = activeDownloads[sourceURL] else {
                return
        }
        activeDownloads[sourceURL] = nil
        if downloadTask.response?.mimeType?.contains("image") ?? false {
            if download.file.type == .image {
                let data = try? Data(contentsOf: location)
                onMain { download.completion(nil, data) }
            } else {
                onMain { download.completion(nil, nil) }
            }
        } else {
            let destinationURL = localFilePath(for: sourceURL)
            let fileManager = FileManager.default
            try? fileManager.removeItem(at: destinationURL)
            do {
                try fileManager.copyItem(at: location, to: destinationURL)
                onMain { download.completion(destinationURL, nil) }
            } catch let error {
                print("Could not copy file to disk: \(error.localizedDescription)")
                onMain { download.completion(nil, nil) }
            }
        }
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                           didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64) {
        guard
            let url = downloadTask.originalRequest?.url,
            let download = activeDownloads[url] else {
                return
        }
        download.file.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        onMain { download.progress?(download.file.progress) }
    }

    public func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            guard let sourceURL = task.originalRequest?.url,
                let download = activeDownloads[sourceURL] else {
                    return
            }
            activeDownloads[sourceURL] = nil
            onMain { download.completion(nil, nil) }
        }
    }

    public func onMain(_ closure: @escaping (() -> Void)) {
       // guard onBackground else {
         return DispatchQueue.main.async { closure() }
       // }
       //  closure()
    }
}


