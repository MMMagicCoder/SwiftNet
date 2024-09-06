import SwiftUI

struct EscapingDataFetchingExample: View {
    @StateObject private  var networkManager = EscapingNetworkManager()
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
            //            Documentation
            /*
             1. Initial Data Fetch:
             The code begins by triggering a function to fetch JSON data from a specified URL.
             This JSON data is expected to contain various data models, each potentially containing a URL pointing to some resource.
             
             2. Data Processing:
             Once the JSON data is successfully fetched, it is processed and stored in a local variable or array.
             The code then iterates over the fetched data models.
             
             3. Fetching Associated Resources:
             For each data model, the code extracts a URL and initiates another request to fetch the resource from that URL.
             In this specific case, the resource is expected to be image data.
             
             4. Resource Handling:
             Upon successfully retrieving the resource (in this case, image data), it is converted from raw data to an image format (e.g., UIImage).
             The image is then stored in a local collection (e.g., an array).
             This process repeats for each data model retrieved in the initial JSON fetch.
             */
            networkManager.fetchJSON(fromURL: url) { (returnedData: [ImageModel]?, response, error)  in
                guard let data = returnedData else { return }
                self.dataModels = data
                
                for dataModel in dataModels {
                    networkManager.fetchData(fromURL: dataModel.url) { (imageData, response, error)  in
                        guard let imageData = imageData, let image = UIImage(data: imageData) else { return }
                        self.images.append(image)
                    }
                }
            }
        }
    }
}

#Preview {
    EscapingDataFetchingExample()
}
