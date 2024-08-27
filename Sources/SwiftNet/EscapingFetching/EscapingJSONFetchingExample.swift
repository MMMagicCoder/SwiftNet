import SwiftUI

struct EscapingJSONFetchingExample: View {
    @StateObject var escapingFetching = EscapingFetching<DataModel>()
    @State var dataModels: [DataModel] = []
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
            escapingFetching.fetchJSON(fromURL: url) { returnedData in
                guard let data = returnedData else { return }
                
                self.dataModels = data
            }
        }
    }
}

#Preview {
    EscapingJSONFetchingExample()
        .previewDevice("iPhone 15")
}
