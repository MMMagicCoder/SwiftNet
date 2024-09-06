import Foundation

public class EscapingUploadManager {
    @Published var uploadProgress: Double = 0.0
    @Published var observation: NSKeyValueObservation?
    
    private let session: URLSession
    private var uploadTask: URLSessionUploadTask?
    
    public init(session: URLSession) {
        self.session = session
    }
    
    public func uploadData(toURL url: String, data: Data, mimeType: MIMEType? = .binary ,completionHandler: @escaping (URLResponse? , Error?) -> ()) {
        guard let url = URL(string: url) else {
            completionHandler(nil, URLError(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(mimeType?.asString(), forHTTPHeaderField: "Content-Type")
        
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
    
    public func cancelUpload() {
        uploadTask?.cancel()
        uploadTask = nil
    }
}
