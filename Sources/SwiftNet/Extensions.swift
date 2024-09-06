import Foundation
import Combine

extension URLSession {
    func downloadTaskPublisher(fromURL url: URL, onTaskCreated: @escaping (URLSessionDownloadTask) -> Void) -> Future<(URL, URLResponse), URLError> {
        Future { promise in
            let downloadTask = self.downloadTask(with: url) { tempURL, response, error in
                if let error = error {
                    promise(.failure(error as? URLError ?? URLError(.unknown)))
                } else if let tempURL = tempURL, let response = response {
                    promise(.success((tempURL, response)))
                }
            }
            onTaskCreated(downloadTask)
            downloadTask.resume()
        }
    }
    
    func downloadTaskPublisher(withResumeData resumeData: Data, onTaskCreated: @escaping (URLSessionDownloadTask) -> Void) -> Future<(URL, URLResponse), URLError> {
        Future { promise in
            let downloadTask = self.downloadTask(withResumeData: resumeData) { tempURL, response, error in
                if let error = error {
                    promise(.failure(error as? URLError ?? URLError(.unknown)))
                } else if let tempURL = tempURL, let response = response {
                    promise(.success((tempURL, response)))
                }
            }
            onTaskCreated(downloadTask)
            downloadTask.resume()
        }
    }
    
    func uploadTaskPublisher(for request: URLRequest, from data: Data ,onTaskCreated: @escaping (URLSessionUploadTask) -> Void) -> Future<URLResponse, URLError> {
        Future { promise in
            let uploadTask = self.uploadTask(with: request, from: data) { data, response, error in
                if let error = error {
                    promise(.failure(error as! URLError))
                } else if let response = response {
                    promise(.success(response))
                }
            }
            onTaskCreated(uploadTask)
            uploadTask.resume()
        }
    }
}

