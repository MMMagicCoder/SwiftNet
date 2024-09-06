import SwiftUI

struct EscapingJSONFetchingExample: View {
    @StateObject private  var networkManager = EscapingNetworkManager()
    @State private var dataModels: [DataModel] = []
    let url: String = "https://jsonplaceholder.typicode.com/posts"
    
    var body: some View {
        List(dataModels) { item in
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.headline)
                Text(item.body)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear {
            networkManager.fetchJSON(fromURL: url) { (returnedData: [DataModel]?, response, error) in
                if let data = returnedData {
                    self.dataModels = data
                } else {
                    // Handle error or empty data scenario here
                    print("Failed to fetch data: \(String(describing: error))")
                }
            }
        }
    }
}

#Preview {
    EscapingJSONFetchingExample()
        .previewDevice("iPhone 15")
}
