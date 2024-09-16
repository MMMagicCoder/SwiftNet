import SwiftUI

struct AsyncDataManagerExample: View {
    @StateObject private var networkManager = AsyncNetworkManager()
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
            Task {
                do {
                    let (fetchedData, _) = try await networkManager.fetchJSON(fromURL: url) as ([DataModel], URLResponse)
                    
                    await MainActor.run {
                        self.dataModels = fetchedData
                    }
                } catch {
                    print("Error fetching data: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    AsyncDataManagerExample()
}
