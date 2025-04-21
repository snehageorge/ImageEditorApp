//
//  PhotoEditorViewModel.swift
//  ImageEditor
//
//  Created by Sneha on 21/04/25.
//

import SwiftUI
import Photos
import CoreImage.CIFilterBuiltins

class PhotoEditorViewModel: ObservableObject {
    
    @Published var originalImage: UIImage?
    @Published var editedImage: UIImage?
    @Published var selectedFilter: FilterType = .none
        
    var brightnessValue: Float = 0.0 // Range: -1.0 to 1.0
    var contrastValue: Float = 1.0  // Range: 0 to 4.0
    
    func setOriginalImage(_ image: UIImage) {
        self.originalImage = image
        resetImage()
    }
    
    func selectFilter(_ type: FilterType) {
        selectedFilter = type
        applyFilter()
    }
    
    func updateBrightness(_ value: Float) {
        brightnessValue = value
        applyFilter()
    }
    
    func updateContrast(_ value: Float) {
        contrastValue = value
        applyFilter()
    }
    
    func resetImage() {
        selectedFilter = .none
        brightnessValue = 0.0
        contrastValue = 1.0
        applyFilter()
    }
    
    func applyFilter() {
        guard let originalImage = originalImage,
              let inputCIImage = CIImage(image: originalImage) else {
            return
        }
        
        let filteredCIImage: CIImage? = {
            switch selectedFilter {
            case .none:
                return inputCIImage
            case .blackAndWhite:
                let filter = CIFilter.photoEffectMono()
                filter.inputImage = inputCIImage
                return filter.outputImage
            case .sepia:
                let filter = CIFilter.sepiaTone()
                filter.intensity = 1.0
                filter.inputImage = inputCIImage
                return filter.outputImage
            case .monochrome:
                let filter = CIFilter.colorMonochrome()
                filter.intensity = 1.0
                filter.color = CIColor(red: 0.7, green: 0.7, blue: 0.7) //grey tone
                filter.inputImage = inputCIImage
                return filter.outputImage
            case .noir:
                let filter = CIFilter.photoEffectNoir()
                filter.inputImage = inputCIImage
                return filter.outputImage
            case .vignette:
                let filter = CIFilter.vignette()
                filter.intensity = 2.0
                filter.radius = 3.0
                filter.inputImage = inputCIImage
                return filter.outputImage
            }
        }()
        
        guard let baseImageForAdjustments = filteredCIImage else { return }
        
        // Apply brightness and contrast
        let adjustFilter = CIFilter.colorControls()
        adjustFilter.inputImage = baseImageForAdjustments
        adjustFilter.brightness = brightnessValue
        adjustFilter.contrast = contrastValue
        
        if let finalImage = adjustFilter.outputImage,
           let cgImage = CIContext().createCGImage(finalImage, from: finalImage.extent) {
            DispatchQueue.main.async {
                self.editedImage = UIImage(cgImage: cgImage)
            }
        }
    }
    
    func saveImagetoPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                if let editedImage = self.editedImage {
                    UIImageWriteToSavedPhotosAlbum(editedImage, nil, nil, nil)
                }
            }
        }
    }
}

enum FilterType: String, CaseIterable, Identifiable {
    case none, blackAndWhite, sepia, monochrome, noir, vignette
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .none: return "None"
        case .blackAndWhite: return "B&W"
        case .sepia: return "Sepia"
        case .monochrome: return "Mono"
        case .noir: return "Noir"
        case .vignette: return "Vignette"
        }
    }
}
