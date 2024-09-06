//
//  SwiftUIView.swift
//  
//
//  Created by mohammadmahdi moayeri on 9/6/24.
//

import SwiftUI

struct SwiftUIView: View {
    @StateObject private var networkManager = CombineNetworkManager()
    let url: String = "https://via.placeholder.com/600/92c952"
    @State var message: String = ""
    @State var downloadedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 20) {
            if let image = downloadedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
            }
            
            Button(action: {
                networkManager.downloadData(fromURL: url) { tempLocalUrl, response, error in
                    if let tempLocalUrl = tempLocalUrl {
                        // Load the image from the URL
                        if let imageData = try? Data(contentsOf: tempLocalUrl),
                           let image = UIImage(data: imageData) {
                            downloadedImage = image
                            message = "Download was successful."
                        } else {
                            message = "Failed to load image from downloaded URL."
                        }
                    } else {
                        message = "Download failed with error: \(String(describing: error))"
                    }
                }
            }, label: {
                Text("Download Image")
                    .foregroundColor(Color.white)
                    .fontWeight(.bold)
                    .frame(width: 250, height: 80)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
            })
            
            ProgressView(value: networkManager.downloadProgress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(maxWidth: 300)
                .padding()
            
            Text(message)
                .frame(width: 400)
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
    }
}

#Preview {
    SwiftUIView()
}
