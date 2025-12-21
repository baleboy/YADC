//
//  StarRatingView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 21.12.2025.
//

import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Int
    let isEditable: Bool

    init(rating: Binding<Int>, isEditable: Bool = true) {
        self._rating = rating
        self.isEditable = isEditable
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .foregroundStyle(star <= rating ? Color("AccentColor") : Color("TextTertiary"))
                    .onTapGesture {
                        if isEditable {
                            rating = star
                        }
                    }
            }
        }
    }
}

struct StarRatingDisplayView: View {
    let rating: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundStyle(star <= rating ? Color("AccentColor") : Color("TextTertiary"))
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        StarRatingView(rating: .constant(3))
        StarRatingView(rating: .constant(5), isEditable: false)
        StarRatingDisplayView(rating: 4)
    }
    .padding()
}
