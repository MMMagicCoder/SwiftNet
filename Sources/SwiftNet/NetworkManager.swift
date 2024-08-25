//
//  NetworkManager.swift
//  SwiftNet
//
//  Created by mohammadmahdi moayeri on 8/22/24.
//

import Foundation

private class NetworkManager: ObservableObject {
    private static func dataTask(fromURL url: URL, completionHandler: @escaping (_ data: Data?) -> ()) {
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
}
