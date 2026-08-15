//
//  ProfileDetailView.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 15/08/26.
//

import SwiftUI

struct ProfileDetailView: View {
    
    let profile: Profile
    
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
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
                            Image(
                                systemName: "person.crop.circle.fill"
                            )
                            .resizable()
                            .scaledToFit()
                            .padding(40)
                            
                        @unknown default:
                            EmptyView()
                    }
                }
                .frame(height: 360)
                .frame(maxWidth: .infinity)
                .clipShape(
                    RoundedRectangle(cornerRadius: 24)
                )
                
                VStack(
                    alignment: .leading,
                    spacing: 16
                ) {
                    
                    Text(
                        "\(profile.firstName) \(profile.lastName)"
                    )
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    
                    detailRow(
                        title: "Gender",
                        value: profile.gender.capitalized
                    )
                    
                    detailRow(
                        title: "Location",
                        value: "\(profile.city), \(profile.country)"
                    )
                    
                    detailRow(
                        title: "Nationality",
                        value: profile.nationality
                    )
                    
                    detailRow(
                        title: "Email",
                        value: profile.email
                    )
                    
                    detailRow(
                        title: "Phone",
                        value: profile.phone
                    )
                    
                    if let dateOfBirth = profile.dateOfBirth {
                        detailRow(
                            title: "Date of Birth",
                            value: dateOfBirth.formatted(
                                date: .abbreviated,
                                time: .omitted
                            )
                        )
                    }
                    
                    if let registeredDate = profile.registeredDate {
                        detailRow(
                            title: "Registered",
                            value: registeredDate.formatted(
                                date: .abbreviated,
                                time: .omitted
                            )
                        )
                    }
                    
                    detailRow(
                        title: "Status",
                        value: profile.matchStatus.rawValue.capitalized
                    )
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                
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
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func detailRow(
        title: String,
        value: String
    ) -> some View {
        
        VStack(
            alignment: .leading,
            spacing: 4
        ) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.body)
        }
    }
}
