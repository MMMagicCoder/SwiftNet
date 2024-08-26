//
//  EscapingFetchingExample.swift
//  
//
//  Created by mohammadmahdi moayeri on 8/22/24.
//

import SwiftUI

struct DataModel: FetchableModel {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

struct EscapingJSONFetchingExample: View {
    @StateObject var escapingFetching = EscapingFetching<DataModel>()
    let url: String = "https://jsonplaceholder.typicode.com/posts"
    
    var body: some View {
        List {
            ForEach(escapingFetching.dataModelItems) { item in
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
            escapingFetching.fetchJSON(fromURL: url)
        }
    }
}

#Preview {
    EscapingJSONFetchingExample()
        .previewDevice("iPhone 15")
}
