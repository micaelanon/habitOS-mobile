import SwiftUI
import PhotosUI

/// Grid of user progress photos with add/delete/compare functionality
struct ProgressPhotosView: View {
    @State private var viewModel = ProgressPhotosViewModel()
    @State private var showSourcePicker = false
    @State private var showCamera = false
    @State private var showLibrary = false
    @State private var selectedPickerItem: PhotosPickerItem?
    @State private var selectedPhoto: ProgressPhoto?
    @State private var compareMode = false
    @State private var compareA: ProgressPhoto?
    @State private var compareB: ProgressPhoto?

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {

                // Header card
                HBCard {
                    HStack(spacing: 14) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 26))
                            .foregroundStyle(Color.hbSage)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Fotos de progreso")
                                .font(.hbSerifBold(18))
                                .foregroundStyle(Color.hbInk)
                            Text("Guarda fotos periódicas para visualizar tu transformación.")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.hbMuted)
                        }
                    }
                }

                // Action row
                HStack(spacing: 12) {
                    Button {
                        showSourcePicker = true
                    } label: {
                        Label("Añadir foto", systemImage: "plus.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.hbSage, in: RoundedRectangle(cornerRadius: 12))
                    }

                    if viewModel.photos.count >= 2 {
                        Button {
                            compareMode.toggle()
                            if !compareMode { compareA = nil; compareB = nil }
                        } label: {
                            Label("Comparar", systemImage: "rectangle.split.2x1")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(compareMode ? Color.hbSage : Color.hbInk)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.hbPaper, in: RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(
                                    compareMode ? Color.hbSage : Color.hbLine, lineWidth: 1))
                        }
                    }
                }

                if compareMode { compareHint }

                // Photo grid
                if viewModel.isLoading {
                    ProgressView().frame(maxWidth: .infinity).padding(.top, 40)
                } else if viewModel.photos.isEmpty {
                    emptyState
                } else {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.photos) { photo in
                            photoCell(photo)
                        }
                    }
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, HBTokens.padScreen)
            .padding(.top, 8)
        }
        .background(Color.hbVanilla)
        .navigationTitle("Progreso")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.hbVanilla.opacity(0.95), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear { viewModel.loadPhotos() }
        .confirmationDialog("Añadir foto", isPresented: $showSourcePicker) {
            Button("Cámara") { showCamera = true }
            Button("Biblioteca") { showLibrary = true }
            Button("Cancelar", role: .cancel) {}
        }
        .photosPicker(isPresented: $showLibrary, selection: $selectedPickerItem, matching: .images)
        .onChange(of: selectedPickerItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.savePhoto(image)
                }
                selectedPickerItem = nil
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPickerView { image in
                viewModel.savePhoto(image)
                showCamera = false
            }
        }
        .fullScreenCover(item: $selectedPhoto) { photo in
            photoDetailView(photo)
        }
        .sheet(isPresented: .init(
            get: { compareA != nil && compareB != nil },
            set: { if !$0 { compareA = nil; compareB = nil; compareMode = false } }
        )) {
            if let a = compareA, let b = compareB {
                PhotoCompareView(photoA: a, photoB: b)
            }
        }
    }

    // MARK: – Subviews

    private func photoCell(_ photo: ProgressPhoto) -> some View {
        Button {
            if compareMode {
                if compareA == nil { compareA = photo }
                else if compareB == nil && photo.id != compareA?.id { compareB = photo }
            } else {
                selectedPhoto = photo
            }
        } label: {
            ZStack(alignment: .bottomLeading) {
                if let img = photo.image {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(3/4, contentMode: .fill)
                        .clipped()
                        .cornerRadius(14)
                } else {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.hbPaper)
                }

                // Date badge
                Text(photo.date, format: .dateTime.day().month().year())
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.black.opacity(0.4))
                    .cornerRadius(8)
                    .padding(8)

                // Compare selection indicator
                if compareMode {
                    let isA = compareA?.id == photo.id
                    let isB = compareB?.id == photo.id
                    if isA || isB {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.hbSage, lineWidth: 3)
                        VStack {
                            HStack {
                                Spacer()
                                Text(isA ? "A" : "B")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 28, height: 28)
                                    .background(Color.hbSage)
                                    .clipShape(Circle())
                                    .padding(8)
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func photoDetailView(_ photo: ProgressPhoto) -> some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                if let img = photo.image {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { selectedPhoto = nil }
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        viewModel.delete(photo)
                        selectedPhoto = nil
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }

    private var compareHint: some View {
        HStack(spacing: 8) {
            Image(systemName: "hand.tap")
                .foregroundStyle(Color.hbSage)
            Text("Toca la primera foto (A) y luego la segunda (B) para comparar.")
                .font(.system(size: 12))
                .foregroundStyle(Color.hbMuted)
        }
        .padding(12)
        .background(Color.hbSageBg, in: RoundedRectangle(cornerRadius: 10))
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(Color.hbSage.opacity(0.4))
            Text("Sin fotos aún")
                .font(.hbSerifBold(20))
                .foregroundStyle(Color.hbInk)
            Text("Añade tu primera foto de progreso pulsando el botón de arriba.")
                .font(.system(size: 13))
                .foregroundStyle(Color.hbMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 48)
    }
}

/// Side-by-side photo comparison with drag divider
struct PhotoCompareView: View {
    let photoA: ProgressPhoto
    let photoB: ProgressPhoto
    @State private var dividerPosition: CGFloat = 0.5
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    // Photo B (right side, full width)
                    if let imgB = photoB.image {
                        Image(uiImage: imgB)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    }

                    // Photo A clipped to left portion
                    if let imgA = photoA.image {
                        Image(uiImage: imgA)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                            .mask(
                                Rectangle()
                                    .frame(width: geo.size.width * dividerPosition)
                                    .offset(x: -(geo.size.width * (1 - dividerPosition)) / 2)
                            )
                    }

                    // Divider handle
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(.white.opacity(0.6))
                            .frame(width: 2)
                            .offset(x: geo.size.width * dividerPosition - geo.size.width / 2)
                        Spacer()
                    }

                    // Labels
                    HStack {
                        Text("A · \(photoA.date, format: .dateTime.day().month())")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(.black.opacity(0.4))
                            .cornerRadius(6)
                            .padding(12)
                        Spacer()
                        Text("B · \(photoB.date, format: .dateTime.day().month())")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(.black.opacity(0.4))
                            .cornerRadius(6)
                            .padding(12)
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let pos = value.location.x / geo.size.width
                            dividerPosition = min(max(pos, 0.05), 0.95)
                        }
                )
            }
            .ignoresSafeArea()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

/// Wraps UIImagePickerController for camera access
struct CameraPickerView: UIViewControllerRepresentable {
    var onCapture: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onCapture: onCapture) }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onCapture: (UIImage) -> Void
        init(onCapture: @escaping (UIImage) -> Void) { self.onCapture = onCapture }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onCapture(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
