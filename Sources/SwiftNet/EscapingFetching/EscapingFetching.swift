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
    @Published var uiImages: [UIImage] = []
    
    /**
         Fetches JSON data from the given URL and decodes it into an array of data models of type `T`.

         This function uses `NetworkManager` to perform a data task and then decodes the JSON data into an array of models that conform to the `FetchableModel` protocol. The result is published to the `dataModelItems` property. The data fetching is performed using an escaping closure, allowing asynchronous operations.

         - Parameters:
            - url: A `String` representing the URL to fetch the JSON data from.
         */
    public func fetchJSON(fromURL url: String, completionHandler: (() -> Void)? = nil) {
        guard let url = URL(string: url) else { return }
        
        NetworkManager.dataTask(fromURL: url) { returnedData in
            if let data = returnedData {
                guard let newDataModelItem = try? JSONDecoder().decode([T].self, from: data) else { return }
                
                DispatchQueue.main.async { [weak self] in
                    self?.dataModelItems = newDataModelItem
                    completionHandler?()
                }
            } else {
                print("Somthing went wrong during fetching data!!!")
            }
        }
    }
    
    /**
     Fetches an image from the given URL and appends it to the `uiImages` array.

     This function uses `NetworkManager` to perform a data task that fetches image data from the specified URL. The image data is then converted to a `UIImage` object and added to the `uiImages` array. The image fetching is performed asynchronously using an escaping closure, allowing the operation to be executed in the background without blocking the main thread.

     - Parameters:
        - url: A `String` representing the URL to fetch the image from.
     */
    public func fetchUIImage(fromURL url: String) {
        guard let url = URL(string: url) else { return }
        
        NetworkManager.dataTask(fromURL: url) { returnedData in
            if let data = returnedData {
                guard let image = UIImage(data: data) else {
                               print("Failed to convert data to image")
                               return
                           }
                
                DispatchQueue.main.async { [weak self] in
                    self?.uiImages.append(image)
                }
            } else {
                print("Something went wrong during fetching the image!!!")
            }
        }
    }
}
