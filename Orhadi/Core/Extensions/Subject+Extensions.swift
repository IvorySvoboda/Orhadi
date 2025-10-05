//
//  Subject+Extensions.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 28/04/25.
//

import SwiftUI

extension Subject {
    func openMail() {
        guard let encoded = self.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let email = self.teacher?.email,
              let url = URL(string: "mailto:\(email)?subject=\(encoded)") else { return }
        UIApplication.shared.open(url)
    }
}
