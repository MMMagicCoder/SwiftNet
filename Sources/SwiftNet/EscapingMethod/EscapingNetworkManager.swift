import Foundation
import SwiftUI

/**
 A class for managing both file downloads and uploads using `URLSession`. This class supports downloading files with the ability to pause and resume, as well as uploading data with customizable MIME types. It also tracks the progress of both download and upload tasks.
 
 The `EscapingDownloadingUploading` class implements `URLSessionDelegate` to handle download and upload tasks, providing real-time progress updates for both operations. It is designed to be used in SwiftUI applications and supports observable progress updates.
 
 - Important: This class uses a default `URLSession` configuration. For more advanced use cases, you may need to customize the session configuration or delegate methods.
 
 - Usage:
 - Call `fetchJSON(fromURL:completionHandler:)` to fetch JSON file to your FetchableModel variable.
 - Call `fetchData(fromURL:completionHandler:)` to fetch small raw data to show it immediately.
 - Call `downloadData(fromURL:completionHandler:)` to start or resume a file download.
 - Call `uploadingData(toURL:data:mimType:completionHandler:)` to upload data with an optional MIME type.
 - Call `pauseDownload()` to pause an ongoing download.
 - Call `cancelDownload()` to cancel the ongoing download.
 - Call `cancelUpload()` to cancel the ongoing upload.
 - Observe `downloadProgress` and `uploadProgress` for real-time updates on the progress of download and upload tasks.
 
 - Properties:
 - `downloadProgress`: A `Double` value representing the current progress of the download as a percentage (0.0 to 1.0).
 - `uploadProgress`: A `Double` value representing the current progress of the upload as a percentage (0.0 to 1.0).
 - `observation`: An `NSKeyValueObservation` object for observing download progress changes.
 
 - Methods:
 - `fetchJSON(fromURL:completionHandler:)`: Fetch JSON file to your FetchableModel variable from the specified URL.
 - `fetchData(fromURL:completionHandler:)` Fetch small raw data to show it immediately from the specified URL.
 - `downloadData(fromURL:completionHandler:)`: Starts or resumes a download from the specified URL.
 - `uploadingData(toURL:data:mimType:completionHandler:)`: Uploads the specified data to the given URL with an optional MIME type.
 - `pauseDownload()`: Pauses the current download and saves the data necessary to resume it later.
 - `cancelDownload()`: Cancels the ongoing download and clears any saved resume data.
 - `cancelUpload()`: Cancels the ongoing upload.
 */
public class EscapingNetworkManager:  ObservableObject{
    @Published var downloadProgress: Double = 0.0
    
    private let dataManager: EscapingDataManager
    private let downloadManager: EscapingDownloadManager
    private let uploadManager: EscapingUploadManager
    
    public init() {
        dataManager = EscapingDataManager(session: URLSession.shared)
        downloadManager = EscapingDownloadManager(session: URLSession.shared)
        uploadManager = EscapingUploadManager(session: URLSession.shared)
        
        downloadManager.$downloadProgress
                    .assign(to: &$downloadProgress)
    }
    
    // MARK: - Fetch Data
    /**
     Fetches JSON data from the specified URL and decodes it into an array of model objects that conform to `FetchableModel`.
     
     This method performs a network request to the provided URL, attempts to decode the received data into an array of model objects, and invokes the completion handler with the decoded data or an error if the request or decoding fails.
     
     - Parameters:
       - url: The URL string from which to fetch the JSON data. This string must be a valid URL.
       - completionHandler: A closure that gets called when the network request completes. It provides an array of decoded model objects, the URL response, and any error encountered during the request or decoding process.
     
     - Note: The `FetchableModel` protocol is used to define the model objects that the JSON data should be decoded into. Ensure that the model conforms to `Decodable` and matches the structure of the JSON data.
     
     - Example:
       ```swift
       let networkManager = EscapingNetworkManager()
       networkManager.fetchJSON(fromURL: "https://example.com/data.json") { (model: [YourModel]?, response, error) in
           if let model = model {
               // Handle the successfully decoded model array
           } else if let error = error {
               // Handle the error
           }
       }
**/
      public func fetchJSON<T: FetchableModel>(fromURL url: String, completionHandler: @escaping ([T]?, URLResponse?, Error?) -> ()) {
          dataManager.fetchJSON(fromURL: url, completionHandler: completionHandler)
      }
      
