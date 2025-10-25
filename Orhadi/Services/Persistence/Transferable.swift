//
//  Transferable.swift
//  Orhadi
//
//  Created by Ivory Svoboda on 14/04/25.
//

import Foundation
import CoreTransferable

struct DataTransferable: Transferable {
    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .data) { transferable in
            transferable.data
        }
    }
}
