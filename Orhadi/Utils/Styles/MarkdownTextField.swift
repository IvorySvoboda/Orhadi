//
//  MarkdownTextView.swift
//  Orhadi
//
//  Created by Zyvoxi . on 26/03/25.
//

import SwiftUI

struct MarkdownTextField: UIViewRepresentable {

    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = true
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.autocorrectionType = .no

        // MARK: - Toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let accentColor = UIColor(.indigo)

        let bold = UIBarButtonItem(image: UIImage(systemName: "bold"), style: .plain, target: context.coordinator, action: #selector(Coordinator.boldTapped))
        bold.tintColor = accentColor

        let italic = UIBarButtonItem(image: UIImage(systemName: "italic"), style: .plain, target: context.coordinator, action: #selector(Coordinator.italicTapped))
        italic.tintColor = accentColor

        let strikethrough = UIBarButtonItem(image: UIImage(systemName: "strikethrough"), style: .plain, target: context.coordinator, action: #selector(Coordinator.strikethroughTapped))
        strikethrough.tintColor = accentColor

        let title = UIBarButtonItem(image: UIImage(systemName: "textformat.size"), style: .plain, target: context.coordinator, action: #selector(Coordinator.titleTapped))
        title.tintColor = accentColor

        let list = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: context.coordinator, action: #selector(Coordinator.listTapped))
        list.tintColor = accentColor

        let code = UIBarButtonItem(image: UIImage(systemName: "highlighter"), style: .plain, target: context.coordinator, action: #selector(Coordinator.codeTapped))
        code.tintColor = accentColor

        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [bold, space, italic, space, strikethrough, space, title, space, list, space, code]

        textView.inputAccessoryView = toolbar

        context.coordinator.textView = textView
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MarkdownTextField
        weak var textView: UITextView?

        init(_ parent: MarkdownTextField) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        // MARK: - Ações da Toolbar

        @objc func boldTapped()             { applyWrapping("**") }
        @objc func italicTapped()           { applyWrapping("*") }
        @objc func strikethroughTapped()    { applyWrapping("~~") }
        @objc func codeTapped()             { applyWrapping("`") }
        @objc func titleTapped()            { applyPrefix("# ") }
        @objc func listTapped()             { applyPrefix("- ") }

        // MARK: - Aplicar Markdown

        private func applyWrapping(_ marker: String) {
            guard let textView = textView else { return }
            let selectedRange = textView.selectedRange
            guard let range = selectedRange.toRange(in: parent.text) else { return }

            let selectedText = parent.text[range]
            let wrapped = "\(marker)\(selectedText)\(marker)"
            parent.text.replaceSubrange(range, with: wrapped)

            textView.text = parent.text
            let cursor = selectedRange.location + marker.count
            textView.selectedRange = NSRange(location: cursor + selectedText.count, length: 0)
        }

        private func applyPrefix(_ prefix: String) {
            guard let textView = textView else { return }

            let selectedRange = textView.selectedRange

            let nsText = parent.text as NSString

            let currentLineRange = nsText.lineRange(for: selectedRange)
            let currentLine = nsText.substring(with: currentLineRange)

            if currentLine.trimmingCharacters(in: .whitespaces).hasPrefix(prefix) {
                return
            }

            let newLine = prefix + currentLine
            parent.text.replaceSubrange(currentLineRange.toRange(in: parent.text)!, with: newLine)

            textView.text = parent.text

            let offset = prefix.count
            textView.selectedRange = NSRange(location: selectedRange.location + offset, length: 0)
        }

        private func applyMarkdown(_ marker: String, to textView: UITextView, range: NSRange) {
            guard let textRange = range.toRange(in: parent.text) else { return }
            let selectedText = parent.text[textRange]
            let formatted = "\(marker)\(selectedText)\(marker)"
            parent.text.replaceSubrange(textRange, with: formatted)
            textView.text = parent.text
        }
    }
}
