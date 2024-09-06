import Foundation
import Combine

public class CombineUploadManager {
    @Published var observation: NSKeyValueObservation?
    @Published var uploadProgress: Double = 0.0
    
    private let session: URLSession
    private var cancellables = Set<AnyCancellable>()
    private var uploadTask: URLSessionUploadTask?
    
    // MARK: - Initialization
    public init(session: URLSession) {
        self.session = session
    }
    
    // MARK: - Public Methods
    
    public func uploadData(toURL url: String, data: Data, mimeType: MIMEType? = .binary, completionHandler: @escaping (URLResponse?, Error?) -> ()) {
        configureUploadTask(toURL: url, data: data, completionHandler: completionHandler)
        
        // Observe Progress
        observeUploadProgress()
        
        // Start Task
        uploadTask?.resume()
    }
    
    public func cancelUpload() {
        uploadTask?.cancel()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func configureUploadTask(toURL url: String, data: Data, mimeType: MIMEType? = .binary, completionHandler: @escaping (URLResponse?, Error?) -> ()) {
        let publisher: Future<URLResponse, URLError>
        
        guard let url = URL(string: url) else {
            completionHandler(nil, URLError(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(mimeType?.asString(), forHTTPHeaderField: "Content-Type")
        
        publisher = session.uploadTaskPublisher(for: request, from: data, onTaskCreated: { [weak self] task in
            self?.uploadTask = task
        })
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error uploading data: \(error.localizedDescription)")
                    completionHandler(nil, error)
                case .finished:
                    print("Successfuly uploaded.")
                }
            } receiveValue: { response in
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Upload failed with response: \(String(describing: response))")
                    completionHandler(response, nil)
                    return
                }
                completionHandler(response, nil)
            }
            .store(in: &cancellables)
    }
    
    private func observeUploadProgress() {
        observation = uploadTask?.progress.observe(\.fractionCompleted) { [weak self] progress, _ in
            DispatchQueue.main.async {
                self?.uploadProgress = progress.fractionCompleted
            }
        }
    }
}
