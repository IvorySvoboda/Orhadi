//
//  Markdown+Extensions.swift
//  Orhadi
//
//  Created by Zyvoxi . on 05/05/25.
//

import MarkdownUI
import SwiftUI

extension Markdown {
    func orhadiMarkdownStyle() -> some View {
        self
            .markdownBlockStyle(\.heading1) { configuration in
                VStack(alignment: .leading, spacing: 0) {
                    configuration.label
                        .relativePadding(.bottom, length: .em(0.1))
                        .markdownMargin(bottom: .em(0.5))
                        .markdownTextStyle {
                            FontWeight(.semibold)
                            FontSize(.em(1.5))
                        }
                    Divider()
                }
            }
            .markdownBlockStyle(\.heading2) { configuration in
                configuration.label
                    .relativePadding(.bottom, length: .em(0.1))
                    .markdownMargin(bottom: .em(0.5))
                    .markdownTextStyle {
                        FontWeight(.semibold)
                        FontSize(.em(1.3))
                    }
            }
            .markdownBlockStyle(\.heading3) { configuration in
                configuration.label
                    .relativePadding(.bottom, length: .em(0.1))
                    .markdownMargin(bottom: .em(0.5))
                    .markdownTextStyle {
                        FontWeight(.semibold)
                        FontSize(.em(1.1))
                    }
            }
            .markdownTextStyle(\.code) {
                FontFamilyVariant(.normal)
                ForegroundColor(Color.accentColor)
                BackgroundColor(Color.accentColor.opacity(0.25))
            }
            .markdownBlockStyle(\.blockquote) { configuration in
                configuration.label
                    .padding(5)
                    .markdownTextStyle {
                        BackgroundColor(nil)
                    }
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(Color.accentColor)
                            .frame(width: 4)
                    }
                    .background(Color.accentColor.opacity(0.25))
            }
    }
}
