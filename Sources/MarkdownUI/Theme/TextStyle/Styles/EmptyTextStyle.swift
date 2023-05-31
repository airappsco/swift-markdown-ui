import Foundation

/// A text style that doesn't apply any text style.
@available(iOS 15, *)
public struct EmptyTextStyle: TextStyle {
  /// Creates an empty text style.
  public init() {}

  public func _collectAttributes(in: inout AttributeContainer) {}
}
