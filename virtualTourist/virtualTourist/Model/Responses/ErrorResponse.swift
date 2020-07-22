//
//  ErrorResponse.swift
//  virtualTourist
//
//  Created by Oleh Titov on 22.07.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation

struct ErrorResponse: Codable {
    let stat: String
    let code: Int
    let message: String
}

extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
