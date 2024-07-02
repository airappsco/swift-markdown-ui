import Foundation

extension Sequence where Element == InlineNode {
  func rewrite(_ r: (InlineNode) throws -> [InlineNode]) rethrows -> [InlineNode] {
    try self.flatMap { try $0.rewrite(r) }
  }
}

extension InlineNode {
  func rewrite(_ r: (InlineNode) throws -> [InlineNode]) rethrows -> [InlineNode] {
    var inline = self
    return try r(inline)
  }
}
