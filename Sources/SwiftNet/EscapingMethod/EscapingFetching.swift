import Foundation
import SwiftUI

public class EscapingFetching<T: FetchableModel>: ObservableObject {
    private var downloadTask: URLSessionDownloadTask?
    private var resumeData: Data?
    
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
        
        if let resumeData = resumeData {
            // Resume download if resumeData is available
            downloadTask = URLSession.shared.downloadTask(withResumeData: resumeData) { tempLocalUrl, response, error in
                self.handleDownloadCompletion(tempLocalUrl: tempLocalUrl, response: response, error: error, completionHandler: completionHandler)
            }
        } else {
            // Start a new download
            downloadTask = URLSession.shared.downloadTask(with: url) { tempLocalUrl, response, error in
                self.handleDownloadCompletion(tempLocalUrl: tempLocalUrl, response: response, error: error, completionHandler: completionHandler)
            }
        }
        downloadTask?.resume()
    }
}




extension EscapingFetching {
    public func pauseDownload() {
        downloadTask?.cancel(byProducingResumeData: { resumeDataOrNil in
            self.resumeData = resumeDataOrNil
            self.downloadTask = nil
        })
    }
    
    public func cancelDownload() {
        downloadTask?.cancel()
        downloadTask = nil
        resumeData = nil
    }
    
    private func handleDownloadCompletion(tempLocalUrl: URL?, response: URLResponse?, error: Error?, completionHandler: @escaping (URL?, URLResponse?, Error?) -> ()) {
        if let error = error {
            print("Download error: \(error.localizedDescription)")
            completionHandler(nil, response, error)
            return
        }
        
        guard let tempLocalUrl = tempLocalUrl else {
            print("No file location received!")
            completionHandler(nil, response, nil)
            return
        }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = tempLocalUrl.lastPathComponent
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
    }
}
