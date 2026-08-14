//
//  MatchesView.swift
//  MatchMate
//
//  Created by Abhishek Pathak on 14/08/26.
//


import SwiftUI

struct MatchesView: View {

    @State private var viewModel: MatchesViewModel

    init(viewModel: MatchesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Matches")
                .task {
                    await viewModel.fetchProfiles()
                }
        }
    }

    @ViewBuilder
    private var content: some View {

        if viewModel.isLoading && viewModel.profiles.isEmpty {
            ProgressView("Loading matches...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else if let error = viewModel.error,
                  viewModel.profiles.isEmpty {

            ContentUnavailableView(
                "Unable to Load Matches",
                systemImage: "wifi.exclamationmark",
                description: Text(error.localizedDescription)
            )

        } else if viewModel.profiles.isEmpty {

            ContentUnavailableView(
                "No Matches",
                systemImage: "person.2",
                description: Text("No profiles are available right now.")
            )

        } else {

            ScrollView {
                LazyVStack(spacing: 20) {

                    ForEach(viewModel.profiles) { profile in

                        NavigationLink {
                            ProfileDetailView(
                                profile: profile,
                                onAccept: {
                                    Task {
                                        await viewModel.accept(
                                            profileID: profile.id
                                        )
                                    }
                                },
                                onDecline: {
                                    Task {
                                        await viewModel.decline(
                                            profileID: profile.id
                                        )
                                    }
                                }
                            )
                        } label: {
                            ProfileCard(
                                profile: profile,
                                onAccept: {
                                    Task {
                                        await viewModel.accept(
                                            profileID: profile.id
                                        )
                                    }
                                },
                                onDecline: {
                                    Task {
                                        await viewModel.decline(
                                            profileID: profile.id
                                        )
                                    }
                                }
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .padding()
            }
        }
    }
}
