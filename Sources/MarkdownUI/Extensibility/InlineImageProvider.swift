import SwiftUI

/// A type that loads images that are displayed within a line of text.
///
/// To configure the current inline image provider for a view hierarchy,
/// use the `markdownInlineImageProvider(_:)` modifier.
public protocol InlineImageProvider {
  /// Returns an image for the given URL.
  ///
  /// ``Markdown`` views call this method to load images within a line of text.
  ///
  /// - Parameters:
  ///   - url: The URL of the image to display.
  ///   - label: The accessibility label associated with the image.
  associatedtype Body: View
    
  func image(with url: URL, label: String) async throws -> Body
}

struct AnyInlineImageProvider: InlineImageProvider {
  private let _makeImage: (URL, String) async throws-> AnyView

  init<I: InlineImageProvider>(_ imageProvider: I) {
    self._makeImage = {
        try await AnyView(imageProvider.image(with: $0, label: $1))
    }
  }
    func image(with url: URL, label: String) async throws -> some View {
        try await self._makeImage(url, label)
    }
}
