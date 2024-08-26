//
//  SwiftUIView.swift
//  
//
//  Created by mohammadmahdi moayeri on 8/25/24.
//

import SwiftUI

struct ImageModel: FetchableModel {
    let albumId: Int
    let id: Int
    let title: String
    let url: String
    let thumbnailUrl: String
}

struct CombineImageFetchingExample: View {
    @StateObject var vm = CombineFetching<ImageModel>()
    let url: String = "https://jsonplaceholder.typicode.com/photos"
    
    func downloadAllImages() {
        for dataModel in vm.dataModels {
            vm.fetchUIImages(fromURL: dataModel.url)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(vm.uiImages.indices, id: \.self) { index in
                    Image(uiImage: vm.uiImages[index])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .padding()
                }
            }
        }
        .onAppear {
            vm.fetchJSON(fromURL: url) {
                downloadAllImages()
            }
        }
    }
}

#Preview {
    CombineImageFetchingExample()
}
