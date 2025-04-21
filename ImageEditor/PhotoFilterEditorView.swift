//
//  PhotoFilterEditorView.swift
//  ImageEditor
//
//  Created by Sneha on 16/04/25.
//

import SwiftUI
import PhotosUI
import CoreImage.CIFilterBuiltins

struct PhotoFilterEditorView: View {
    @StateObject private var viewModel = PhotoEditorViewModel()
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var brightness: Float = 0.0
    @State private var contrast: Float = 1.0
    
    var body: some View {
        VStack {
            if let editedImage = viewModel.editedImage {
                Image(uiImage: editedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .padding()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 300)
                    .overlay(Text("No photo selected"))
            }
            
            PhotosPicker("Select a Photo", selection: $selectedItem, matching: .images)
                .padding()
            
            if let _ = viewModel.editedImage {
                HStack {
                    Text("Brightness")
                    Slider(value: $brightness, in: -1...1)
                        .onChange(of: brightness) { _, newValue in
                            viewModel.updateBrightness(newValue)
                        }
                }
                .padding()
                
                HStack {
                    Text("Contrast   ")
                    Slider(value: $contrast, in: 0...4)
                        .onChange(of: contrast) { _, newValue in
                            viewModel.updateContrast(newValue)
                        }
                }
                .padding()
                
                Picker("Filter", selection: $viewModel.selectedFilter) {
                    ForEach(FilterType.allCases) { filter in
                        Text(filter.displayName).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: viewModel.selectedFilter) { _, newValue in
                    viewModel.selectFilter(newValue)
                }
                
                Button("Save to Photos") {
                    viewModel.saveImagetoPhotos()
                }

            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let item = newItem, let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    viewModel.originalImage = uiImage
                    viewModel.editedImage = nil
                    brightness = 0
                    contrast = 1.0
                    viewModel.resetImage()
                }
            }
        }
        .onAppear() {
            viewModel.setOriginalImage(UIImage())
        }
        
    }
}

#Preview {
    PhotoFilterEditorView()
}
