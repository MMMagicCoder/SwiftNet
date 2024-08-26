import Foundation
import SwiftUI

/**
 A class that handles the fetching and management of data models using an escaping closure.

 The `EscapingFetching` class is a generic class where `T` conforms to the `FetchableModel` protocol. It provides functionality to fetch JSON data from a given URL, decode it into an array of data models, and publish the fetched data so that it can be observed by SwiftUI views.

 - Parameters:
    - dataModelItems: An array of fetched data models of type `T`. This array is automatically updated when JSON data is successfully fetched.
 */
public class EscapingFetching<T: FetchableModel>: ObservableObject {
    @Published var dataModelItems: [T] = []
    
    /**
         Fetches JSON data from the given URL and decodes it into an array of data models of type `T`.

         This function uses `NetworkManager` to perform a data task and then decodes the JSON data into an array of models that conform to the `FetchableModel` protocol. The result is published to the `dataModelItems` property. The data fetching is performed using an escaping closure, allowing asynchronous operations.

         - Parameters:
            - url: A `String` representing the URL to fetch the JSON data from.
         */
    public func fetchData(fromURL url: String) {
        guard let url = URL(string: url) else { return }
        
        NetworkManager.dataTask(fromURL: url) { returnedData in
            if let data = returnedData {
                guard let newDataModelItem = try? JSONDecoder().decode([T].self, from: data) else { return }
                
                DispatchQueue.main.async { [weak self] in
                    self?.dataModelItems = newDataModelItem
                }
            } else {
                print("Somthing went wrong during fetching data!!!")
            }
        }
    }
}
