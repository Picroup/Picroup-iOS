//
//  DefaultCacheService.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/21.
//  Copyright © 2018年 luojie. All rights reserved.
//

import struct Foundation.URL
import class Foundation.FileManager
import struct Foundation.FileAttributeKey
import struct Foundation.Date
import struct Foundation.Data
import class Foundation.DispatchQueue

final class DefaultCacheService: CacheService {
    
    static let shared = try? DefaultCacheService()
    
    private struct Constant {
        static let cacheDirectoryName = "DefaultCache"
    }
    
    fileprivate let fileManager: FileManager
    fileprivate let path: String
    
    init() throws {
        fileManager = FileManager.default
        path = try type(of: self).createPath(fileManager: fileManager)
        try createDirectory()
    }
    
    func set(_ data: Data, for remoteURL: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            let filePath = self.createFilePath(for: remoteURL)
            guard !self.fileManager.fileExists(atPath: filePath) else {
                return print("cache file exist for: \(remoteURL)")
            }
            self.fileManager.createFile(atPath: filePath, contents: data, attributes: [.modificationDate: Date()])
        }
    }
    
    func fileURL(for remoteURL: URL) -> URL? {
        let filePath = createFilePath(for: remoteURL)
        if fileManager.fileExists(atPath: filePath) {
            try? fileManager.setAttributes([.modificationDate: Date()], ofItemAtPath: filePath)
            print("filePath", filePath)
            print("fileURL", URL(fileURLWithPath: filePath))
            return URL(fileURLWithPath: filePath)
        }
        return nil
    }
}

extension DefaultCacheService {
    
    fileprivate func createFilePath(for remoteURL: URL) -> String {
        return "\(path)/\(createFileName(for: remoteURL))"
    }
    
    fileprivate func createFileName(for remoteURL: URL) -> String {
        var fileName = MD5(remoteURL.absoluteString)
        if !remoteURL.pathExtension.isEmpty {
            fileName.append(".\(remoteURL.pathExtension)")
        }
        return fileName
    }
    
    fileprivate static func createPath(fileManager: FileManager) throws -> String {
        let url = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return url.appendingPathComponent(Constant.cacheDirectoryName, isDirectory: true).path
    }
    
    fileprivate func createDirectory() throws {
        if fileManager.fileExists(atPath: path) { return }
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    }
}
