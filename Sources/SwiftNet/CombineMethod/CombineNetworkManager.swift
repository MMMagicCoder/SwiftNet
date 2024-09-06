import Foundation
import SwiftUI
import Combine

public class CombineNetworkManager: ObservableObject {
    @Published var downloadProgress: Double = 0.0
    
    private let dataManager: CombineDataManager
    private let downloadManager: CombineDownloadManager
    private let uploadManager: CombineUploadManager
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        dataManager = CombineDataManager(session: URLSession.shared)
        downloadManager = CombineDownloadManager(session: URLSession.shared)
        uploadManager = CombineUploadManager(session: URLSession.shared)
        
        downloadManager.$downloadProgress
            .receive(on: DispatchQueue.main)
            .assign(to: \.downloadProgress, on: self)
            .store(in: &cancellables)
    }
    
    //    MARK: - Fetch JSON
    
    /**
       Fetches JSON data from the specified URL and decodes it into an array of model objects that conform to `FetchableModel`.
       
       This method performs a network request to the provided URL, attempts to decode the received data into an array of model objects, and invokes the completion handler with the decoded data or an error if the request or decoding fails.
       
       - Parameters:
         - url: The URL string from which to fetch the JSON data. This string must be a valid URL.
         - completionHandler: A closure that gets called when the network request completes. It provides an array of decoded model objects, the URL response, and any error encountered during the request or decoding process.
       
       - Note: The `FetchableModel` protocol is used to define the model objects that the JSON data should be decoded into. Ensure that the model conforms to `Decodable` and matches the structure of the JSON data.
       
       - Example:
         ```swift
         let dataManager = CombineNetworkManager()
         dataManager.fetchJSON(fromURL: "https://example.com/data.json") { (model: [YourModel]?, response, error) in
             if let model = model {
                 // Handle the successfully decoded model array
             } else if let error = error {
                 // Handle the error
             }
         }
         ```
       */
    public func fetchJSON<T: FetchableModel>(fromURL url: String, completionHandler: @escaping ([T]?, URLResponse?, Error?) -> ()) {
        dataManager.fetchJSON(fromURL: url, completionHandler: completionHandler)
    }
    
    /**
         Fetches raw data from the specified URL.
         
         This method performs a network request to the provided URL and invokes the completion handler with the raw data received from the server, or with an error if the request fails.
         
         - Parameters:
           - url: The URL string from which to fetch the data. This string must be a valid URL.
           - completionHandler: A closure that gets called when the network request completes. It provides the raw data received from the server, the URL response, and any error encountered during the request.
         
         - Example:
           ```swift
           let dataManager = CombineNetworkManager()
           dataManager.fetchData(fromURL: "https://example.com/file.dat") { data, response, error in
               if let data = data {
                   // Handle the raw data
               } else if let error = error {
                   // Handle the error
               }
           }
           ```
         */
    public func fetchData(fromURL url: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
        dataManager.fetchData(fromURL: url, completionHandler: completionHandler)
    }
    
    // MARK: - Download Data
    
    /**
     Starts or resumes downloading data from the specified URL.
     
     This method starts a new download if no previous data exists or resumes a paused download using the stored `resumeData`. The progress of the download is observed in real-time and can be accessed via the `downloadProgress` property.
     
     - Parameters:
       - urlString: The URL string from which to download the data. This string must be a valid URL.
       - completionHandler: A closure that gets called when the download is completed. It provides the local file URL, the URL response, and any error encountered during the download.
     
     - Example:
       ```swift
       let downloadManager = CombineNetworkManager()
       downloadManager.downloadData(fromURL: "https://example.com/file.zip") { fileURL, response, error in
           if let fileURL = fileURL {
               // Handle the downloaded file
               print("File downloaded to: \(fileURL)")
           } else if let error = error {
               // Handle the error
               print("Error during download: \(error)")
           }
       }
       ```
     */
    public func downloadData(fromURL url: String, completionHandler: @escaping (URL?, URLResponse?, Error?) -> ()) {
        downloadManager.downloadData(fromURL: url, completionHandler: completionHandler)
    }
    
    /**
     Pauses the ongoing download and stores the data required to resume it later.
     
     When this method is called, the current download is paused, and the `resumeData` is stored. The download can be resumed later using the stored data.
     */
    public func pauseDownload() {
        downloadManager.pauseDownload()
    }
    
    /**
     Cancels the ongoing download and clears any stored resume data.
     
     This method cancels the download if one is active and resets both the `downloadTask` and `resumeData` properties, making it impossible to resume the download.
     */
    public func cancelDownload() {
        downloadManager.cancelDownload()
    }
    
    // MARK: - Upload Data
    
    /**
     Starts uploading data to the specified URL with an optional MIME type.
     
     This method uploads the provided `Data` object to the specified URL via an HTTP `POST` request. It observes the progress of the upload task and updates the `uploadProgress` property.
     
     - Parameters:
       - url: The string representing the URL to which the data will be uploaded. Must be a valid URL string.
       - data: The `Data` object to be uploaded.
       - mimeType: An optional `MIMEType` specifying the content type of the uploaded data. Defaults to `.binary` if not specified.
       - completionHandler: A closure that gets called when the upload is completed. It provides the server's response and any error encountered during the upload.
     
     - Example:
       ```swift
       let uploadManager = CombineNetworkManager()
       let dataToUpload = Data()  // Your data here
       uploadManager.uploadData(toURL: "https://example.com/upload", data: dataToUpload, mimeType: .json) { response, error in
           if let error = error {
               print("Upload error: \(error.localizedDescription)")
           } else {
               print("Upload completed successfully.")
           }
       }
       ```
     */
    public func uploadData(toURL url: String, data: Data, mimeType: MIMEType? = .binary, completionHandler: @escaping (URLResponse?, Error?) -> ()) {
        uploadManager.uploadData(toURL: url, data: data, mimeType: mimeType, completionHandler: completionHandler)
    }
    
    /**
     Cancels the ongoing upload task.
     
     This method cancels the active upload task and clears the internal `uploadTask` reference. Any progress tracking or ongoing uploads will be stopped.
     */
    public func cancelUpload() {
        uploadManager.cancelUpload()
    }
}
    
    
