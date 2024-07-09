import Foundation

func statement(invoice: Invoice, plays: [String: Play]) -> String {
    var statementData: StatementData = StatementData()
    statementData.customer = invoice.customer
    statementData.performances = invoice.performances.map(enrichPerformance(aPerformance:))
    statementData.totalAmount = totalAmount(data: statementData)
    statementData.totalVolumeCredits = totalVolumeCredits(data: statementData)
    return renderPlainText(data: statementData, plays: plays)
    
    func enrichPerformance(aPerformance: Performance) -> Performance {
        var result = aPerformance
        result.play = playFor(result)
        result.amount = amountFor(result)
        result.volumeCredits = volumCreditsFor(result)
        return result
    }
    
    func playFor(_ aPerformance: Performance) -> Play {
        return plays[aPerformance.playID]!
    }
    
    func amountFor(_ aPerformance: Performance) -> Int {
        var result = 0
        switch aPerformance.play!.type {
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
            fatalError("알 수 없는 장르: \(aPerformance.play!.type)")
        }
        return result
    }
    
    func volumCreditsFor(_ aPerformance: Performance) -> Int {
        var result = 0
        result += max(aPerformance.audience - 30, 0)
        if aPerformance.play!.type == "comedy" {
            result += aPerformance.audience / 5
        }
        return result
    }
    
    func totalVolumeCredits(data: StatementData) -> Int {
        var result = 0
        for perf in data.performances {
            result += perf.volumeCredits!
        }
        return result
    }
    
    func totalAmount(data: StatementData) -> Int {
        var result = 0
        for perf in data.performances {
            result += perf.amount!
        }
        return result
    }
}

func renderPlainText(data: StatementData, plays: [String: Play]) -> String {
    var result = "청구 내역 (고객명: \(data.customer))\n"
    for perf in data.performances {
        result += "\(perf.play!.name): \(usd(perf.amount!)) (\(perf.audience)석)\n"
    }
    result += "총액: \(usd(data.totalAmount!))\n"
    result += "적립 포인트: \(data.totalVolumeCredits!)점\n"
    return result
    
    func usd(_ number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.minimumFractionDigits = 2
        return numberFormatter.string(from: NSNumber(value: Double(number) / 100.0)) ?? ""
    }
}
