import Foundation
import SwiftUI
import Combine

/**
 A class that handles the fetching and management of data models and images using Combine.

 The `CombineFetching` class is a generic class where `T` conforms to the `FetchableModel` protocol. It provides functionalities to fetch JSON data and images from given URLs, and publishes the fetched data so that it can be observed by SwiftUI views.

 - Parameters:
    - dataModels: An array of fetched data models of type `T`. This is automatically updated when JSON data is successfully fetched.
    - uiImages: An array of `UIImage` objects that are fetched from image URLs. This is automatically updated when images are successfully fetched.
    - cancellables: A set of `AnyCancellable` objects used to store subscriptions for Combine pipelines.
 */
public class CombineFetching<T: FetchableModel>: ObservableObject {
    @Published var dataModels: [T] = []
    @Published var uiImages: [UIImage] = []
    var cancellables = Set<AnyCancellable>()
    
    /**
      Fetches JSON data from the given URL and decodes it into an array of data models of type `T`.

      This function uses `NetworkManager` to perform a data task publisher, then decodes the JSON data into an array of models that conform to the `FetchableModel` protocol. The result is published to the `dataModels` property. If a completion handler is provided, it will be called after the data is successfully fetched and assigned.

      - Parameters:
         - url: A `String` representing the URL to fetch the JSON data from.
         - completionHandler: An optional closure that gets called when the data fetching and decoding process is complete. Default value is `nil`.
      */
    public func fetchJSON(fromURL url: String, completionHandler: (() -> Void)? = nil) {
        guard let url = URL(string: url) else { return }
        
        NetworkManager.dataTaskPublisher(fromURL: url)
            .decode(type: [T].self, decoder: JSONDecoder())
            .sink { completion in
                switch completion {
                case .finished:
                    print("Finished fetching JSON")
                case .failure(let error):
                    print("Failed to fetch JSON: \(error)")
                }
            } receiveValue: { [weak self] returnedData in
                self?.dataModels = returnedData
                completionHandler?()
            }
            .store(in: &cancellables)
    }
    
    /**
        Fetches images from the given URL and converts them to `UIImage` objects.

        This function uses `NetworkManager` to perform a data task publisher, then attempts to convert the fetched data into `UIImage` objects. If successful, the images are appended to the `uiImages` array.

        - Parameters:
           - url: A `String` representing the URL to fetch the image data from.
        */
    public func fetchUIImages(fromURL url: String) {
        guard let url = URL(string: url) else { return }
        
        NetworkManager.dataTaskPublisher(fromURL: url)
            .tryMap { data -> UIImage? in
                UIImage(data: data)
            }
            .sink { completion in
                switch completion {
                case .finished:
                    print("Finished fetching image")
                case .failure(let error):
                    print("Failed to fetch image: \(error)")
                }
            } receiveValue: { [weak self] returnedImage in
                if let image = returnedImage {
                    self?.uiImages.append(image)
                } else {
                    print("Failed to convert data to UIImage")
                }
            }
            .store(in: &cancellables)
    }
}
