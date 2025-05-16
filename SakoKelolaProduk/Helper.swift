//
//  Helper.swift
//  SakoKelolaProduk
//
//  Created by Callista on 12/05/25.
//

import Foundation

func formatInputHarga(_ input: String) -> String {
    let digitsOnly = input.filter { "0123456789".contains($0) }
    guard let number = Int(digitsOnly) else { return "" }

    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = "."
    formatter.locale = Locale(identifier: "id_ID")

    return formatter.string(from: NSNumber(value: number)) ?? ""
}
