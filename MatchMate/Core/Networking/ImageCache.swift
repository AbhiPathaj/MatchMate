//
//  ImageCache.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 15/08/26.
//


import Foundation

actor ImageCache {

    static let shared = ImageCache()

    private let fileManager = FileManager.default
    private let directory: URL

    private init() {
        directory = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )[0]
        .appendingPathComponent("ProfileImages", isDirectory: true)

        try? fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
    }

    func imageData(for url: URL) -> Data? {
        let fileURL = cachedFileURL(for: url)

        return try? Data(contentsOf: fileURL)
    }

    func save(
        _ data: Data,
        for url: URL
    ) {
        let fileURL = cachedFileURL(for: url)

        try? data.write(
            to: fileURL,
            options: .atomic
        )
    }

    private func cachedFileURL(for url: URL) -> URL {
        let fileName = url.absoluteString
            .addingPercentEncoding(
                withAllowedCharacters: .alphanumerics
            ) ?? UUID().uuidString

        return directory.appendingPathComponent(fileName)
    }
}