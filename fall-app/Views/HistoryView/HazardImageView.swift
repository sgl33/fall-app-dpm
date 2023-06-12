//
//  HazardImageView.swift
//  fall-app
//
//  Created by Seung-Gu Lee on 6/12/23.
//

import SwiftUI

struct HazardImageView: View {
    var imageId: String
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    @State var showPhotoPicker: Bool = false
    
    init(imageId: String) {
        self.imageId = imageId
        // load image
        FirebaseManager.loadImage(uuid: imageId, loader: imageLoader)
    }
    
    var body: some View {
        VStack {
            if imageLoader.loading {
                Text("Loading...")
            }
            else {
                Image(uiImage: imageLoader.image)
                    .resizable()
                    .scaledToFit()
                
                Button(action: {
                    showPhotoPicker = true
                }) {
                    IconButtonInner(iconName: "camera.fill", buttonText: "Replace Photo")
                }
                .buttonStyle(IconButtonStyle(backgroundColor: .cyan,
                                             foregroundColor: .black))
                // Photo Picker
                .sheet(isPresented: $showPhotoPicker) {
                    ImagePickerView() { image in
                        FirebaseManager.uploadImage(uuid: imageId, image: image)
                        imageLoader.image = image
                        Toast.showToast("Success!")
                    }.presentationDetents([.large])
                }
            }
        }
    }
}
