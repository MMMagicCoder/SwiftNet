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
    @State var dataModels: [ImageModel] = []
    @State var images: [UIImage] = []
    let url: String = "https://jsonplaceholder.typicode.com/photos"
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(images.indices, id: \.self) { index in
                    Image(uiImage: images[index])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .padding()
                }
            }
        }
        .onAppear {
            vm.fetchJSON(fromURL: url) { returnedData in
                if let data = returnedData {
                    self.dataModels = data
                }
                for dataModel in dataModels {
                    vm.fetchData(fromURL: dataModel.url) { returnedData in
                        if let data = returnedData, let image = UIImage(data: data) {
                            self.images.append(image)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CombineImageFetchingExample()
}
