//
//  main.swift
//  RefactoringSwift
//
//  Created by 주동석 on 7/8/24.
//

import Foundation


if let theaterData = parseTheaterData(playsJSON: playsJSON, invoicesJSON: invoicesJSON) {
    print(statement(invoice: theaterData.invoices.first!, plays: theaterData.plays))
} else {
    print("Failed to parse data")
}

