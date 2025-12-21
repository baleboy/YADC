//
//  JournalPhotoGridView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 21.12.2025.
//

import SwiftUI
import PhotosUI

struct JournalPhotoGridView: View {
    @Binding var images: [UIImage]
    let isEditable: Bool
    let maxPhotos: Int

    @State private var showingImageSourceSheet = false
    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    init(images: Binding<[UIImage]>, isEditable: Bool = true, maxPhotos: Int = 5) {
        self._images = images
        self.isEditable = isEditable
        self.maxPhotos = maxPhotos
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                photoCell(image: image, index: index)
            }

            if isEditable && images.count < maxPhotos {
                addPhotoButton
            }
        }
        .confirmationDialog("Add Photo", isPresented: $showingImageSourceSheet) {
            Button("Take Photo") {
                showingCamera = true
            }
            Button("Choose from Library") {
                showingPhotoPicker = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView { capturedImage in
                if let image = capturedImage {
                    images.append(image)
                }
            }
        }
        .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, newValue in
            Task {
                if let item = newValue,
                   let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    images.append(image)
                }
                selectedPhotoItem = nil
            }
        }
    }

    private func photoCell(image: UIImage, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 100)
                .clipped()
                .cornerRadius(8)

            if isEditable {
                Button {
                    withAnimation {
                        _ = images.remove(at: index)
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .background(Circle().fill(Color.black.opacity(0.5)))
                }
                .padding(4)
            }
        }
    }

    private var addPhotoButton: some View {
        Button {
            showingImageSourceSheet = true
        } label: {
            VStack {
                Image(systemName: "plus")
                    .font(.title2)
                Text("Add Photo")
                    .font(.caption)
            }
            .foregroundStyle(Color("TextSecondary"))
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(Color("FormRowBackground"))
            .cornerRadius(8)
        }
    }
}

#Preview {
    JournalPhotoGridView(images: .constant([]))
        .padding()
}
