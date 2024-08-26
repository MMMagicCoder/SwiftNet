//
//  NetworkManager.swift
//  SwiftNet
//
//  Created by mohammadmahdi moayeri on 8/22/24.
//

import Foundation
import Combine

public protocol FetchableModel: Identifiable, Codable {}

public class NetworkManager: ObservableObject {
    public static func dataTask(fromURL url: URL, completionHandler: @escaping (_ data: Data?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  error == nil,
                    let response = response as? HTTPURLResponse,
                  response.statusCode >= 200 && response.statusCode < 300 else {
                print("Error downloading data!!!")
                completionHandler(nil)
                return
            }
            return completionHandler(data)
        }.resume()
    }
    
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
