import Foundation

func statement(invoice: Invoice, plays: [String: Play]) -> String {
    var totalAmount = 0
    var volumeCredits = 0
    var result = "청구 내역 (고객명: \(invoice.customer))\n"
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    numberFormatter.locale = Locale(identifier: "en_US")
    numberFormatter.minimumFractionDigits = 2
    
    func format(_ number: Int) -> String {
        return numberFormatter.string(from: NSNumber(value: Double(number) / 100.0)) ?? ""
    }
    
    for perf in invoice.performances {
        guard let play = plays[perf.playID] else {
            fatalError("플레이를 찾을 수 없습니다: \(perf.playID)")
        }
        
        // 포인트를 적립한다.
        volumeCredits += max(perf.audience - 30, 0)
        // 희극 관객 5명마다 추가 포인트를 제공한다.
        if play.type == "comedy" {
            volumeCredits += perf.audience / 5
        }
        
        // 청구 내역을 출력한다.
        result += "\(play.name): \(format(amountFor(play, perf))) (\(perf.audience)석)\n"
        totalAmount += amountFor(play, perf)
    }
    
    result += "총액: \(format(totalAmount))\n"
    result += "적립 포인트: \(volumeCredits)점\n"
    return result
}

func amountFor(_ play: Play, _ aPerformance: Performance) -> Int {
    var result = 0
    
    switch play.type {
    case "tragedy": // 비극
        result = 40000
        if aPerformance.audience > 30 {
            result += 1000 * (aPerformance.audience - 30)
        }
    case "comedy": // 희극
        result = 30000
        if aPerformance.audience > 20 {
            result += 10000 + 500 * (aPerformance.audience - 20)
        }
        result += 300 * aPerformance.audience
    default:
        fatalError("알 수 없는 장르: \(play.type)")
    }
    
    return result
}
