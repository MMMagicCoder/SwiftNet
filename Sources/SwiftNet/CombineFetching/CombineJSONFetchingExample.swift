//
//  SwiftUIView.swift
//  
//
//  Created by mohammadmahdi moayeri on 8/25/24.
//

import SwiftUI

struct CombineJSONFetchingExample: View {
    @StateObject var vm = CombineFetching<DataModel>()
    let url: String = "https://jsonplaceholder.typicode.com/posts"
    
    var body: some View {
        List {
            ForEach(vm.dataModels) { item in
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
            vm.fetchJSON(fromURL: url)
        }
    }
}

#Preview {
    CombineJSONFetchingExample()
}
