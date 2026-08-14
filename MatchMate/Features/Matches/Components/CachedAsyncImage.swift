//
//  CachedAsyncImage.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 15/08/26.
//

import SwiftUI
import UIKit
import SwiftUI

struct CachedAsyncImage<Content: View>: View {
    
    private let url: URL?
    private let content: (AsyncImagePhase) -> Content
    
    @State private var phase: AsyncImagePhase = .empty
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.content = content
    }
    
    var body: some View {
        content(phase)
            .task(id: url) {
                await loadImage()
            }
    }
    
    private func loadImage() async {
        
        guard let url else {
            phase = .failure(
                URLError(.badURL)
            )
            return
        }
        
        let cacheKey = url.absoluteString
            .data(using: .utf8)!
            .base64EncodedString()
        
        let fileURL = FileManager.default
            .urls(
                for: .cachesDirectory,
                in: .userDomainMask
            )[0]
            .appendingPathComponent(cacheKey)
        
        // 1. Try disk cache first
        if let data = try? Data(contentsOf: fileURL),
           let uiImage = UIImage(data: data) {
            
            phase = .success(
                Image(uiImage: uiImage)
            )
            
            return
        }
        
        // 2. No cache → download
        do {
            let (data, _) = try await URLSession.shared.data(
                from: url
            )
            
            guard let uiImage = UIImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }
            
            // 3. Save image for offline usage
            try? data.write(to: fileURL)
            
            phase = .success(
                Image(uiImage: uiImage)
            )
            
        } catch {
            phase = .failure(error)
        }
    }
}
