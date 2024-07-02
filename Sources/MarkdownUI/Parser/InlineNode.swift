import Foundation

enum InlineNode: Hashable {
    case text(String)
    case softBreak
    case lineBreak
    case code(String)
    case html(String)
    case emphasis([InlineNode])
    case strong([InlineNode])
    case strikethrough([InlineNode])
    case link(destination: String, [InlineNode])
    case image(source: String, [InlineNode])
}

extension InlineNode {
    var children: [InlineNode] {
        get {
            switch self {
            case .emphasis(let children),
                 .strong(let children),
                 .strikethrough(let children),
                 .link(_, let children),
                 .image(_, let children):
                return children
            default:
                return []
            }
        }
    }
    
    func withChildren(_ newValue: [InlineNode]) -> InlineNode {
        switch self {
        case .emphasis:
            return .emphasis(newValue)
        case .strong:
            return .strong(newValue)
        case .strikethrough:
            return .strikethrough(newValue)
        case .link(let destination, _):
            return .link(destination: destination, newValue)
        case .image(let source, _):
            return .image(source: source, newValue)
        default:
            return self
        }
    }
}
