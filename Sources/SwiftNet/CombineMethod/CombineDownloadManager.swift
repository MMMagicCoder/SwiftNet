import Foundation
import Combine

public class CombineDownloadManager {
    @Published var observation: NSKeyValueObservation?
    @Published var downloadProgress: Double = 0.0
    
    private let session: URLSession
    private var downloadTask: URLSessionDownloadTask?
    private var resumeData: Data?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init(session: URLSession) {
        self.session = session
    }
    
    // MARK: - Public Methods
    
    public func downloadData(fromURL urlString: String, completionHandler: @escaping (URL?, URLResponse?, Error?) -> ()) {
        guard let url = URL(string: urlString) else {
            completionHandler(nil, nil, URLError(.badURL))
            return
        }
        
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
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func configureDownloadTask(with url: URL, completionHandler: @escaping (URL?, URLResponse?, Error?) -> ()) {
        let publisher: Future<(URL, URLResponse), URLError>
        
        if let resumeData = resumeData {
            // Resume download if resumeData is available
            publisher = session.downloadTaskPublisher(withResumeData: resumeData) { [weak self] task in
                self?.downloadTask = task
            }
        } else {
            // Start a new download
            publisher = session.downloadTaskPublisher(fromURL: url) { [weak self] task in
                self?.downloadTask = task
            }
        }
        
        publisher
            .receive(on: DispatchQueue.main)
            .tryMap { [weak self] (temporaryFileURL, urlResponse) in
                guard let self = self else { throw URLError(.cancelled) }
                return try self.moveFileToDocuments(from: temporaryFileURL, response: urlResponse)
            }
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Download failed with error: \(error.localizedDescription)")
                    completionHandler(nil, nil, error)
                case .finished:
                    print("Download completed successfully.")
                }
                self.downloadTask = nil  // Clear the task after completion
            } receiveValue: { (savedFileURL, response) in
                print("File saved to: \(savedFileURL)")
                self.resumeData = nil  // Clear resume data on successful download
                completionHandler(savedFileURL, response, nil)
            }
            .store(in: &cancellables)
    }
    
    private func observeDownloadProgress() {
        observation = downloadTask?.progress.observe(\.fractionCompleted) { [weak self] progress, _ in
            DispatchQueue.main.async {
                self?.downloadProgress = progress.fractionCompleted
            }
        }
    }
    
    private func moveFileToDocuments(from temporaryFileURL: URL, response urlResponse: URLResponse) throws -> (URL, URLResponse) {
        let destinationURL = getDestinationUrl(for: temporaryFileURL, response: urlResponse)
        
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        
        try FileManager.default.moveItem(at: temporaryFileURL, to: destinationURL)
        return (destinationURL, urlResponse)
    }
    
    private func getDestinationUrl(for temporaryFileURL: URL, response urlResponse: URLResponse) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = UUID().uuidString + "-" + (urlResponse.suggestedFilename ?? temporaryFileURL.lastPathComponent)
        return documentsDirectory.appendingPathComponent(fileName)
    }
}
