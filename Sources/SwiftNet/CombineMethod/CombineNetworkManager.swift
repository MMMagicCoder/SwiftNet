import Foundation
import SwiftUI
import Combine

/**
 A utility class that handles fetching JSON data or raw data from a URL using Combine framework.

 The `CombineFetching` class is designed to fetch data from the internet using `URLSession` and Combine's `Publisher` mechanisms. It can decode JSON data into specified models conforming to the `FetchableModel` protocol.

 - Note: The fetched data is handled asynchronously and returned via completion handlers.

 - Parameters:
    - T: A generic type parameter constrained to `FetchableModel`, representing the model type that the fetched JSON data will be decoded into.
    - cancellables: A set of `AnyCancellable` used to store subscriptions, ensuring they are retained during the network request lifecycle.

 - Usage:
   1. Call `fetchJSON(fromURL:completionHandler:)` to fetch and decode JSON data.
 */

public class CombineFetching<T: FetchableModel>: ObservableObject {
    var cancellables = Set<AnyCancellable>()

    /**
     Fetches JSON data from the specified URL, decodes it into an array of the specified model type `T`, and returns it through a completion handler.
     
     - Parameters:
        - url: The URL string from which to fetch the JSON data.
        - completionHandler: A closure that is called upon completion of the fetch operation. The closure takes an optional array of `T` as its parameter, which is `nil` if the fetch or decoding fails.
     */
    public func fetchJSON(fromURL url: String, completionHandler: @escaping ([T]?) -> ()) {
        guard let url = URL(string: url) else { return }
        
        NetworkManager.dataTaskPublisher(fromURL: url)
            .decode(type: [T].self, decoder: JSONDecoder())
            .sink { completion in
                switch completion {
                case .finished:
                    print("Finished fetching JSON")
                case .failure(let error):
                    print("Failed to fetch JSON: \(error)")
                    completionHandler(nil)
                }
            } receiveValue: { returnedData in
                completionHandler(returnedData)
            }
            .store(in: &cancellables)
    }
}
