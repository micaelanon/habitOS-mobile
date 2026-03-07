import SwiftUI
import PhotosUI

/// Form to log a tracked meal, including photos and adherence context
struct MealLogView: View {
    let mealName: String
    let mealItems: [String]
    
    @State private var viewModel = MealLogViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Header info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Estaba planeado:")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.hbMuted)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(mealItems, id: \.self) { item in
                                HStack(spacing: 8) {
                                    Circle().fill(Color.hbSage).frame(width: 4, height: 4)
                                    Text(item).font(.system(size: 15)).foregroundStyle(Color.hbInk)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.hbPaper, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.hbLine, lineWidth: 1))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Adherence toggle
                    HBCard {
                        Toggle("¿Has seguido el plan?", isOn: $viewModel.followedPlan)
                            .tint(Color.hbSage)
                            .font(.system(size: 15, weight: .medium))
                    }
                    .padding(.horizontal, 20)
                    
                    // Deviations (if didn't follow plan)
                    if !viewModel.followedPlan {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("¿Qué comiste en su lugar?")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.hbMuted)
                            
                            TextField("Escribe aquí...", text: $viewModel.actualDescription)
                                .font(.system(size: 15))
                                .padding(14)
                                .background(Color.hbPaper)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.hbLine, lineWidth: 1))
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("¿Por qué no lo seguiste?")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.hbMuted)
                            
                            TextField("Ej: Salí a cenar, no tenía ingredientes...", text: $viewModel.deviationReason)
                                .font(.system(size: 15))
                                .padding(14)
                                .background(Color.hbPaper)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.hbLine, lineWidth: 1))
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Photo Upload
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sube una foto (opcional)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.hbMuted)
                        
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                            if let data = viewModel.photoData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.hbLine, lineWidth: 1))
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "camera")
                                        .font(.system(size: 32))
                                        .foregroundStyle(Color.hbSage)
                                    Text("Añadir foto")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(Color.hbSage)
                                }
                                .frame(height: 120)
                                .frame(maxWidth: .infinity)
                                .background(Color.hbSageBg, in: RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.hbSage.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [6]))
                                )
                            }
                        }
                        .buttonStyle(.plain)
                        .onChange(of: selectedPhotoItem) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    viewModel.photoData = data
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Save button
                    VStack {
                        if viewModel.isSaving {
                            ProgressView().tint(Color.hbSage)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.hbPaper, in: RoundedRectangle(cornerRadius: 10))
                        } else {
                            Button {
                                Task { await viewModel.saveLog(mealType: mealName, planItems: mealItems) }
                            } label: {
                                Text("Guardar Registro")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.hbSage, in: RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color.hbVanilla.ignoresSafeArea())
            .navigationTitle("Registrar \(mealName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color.hbMuted)
                }
            }
            .sensoryFeedback(.success, trigger: viewModel.isSaved)
            .onChange(of: viewModel.isSaved) { _, saved in
                if saved {
                    dismiss()
                }
            }
        }
    }
}
