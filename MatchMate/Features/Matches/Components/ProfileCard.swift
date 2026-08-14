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
        VStack(spacing: 16) {

            AsyncImage(
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
                        .padding(40)

                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 320)
            .frame(maxWidth: .infinity)
            .clipShape(
                RoundedRectangle(cornerRadius: 20)
            )

            VStack(alignment: .leading, spacing: 8) {

                Text(
                    "\(profile.firstName) \(profile.lastName)"
                )
                .font(.title2)
                .fontWeight(.semibold)

                Text(
                    "\(profile.gender.capitalized) • \(profile.city), \(profile.country)"
                )
                .foregroundStyle(.secondary)

                Text(profile.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )

            HStack(spacing: 16) {

                Button {
                    onDecline()
                } label: {
                    Label("Decline", systemImage: "xmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    onAccept()
                } label: {
                    Label("Accept", systemImage: "heart.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(.background)
        .clipShape(
            RoundedRectangle(cornerRadius: 24)
        )
        .shadow(
            radius: 8,
            y: 4
        )
    }
}