    /**
     Fetches raw data from the specified URL.
     
     This method performs a network request to the provided URL and invokes the completion handler with the raw data received from the server, or with an error if the request fails.

     - Parameters:
       - url: The URL string from which to fetch the data. This string must be a valid URL.
       - completionHandler: A closure that gets called when the network request completes. It provides the raw data received from the server, the URL response, and any error encountered during the request.
     
     - Note: This method does not attempt to decode or process the raw data; it simply returns it as-is. Use this method when you need to work with the raw data directly, such as for downloading files or handling custom data formats.
     
     - Example:
       ```swift
       let networkManager = EscapingNetworkManager()
       networkManager.fetchData(fromURL: "https://example.com/file.dat") { data, response, error in
           if let data = data {
               // Handle the raw data
           } else if let error = error {
               // Handle the error
           }
       }
**/
      public func fetchData(fromURL url: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
          dataManager.fetchData(fromURL: url, completionHandler: completionHandler)
      }
      
      // MARK: - Download Data
    /**
     Initiates a download from the specified URL. If the download was previously paused, it resumes from where it left off.
     
     - Parameters:
     - url: The URL string from which to download the file.
     - completionHandler: A closure that gets called when the download completes or fails, providing the local file URL, the URL response, and any error encountered.
     
     - Note: The downloaded file is saved in the app's documents directory.
     
     - Example:
     ```swift
     @StateObject var downloader = EscapingNetworkManager()
     downloader.downloadData(fromURL: "https://example.com/file.zip") { localUrl, response, error in
     if let localUrl = localUrl {
     // Handle the successful download
     } else if let error = error {
     // Handle the error
     }
     }
     ```
     */
      public func downloadData(fromURL url: String, completionHandler: @escaping (URL?, URLResponse?, Error?) -> ()) {
          downloadManager.downloadData(fromURL: url, completionHandler: completionHandler)
      }
    
    /**
     Pauses an ongoing download and saves the data necessary to resume it later.
     
     This method cancels the download task but produces resume data that can be used to restart the download from where it left off.
     
     - Note: After pausing, you can resume the download by calling `downloadData(fromURL:completionHandler:)` again.
     
     - Example:
     ```swift
     let downloader = EscapingNetworkManager()
     downloader.pauseDownload()
     ```
     */
      public func pauseDownload() {
          downloadManager.pauseDownload()
      }
      
    /**
     Cancels the current download and clears any saved resume data.
     
     This method completely stops the download process and removes any data saved for resuming the download later.
     
     - Example:
     ```swift
     let downloader = EscapingNetworkManager()
     downloader.cancelDownload()
     ```
     */
      public func cancelDownload() {
          downloadManager.cancelDownload()
      }
      
      // MARK: - Upload Data
    /**
     Uploads data to the specified URL with an optional MIME type. This method handles the upload task and processes the server's response.
     
     - Parameters:
     - url: The URL string to which the data will be uploaded.
     - data: The data to be uploaded.
     - mimType: An optional `MIMEType` representing the content type of the data. Defaults to `application/octet-stream` if not provided.
     - completionHandler: A closure that gets called when the upload completes or fails, providing the URL response and any error encountered.
     
     - Note: If no MIME type is provided, `application/octet-stream` will be used, which is suitable for binary data but not ideal for specific file types like images or text.
     
     - Example:
     ```swift
     @StateObject var uploader = EscapingNetworkManager()
     let dataToUpload = Data() // Your file data here
     uploader.uploadData(toURL: "https://example.com/upload", data: dataToUpload, mimType: .jpeg) { response, error in
     if let response = response {
     // Handle the successful upload
     } else if let error = error {
     // Handle the error
     }
     }
     ```
     */
      public func uploadData(toURL url: String, data: Data, mimeType: MIMEType? = .binary, completionHandler: @escaping (URLResponse?, Error?) -> ()) {
          uploadManager.uploadData(toURL: url, data: data, mimeType: mimeType, completionHandler: completionHandler)
      }
      
    /**
        Cancels the current upload.
   
        This method completely stops the upload process.
   
        - Example:
        ```swift
        let uploader = EscapingNetworkManager()
        uploader.cancelUpload()
        ```
        */
      public func cancelUpload() {
          uploadManager.cancelUpload()
      }
}
