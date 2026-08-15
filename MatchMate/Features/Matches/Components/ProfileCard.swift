//
//  ProfileCard.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//

import SwiftUI

struct ProfileCard: View {
    
    let profile: Profile
    
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    var body: some View {
        VStack(spacing: 18) {
            
            // MARK: - Profile Content
            
            HStack(alignment: .top, spacing: 18) {
                
                CachedAsyncImage(
                    url: profile.largeImageURL
                ) { phase in
                    switch phase {
                        case .empty:
                            ProgressView()
                            
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                            
                        case .failure:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(30)
                            
                        @unknown default:
                            EmptyView()
                    }
                }
                .frame(width: 145, height: 190)
                .clipShape(
                    RoundedRectangle(cornerRadius: 18)
                )
                
                VStack(alignment: .leading, spacing: 9) {
                    
                    Text("\(profile.firstName) \(profile.lastName)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(
                        "\(profile.gender.capitalized) • \(profile.city), \(profile.country)"
                    )
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    
                    Text(profile.email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }
            
            // MARK: - Action / Status
            
            switch profile.matchStatus {
                    
                case .pending:
                    HStack(spacing: 16) {
                        
                        Button {
                            onDecline()
                        } label: {
                            Label(
                                "Decline",
                                systemImage: "xmark"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        Button {
                            onAccept()
                        } label: {
                            Label(
                                "Accept",
                                systemImage: "heart.fill"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                case .accepted:
                    Text("Accepted")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 56
                        )
                        .background(
                            Color.green,
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                    
                case .declined:
                    Text("Declined")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 56
                        )
                        .background(
                            Color.red,
                            in: RoundedRectangle(cornerRadius: 16)
                        )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    Color.primary.opacity(0.08),
                    lineWidth: 1
                )
        )
        .shadow(
            color: .black.opacity(0.12),
            radius: 8,
            y: 4
        )
    }
}
