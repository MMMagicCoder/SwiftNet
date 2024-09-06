//
//  SwiftUIView.swift
//  
//
//  Created by mohammadmahdi moayeri on 8/25/24.
//

import SwiftUI

struct CombineJSONFetchingExample: View {
    let networkManager = CombineNetworkManager()
    
    @State var  dataModels: [DataModel] = []
    let url: String = "https://jsonplaceholder.typicode.com/posts"
    
    var body: some View {
        List {
            ForEach(dataModels) { item in
                VStack(alignment: .leading) {
                    Text(item.title)
                        .font(.headline)
                    Text(item.body)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .onAppear {
            networkManager.fetchJSON(fromURL: url) { (returnedData: [DataModel]?, response, error) in
                guard let data = returnedData else { return }
                
                self.dataModels = data
            }
        }
    }
}

#Preview {
    CombineJSONFetchingExample()
}
