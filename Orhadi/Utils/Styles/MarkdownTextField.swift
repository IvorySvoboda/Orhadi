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

        init(_ parent: MarkdownTextField) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        func textView(
            _ textView: UITextView,
            editMenuForTextIn range: NSRange,
            suggestedActions: [UIMenuElement]
        ) -> UIMenu? {

            let boldAction = UIAction(title: "Negrito") { _ in
                self.applyMarkdown("**", to: textView, range: range)
            }

            let italicAction = UIAction(title: "Itálico") { _ in
                self.applyMarkdown("*", to: textView, range: range)
            }

            let strikethroughAction = UIAction(title: "Tachado") { _ in
                self.applyMarkdown("~~", to: textView, range: range)
            }

            return UIMenu(
                title: "Formatar",
                children: [
                    boldAction,
                    italicAction,
                    strikethroughAction,
                ] + suggestedActions
            )
        }

        private func applyMarkdown(
            _ marker: String,
            to textView: UITextView,
            range: NSRange
        ) {
            guard let textRange = range.toRange(in: parent.text) else { return }
            let selectedText = parent.text[textRange]

            let formattedText = "\(marker)\(selectedText)\(marker)"
            parent.text.replaceSubrange(textRange, with: formattedText)

            textView.text = parent.text
        }
    }
}
