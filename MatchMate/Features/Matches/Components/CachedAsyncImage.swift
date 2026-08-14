//
//  CachedAsyncImage.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 15/08/26.
//
import SwiftUI
import UIKit

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
        
        // First check our shared disk cache.
        if let data = await ImageCache.shared.imageData(
            for: url
        ),
           let image = UIImage(data: data) {
            
            phase = .success(
                Image(uiImage: image)
            )
            
            return
        }
        
        // Nothing cached → download.
        do {
            let (data, _) = try await URLSession.shared.data(
                from: url
            )
            
            guard let image = UIImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }
            
            // Save through the single cache implementation.
            await ImageCache.shared.save(
                data,
                for: url
            )
            
            phase = .success(
                Image(uiImage: image)
            )
            
        } catch {
            phase = .failure(error)
        }
    }
}
