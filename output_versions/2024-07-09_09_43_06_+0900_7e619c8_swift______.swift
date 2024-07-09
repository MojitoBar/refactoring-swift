import Foundation

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
        let play = plays[perf.playID]!
        var thisAmount = 0
        
        switch play.type {
        case "tragedy": // 비극
            thisAmount = 40000
            if perf.audience > 30 {
                thisAmount += 1000 * (perf.audience - 30)
            }
        case "comedy": // 희극
            thisAmount = 30000
            if perf.audience > 20 {
                thisAmount += 10000 + 500 * (perf.audience - 20)
            }
            thisAmount += 300 * perf.audience
        default:
            fatalError("알 수 없는 장르: \(play.type)")
        }
        
        // 포인트를 적립한다.
        volumeCredits += max(perf.audience - 30, 0)
        // 희극 관객 5명마다 추가 포인트를 제공한다.
        if play.type == "comedy" {
            volumeCredits += perf.audience / 5
        }
        
        // 청구 내역을 출력한다.
        result += "\(play.name): \(format(thisAmount)) (\(perf.audience)석)\n"
        totalAmount += thisAmount
    }
    
    result += "총액: \(format(totalAmount))\n"
    result += "적립 포인트: \(volumeCredits)점\n"
    return result
}

