import Foundation

public protocol FetchableModel: Identifiable, Codable {}

/// An enum representing common MIME types for file uploads.
public enum MIMEType: String {
    // Text-Based Files
    case plainText = "text/plain"
    case html = "text/html"
    case css = "text/css"
    case javascript = "application/javascript"
    case json = "application/json"
    case xml = "application/xml"
    case csv = "text/csv"
    
    // Image Files
    case jpeg = "image/jpeg"
    case png = "image/png"
    case gif = "image/gif"
    case svg = "image/svg+xml"
    case webp = "image/webp"
    
    // Audio Files
    case mp3 = "audio/mpeg"
    case wav = "audio/wav"
    case ogg = "audio/ogg"
    
    // Video Files
    case mp4 = "video/mp4"
    case webm = "video/webm"
    case oggVideo = "video/ogg"
    
    // Application Files
    case pdf = "application/pdf"
    case zip = "application/zip"
    case gzip = "application/gzip"
    case docx = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    case xlsx = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    case pptx = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    
    // Binary Files
    case binary = "application/octet-stream"
    
    // Font Files
    case woff = "font/woff"
    case woff2 = "font/woff2"
    
    // Tarball Archive
    case tar = "application/x-tar"
    
    // RTF Document
    case rtf = "application/rtf"
    
    /// Returns the MIME type as a string.
    public func asString() -> String {
        return self.rawValue
    }
}
