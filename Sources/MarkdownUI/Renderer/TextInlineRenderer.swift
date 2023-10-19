import SwiftUI

extension Sequence where Element == InlineNode {
    func renderText<Content: View>(
    baseURL: URL?,
    textStyles: InlineTextStyles,
    images: [String: Content],
    attributes: AttributeContainer
  ) -> some View {
    var renderer = TextInlineRenderer(
      baseURL: baseURL,
      textStyles: textStyles,
      images: images,
      attributes: attributes
    )
    renderer.render(self)
    return renderer.list
  }
}

private struct TextInlineRenderer<Content: View> {
  var result = Text("")
    lazy var list = VStack(alignment: .leading) {
    ForEach(results) {
        $0.content
    }
  }
  private var results: [InlinerResult] = [.init(source: nil, content: AnyView(Text("")))]
  private let baseURL: URL?
  private let textStyles: InlineTextStyles
  private let images: [String: Content]
  private let attributes: AttributeContainer
  private var shouldSkipNextWhitespace = false

  init(
    baseURL: URL?,
    textStyles: InlineTextStyles,
    images: [String: Content],
    attributes: AttributeContainer
  ) {
    self.baseURL = baseURL
    self.textStyles = textStyles
    self.images = images
    self.attributes = attributes
  }

  mutating func render<S: Sequence>(_ inlines: S) where S.Element == InlineNode {
    for inline in inlines {
      self.render(inline)
    }
  }

  private mutating func render(_ inline: InlineNode) {
    switch inline {
    case .text(let content):
      self.renderText(content)
    case .softBreak:
      self.renderSoftBreak()
    case .html(let content):
      self.renderHTML(content)
    case .image(let source, _):
      self.renderImage(source)
    default:
      self.defaultRender(inline)
    }
  }

  private mutating func renderText(_ text: String) {
    var text = text

    if self.shouldSkipNextWhitespace {
      self.shouldSkipNextWhitespace = false
      text = text.replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)
    }

    self.defaultRender(.text(text))
  }

  private mutating func renderSoftBreak() {
    if self.shouldSkipNextWhitespace {
      self.shouldSkipNextWhitespace = false
    } else {
      self.defaultRender(.softBreak)
    }
  }

  private mutating func renderHTML(_ html: String) {
    let tag = HTMLTag(html)

    switch tag?.name.lowercased() {
    case "br":
      self.defaultRender(.lineBreak)
      self.shouldSkipNextWhitespace = true
    default:
      self.defaultRender(.html(html))
    }
  }

  private mutating func renderImage(_ source: String) {
     
    if let image = self.images[source] {
        let resultImage = image
        self.results.append(InlinerResult(source: source, content: AnyView(resultImage)))
        self.result = Text("")
        self.results.append(InlinerResult(source: nil, content: AnyView(Text(""))))
    }
  }

  private mutating func defaultRender(_ inline: InlineNode) {
    self.result =
      self.result
      + Text(
        inline.renderAttributedString(
          baseURL: self.baseURL,
          textStyles: self.textStyles,
          attributes: self.attributes
        )
      )
      
      results[results.count - 1].changeContent(to: AnyView(result))
  }
}

struct InlinerResult: Identifiable {
    let id = UUID().uuidString
    let source: String?
    var content: AnyView
    
    mutating func changeContent(to content: AnyView) {
        self.content = AnyView(content.frame(maxWidth: .infinity, alignment: .leading))
    }
}
