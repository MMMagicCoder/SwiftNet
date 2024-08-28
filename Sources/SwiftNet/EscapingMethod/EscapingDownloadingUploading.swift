import Foundation

/**
 A class for managing file downloads with options to pause, resume, and cancel downloads using `URLSessionDownloadTask`.

 The `EscapingDownloading` class provides methods to download files from a given URL, pause ongoing downloads by saving the resume data, and cancel downloads entirely. It also handles the file management after the download completes, saving the downloaded file to the app's documents directory.

 - Important: This class is designed for use in scenarios where downloads might need to be paused and resumed, such as large files or unreliable network conditions. The class is `ObservableObject`, making it suitable for use in SwiftUI applications for state management.

 - Usage:
    - Call `downloadData(fromURL:completionHandler:)` to start or resume a download.
    - Call `pauseDownload()` to pause an ongoing download.
    - Call `cancelDownload()` to cancel the download and clear any saved resume data.
 */
public class EscapingDownloading: ObservableObject {
    private var downloadTask: URLSessionDownloadTask?
    private var resumeData: Data?
    private var uploadTask: URLSessionUploadTask?
    
    /**
     Initiates a download from the specified URL. If the download was previously paused, it resumes from where it left off.

     - Parameters:
        - url: The URL string from which to download the file.
        - completionHandler: A closure that gets called when the download completes or fails, providing the local file URL, the URL response, and any error encountered.

     - Note: The downloaded file is saved in the app's documents directory.
     
     - Example:
        ```swift
        let downloader = EscapingDownloading()
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



extension EscapingDownloading {
    /**
     Pauses an ongoing download and saves the data necessary to resume it later.

     This method cancels the download task but produces resume data that can be used to restart the download from where it left off.

     - Note: After pausing, you can resume the download by calling `downloadData(fromURL:completionHandler:)` again.
     
     - Example:
        ```swift
        let downloader = EscapingDownloading()
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
        let downloader = EscapingDownloading()
        downloader.cancelDownload()
        ```
     */
    public func cancelDownload() {
        downloadTask?.cancel()
        downloadTask = nil
        resumeData = nil
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
