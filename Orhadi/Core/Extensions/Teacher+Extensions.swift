//
//  Teacher+Extensions.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 28/04/25.
//

import SwiftUI

extension Teacher {
    func openMail() {
        guard let url = URL(string: "mailto:\(self.email)") else { return }
        UIApplication.shared.open(url)
    }
}
