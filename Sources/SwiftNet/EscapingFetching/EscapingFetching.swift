import Foundation
import SwiftUI

/**
 A utility class for fetching data from a network resource, supporting both JSON decoding into a model and raw data fetching.
 
 The `EscapingFetching` class provides two methods:
 
 - `fetchJSON(fromURL:completionHandler:)`: Fetches JSON data from a given URL, decodes it into an array of models conforming to the `FetchableModel` protocol, and returns the decoded data via a completion handler.
 - `fetchData(fromURL:completionHandler:)`: Fetches raw data from a given URL and returns it via a completion handler. This method can be used for fetching image data or other non-JSON data.
 
 - Note: Both methods perform network requests asynchronously and execute the completion handler on the main thread.
 
 - Parameters:
 - T: A generic type conforming to the `FetchableModel` protocol, representing the model to decode the JSON data into.
 */

public class EscapingFetching<T: FetchableModel>: ObservableObject {
    
    /**
     Fetches JSON data from a specified URL, decodes it into an array of `T` models, and returns the result via a completion handler.
     
     - Parameters:
     - url: The URL string from which to fetch the JSON data.
     - completionHandler: A closure that gets called with the decoded data on success, or `nil` if the operation fails.
     
     - Note: If the data fetching or decoding process fails, the completion handler will be called with `nil`.
     */
    public func fetchJSON(fromURL url: String, completionHandler: @escaping ([T]?) -> ()) {
        guard let url = URL(string: url) else { return }
        
        NetworkManager.dataTask(fromURL: url) { returnedData in
            if let data = returnedData {
                guard let dataModel = try? JSONDecoder().decode([T].self, from: data) else { return }
                
                DispatchQueue.main.async {
                    completionHandler(dataModel)
                }
            } else {
                print("Something went wrong during fetching data!!!")
                completionHandler(nil)
            }
        }
    }
    
    /**
     Fetches raw data from a specified URL and returns the result via a completion handler.
     
     - Parameters:
     - url: The URL string from which to fetch the raw data.
     - completionHandler: A closure that gets called with the fetched data on success, or `nil` if the operation fails.
     
     - Note: This method is useful for fetching non-JSON data such as images.
     */
    public func fetchData(fromURL url: String, completionHandler: @escaping (Data?) -> ()) {
        guard let url = URL(string: url) else { return }
        
        NetworkManager.dataTask(fromURL: url) { returnedData in
            if let data = returnedData {
                DispatchQueue.main.async {
                    completionHandler(data)
                }
            } else {
                print("Something went wrong during fetching the image!!!")
                completionHandler(nil)
            }
        }
    }
    
    public func downloadData(fromURL url: String, completionHandler: @escaping (URL?, URLResponse?, Error?) -> ()) {
        guard let url = URL(string: url) else { return }
        URLSession.shared.downloadTask(with: url) { tempLocalUrl, response, error in
            if let error = error {
                print("Download error: \(error.localizedDescription)")
                completionHandler(nil, response, error)
                return
            }
            
            guard let tempLocalUrl = tempLocalUrl else {
                print("No file location recieved!")
                completionHandler(nil, response, nil)
                return
            }
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileName = url.lastPathComponent
            let destinationUrl = documentsDirectory.appendingPathComponent(fileName)
            
            do {
                if FileManager.default.fileExists(atPath: destinationUrl.path) {
                    try FileManager.default.removeItem(at: destinationUrl)
                }
                try FileManager.default.moveItem(at: tempLocalUrl, to: destinationUrl)
                print("File successfully downloaded to: \(destinationUrl.path)")
                completionHandler(destinationUrl, response, nil)
                
            } catch let moveError {
                print("File move error: \(moveError.localizedDescription)")
                completionHandler(nil, response, moveError)
            }
        }.resume()
    }
}
