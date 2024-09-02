import Foundation
import SwiftUI

/**
 A class for managing both file downloads and uploads using `URLSession`. This class supports downloading files with the ability to pause and resume, as well as uploading data with customizable MIME types. It also tracks the progress of both download and upload tasks.
 
 The `EscapingDownloadingUploading` class implements `URLSessionDelegate` to handle download and upload tasks, providing real-time progress updates for both operations. It is designed to be used in SwiftUI applications and supports observable progress updates.
 
 - Important: This class uses a default `URLSession` configuration. For more advanced use cases, you may need to customize the session configuration or delegate methods.
 
 - Usage:
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
 - `downloadData(fromURL:completionHandler:)`: Starts or resumes a download from the specified URL.
 - `uploadingData(toURL:data:mimType:completionHandler:)`: Uploads the specified data to the given URL with an optional MIME type.
 - `pauseDownload()`: Pauses the current download and saves the data necessary to resume it later.
 - `cancelDownload()`: Cancels the ongoing download and clears any saved resume data.
 - `cancelUpload()`: Cancels the ongoing upload.
 */
public class EscapingNetworkManager: NSObject , ObservableObject, URLSessionDelegate {
    private var downloadTask: URLSessionDownloadTask?
    private var resumeData: Data?
    private var uploadTask: URLSessionUploadTask?
    
    @Published var observation: NSKeyValueObservation?
    @Published var downloadProgress: Double = 0.0
    @Published var uploadProgress: Double = 0.0
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    /**
     Initiates a download from the specified URL. If the download was previously paused, it resumes from where it left off.
     
     - Parameters:
     - url: The URL string from which to download the file.
     - completionHandler: A closure that gets called when the download completes or fails, providing the local file URL, the URL response, and any error encountered.
     
     - Note: The downloaded file is saved in the app's documents directory.
     
     - Example:
     ```swift
     let downloader = EscapingDownloadingUploading()
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
        guard let url = URL(string: url) else { return }
        
        if let resumeData = resumeData {
            // Resume download if resumeData is available
            downloadTask = session.downloadTask(withResumeData: resumeData) { tempLocalUrl, response, error in
                self.handleDownloadCompletion(tempLocalUrl: tempLocalUrl, response: response, error: error, completionHandler: completionHandler)
            }
        } else {
            // Start a new download
            downloadTask = session.downloadTask(with: url) { tempLocalUrl, response, error in
                self.handleDownloadCompletion(tempLocalUrl: tempLocalUrl, response: response, error: error, completionHandler: completionHandler)
            }
        }
        
        observation = downloadTask?.progress.observe(\.fractionCompleted)  { observationProgress, _ in
            DispatchQueue.main.async {
                self.downloadProgress = observationProgress.fractionCompleted
            }
        }
        
        downloadTask?.resume()
    }
    
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
     let uploader = EscapingDownloadingUploading()
     let dataToUpload = Data() // Your file data here
     uploader.uploadingData(toURL: "https://example.com/upload", data: dataToUpload, mimType: .jpeg) { response, error in
     if let response = response {
     // Handle the successful upload
     } else if let error = error {
     // Handle the error
     }
     }
     ```
     */
    public func uploadingData(toURL url: String, data: Data, mimType: MIMEType? = .binary ,completionHandler: @escaping (URLResponse? , Error?) -> ()) {
        guard let url = URL(string: url) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(mimType?.asString(), forHTTPHeaderField: "Content-Type")
        
        uploadTask = session.uploadTask(with: request, from: data) { responseData, response, error in
            if let error = error {
                print("Upload error: \(error.localizedDescription)")
                completionHandler(response, error)
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Upload failed with response: \(String(describing: response))")
                completionHandler(response, nil)
                return
            }
            
            print("Upload successful!")
            completionHandler(response, nil)
        }
        
        observation = uploadTask?.progress.observe(\.fractionCompleted) { observationProgress, _ in
            DispatchQueue.main.async {
                self.uploadProgress = observationProgress.fractionCompleted
            }
        }
        
        uploadTask?.resume()
    }
    
    /**
     Pauses an ongoing download and saves the data necessary to resume it later.
     
     This method cancels the download task but produces resume data that can be used to restart the download from where it left off.
     
     - Note: After pausing, you can resume the download by calling `downloadData(fromURL:completionHandler:)` again.
     
     - Example:
     ```swift
     let downloader = EscapingDownloadingUploading()
     downloader.pauseDownload()
     ```
     */
    public func pauseDownload() {
        downloadTask?.cancel(byProducingResumeData: { resumeDataOrNil in
            self.resumeData = resumeDataOrNil
            self.downloadTask = nil
        })
    }
    
    /**
     Cancels the current download and clears any saved resume data.
     
     This method completely stops the download process and removes any data saved for resuming the download later.
     
     - Example:
     ```swift
     let downloader = EscapingDownloadingUploading()
     downloader.cancelDownload()
     ```
     */
    public func cancelDownload() {
        downloadTask?.cancel()
        downloadTask = nil
        resumeData = nil
    }
    
    /**
     Cancels the current upload.
     
     This method completely stops the upload process.
     
     - Example:
     ```swift
     let uploader = EscapingDownloadingUploading()
     uploader.cancelUpload()
     ```
     */
    public func cancelUpload() {
        uploadTask?.cancel()
        uploadTask = nil
    }
    
    /**
     Handles the completion of a download task, saving the downloaded file to the documents directory.
     
     - Parameters:
     - tempLocalUrl: The temporary file URL where the downloaded file is stored.
     - response: The URL response received from the server.
     - error: Any error encountered during the download.
     - completionHandler: A closure that gets called with the final file URL, response, and error after the download is completed and the file is moved to its final location.
     
     - Note: If the download is successful, the file is moved to the documents directory. If an error occurs, it is passed to the completion handler.
     */
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
