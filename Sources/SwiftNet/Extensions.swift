//
//  NetworkManager.swift
//  SwiftNet
//
//  Created by mohammadmahdi moayeri on 8/22/24.
//

import Foundation
import Combine

public class NetworkManager: ObservableObject {
    public static func dataTaskPublisher(fromURL url: URL) -> AnyPublisher<Data, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .tryMap { data, response in
                guard let response = response as? HTTPURLResponse,
                      response.statusCode >= 200 && response.statusCode < 300 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .eraseToAnyPublisher()
    }
}


extension URLSession {
    func downloadTaskPublisher(fromURL url: URL) -> AnyPublisher<(URL, URLResponse), URLError> {
        Future<(URL, URLResponse), URLError> { promise in
            let downloadTask = self.downloadTask(with: url) { tempURL, response, error in
                if let error = error {
                    promise(.failure(error as? URLError ?? URLError(.unknown)))
                } else if let tempURL = tempURL, let response = response {
                    promise(.success((tempURL, response)))
                }
            }
            downloadTask.resume()
        }
        .eraseToAnyPublisher()
    }
}
