//
//  FavouriteView.swift
//
//  Copyright © 2026 Blue Triangle. All rights reserved.
//

import SwiftUI
import BlueTriangle

struct FavouriteView: View {
    private let favorites = FavoriteItemFactory.defaultFavorites()

    var body: some View {
        List(favorites.indices, id: \.self) { index in
            let item = favorites[index]
            HStack(spacing: 12) {
                // Deliberately expensive synchronous render — most rows
                // hitch (<750ms), every 15th row hangs (>750ms), see
                // StressSimulators.hitchOrHangCellImage — so Favourite
                // exercises both hitch-rate tracking and hang diagnostics.
                Image(uiImage: StressSimulators.hitchOrHangCellImage(index: index))
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                    Text(item.category)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text(item.price, format: .currency(code: "USD"))
                        .font(.subheadline.bold())
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                }
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Favourite")
        .navigationBarTitleDisplayMode(.inline)
        .bttTrackScreen("FavouriteView")
        .bttTrack("\(Self.self)")
    }
}

#Preview {
    NavigationStack {
        FavouriteView()
    }
}
