//
//  SwiftUIView.swift
//  
//
//  Created by mohammadmahdi moayeri on 8/29/24.
//

import SwiftUI

struct EscapingUploading: View {
    let uploader = EscapingDownloadingUploading()
    let url: String = "https://jsonplaceholder.typicode.com/posts"
    @State var message: String = ""
    let json: [String: Any] = [
        "userId": 1,
        "id": 1,
        "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
        "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
      ]
    
    func convertToJson(json: [String: Any]) -> Data? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            print("Failed to convert JSON to Data")
            return nil
        }
        return jsonData
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                guard let json = convertToJson(json: json) else { return }
                uploader.uploadingData(toURL: url, data: json, mimType: .json) { response , error in
                    if let error = error {
                            message = "Upload error: \(error.localizedDescription)"
                        } else if let response = response as? HTTPURLResponse, response.statusCode == 201 {
                            message = "Upload successful! Response status code: \(response.statusCode)"
                        } else {
                            message = "Upload failed or unexpected response."
                        }
                }
                
            }, label: {
                Text("Tap to upload...")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .frame(width: 250, height: 100)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            })
            
            Text(message)
        }
    }
}

#Preview {
    EscapingUploading()
}
