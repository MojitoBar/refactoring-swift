import Foundation

struct Performance: Codable {
    let playID: String
    let audience: Int
    var play: Play?
}

struct Invoice: Codable {
    let customer: String
    let performances: [Performance]
}

struct Play: Codable {
    let name: String
    let type: String
}

// 전체 데이터 구조를 위한 타입
struct TheaterData: Codable {
    let plays: [String: Play]
    let invoices: [Invoice]
}

struct StatementData {
    var customer: String
    var performances: [Performance]
    
    init(customer: String = "", performances: [Performance] = []) {
        self.customer = customer
        self.performances = performances
    }
}

// JSON 데이터를 파싱하는 함수
func parseTheaterData(playsJSON: String, invoicesJSON: String) -> TheaterData? {
    let jsonDecoder = JSONDecoder()
    
    guard let playsData = playsJSON.data(using: .utf8),
          let invoicesData = invoicesJSON.data(using: .utf8),
          let plays = try? jsonDecoder.decode([String: Play].self, from: playsData),
          let invoices = try? jsonDecoder.decode([Invoice].self, from: invoicesData) else {
        return nil
    }
    
    return TheaterData(plays: plays, invoices: invoices)
}

let playsJSON = """
{
    "hamlet": {"name": "Hamlet", "type": "tragedy"},
    "as-like": {"name": "As You Like It", "type": "comedy"},
    "othello": {"name": "Othello", "type": "tragedy"}
}
"""

let invoicesJSON = """
[
    {
        "customer": "BigCo",
        "performances": [
            {
                "playID": "hamlet",
                "audience": 55
            },
            {
                "playID": "as-like",
                "audience": 35
            },
            {
                "playID": "othello",
                "audience": 40
            }
        ]
    }
]
"""
