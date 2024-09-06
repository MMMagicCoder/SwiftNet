import Foundation
import Combine

public class EscapingDownloadManager {
    @Published var observation: NSKeyValueObservation?
    @Published var downloadProgress: Double = 0.0
    
    private let session: URLSession
    private var downloadTask: URLSessionDownloadTask?
    private var resumeData: Data?
    
    // MARK: - Initialization
    
    public init(session: URLSession) {
        self.session = session
    }
    
    // MARK: - Public Methods
    
    public func downloadData(fromURL urlString: String, completionHandler: @escaping (URL?, URLResponse?, Error?) -> ()) {
        guard let url = URL(string: urlString) else { return }
        
        // Start or Resume Download
        configureDownloadTask(with: url, completionHandler: completionHandler)
        
        // Observe Progress
        observeDownloadProgress()
        
        // Start Task
        downloadTask?.resume()
    }
    
    public func pauseDownload() {
        downloadTask?.cancel(byProducingResumeData: { [weak self] resumeDataOrNil in
            self?.resumeData = resumeDataOrNil
            self?.downloadTask = nil
        })
    }
    
    public func cancelDownload() {
        downloadTask?.cancel()
        downloadTask = nil
        resumeData = nil
    }
    
    // MARK: - Private Methods
    
    private func configureDownloadTask(with url: URL, completionHandler: @escaping (URL?, URLResponse?, Error?) -> ()) {
        if let resumeData = resumeData {
            // Resume download if resumeData is available
            downloadTask = session.downloadTask(withResumeData: resumeData) { [weak self] tempLocalUrl, response, error in
                self?.handleDownloadCompletion(tempLocalUrl: tempLocalUrl, response: response, error: error, completionHandler: completionHandler)
            }
        } else {
            // Start a new download
            downloadTask = session.downloadTask(with: url) { [weak self] tempLocalUrl, response, error in
                self?.handleDownloadCompletion(tempLocalUrl: tempLocalUrl, response: response, error: error, completionHandler: completionHandler)
            }
        }
    }
    
    private func observeDownloadProgress() {
        observation = downloadTask?.progress.observe(\.fractionCompleted) { [weak self] progress, _ in
            DispatchQueue.main.async {
                self?.downloadProgress = progress.fractionCompleted
            }
        }
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
        
        let destinationUrl = getDestinationUrl(for: tempLocalUrl)
        
        do {
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                try FileManager.default.removeItem(at: destinationUrl)
            }
            try FileManager.default.moveItem(at: tempLocalUrl, to: destinationUrl)
            print("File successfully downloaded to: \(destinationUrl.path)")
            completionHandler(destinationUrl, response, nil)
        } catch {
            print("File move error: \(error.localizedDescription)")
            completionHandler(nil, response, error)
        }
    }
    
    private func getDestinationUrl(for tempLocalUrl: URL) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = tempLocalUrl.lastPathComponent
        return documentsDirectory.appendingPathComponent(fileName)
    }
}
