import Foundation

func statement(invoice: Invoice, plays: [String: Play]) -> String {
    var statementData: StatementData = StatementData()
    statementData.customer = invoice.customer
    return renderPlainText(data: statementData, invoice: invoice, plays: plays)
}

func renderPlainText(data: StatementData, invoice: Invoice, plays: [String: Play]) -> String {
    var result = "청구 내역 (고객명: \(data.customer))\n"
    for perf in invoice.performances {
        result += "\(playFor(perf).name): \(usd(amountFor(perf))) (\(perf.audience)석)\n"
    }
    result += "총액: \(usd(totalAmount()))\n"
    result += "적립 포인트: \(totalVolumeCredits())점\n"
    return result
    
    func usd(_ number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.minimumFractionDigits = 2
        return numberFormatter.string(from: NSNumber(value: Double(number) / 100.0)) ?? ""
    }
    
    func amountFor(_ aPerformance: Performance) -> Int {
        var result = 0
        switch playFor(aPerformance).type {
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
            fatalError("알 수 없는 장르: \(playFor(aPerformance).type)")
        }
        return result
    }
    
    func playFor(_ aPerformance: Performance) -> Play{
        return plays[aPerformance.playID]!
    }
    
    func volumCreditsFor(_ aPerformance: Performance) -> Int {
        var result = 0
        result += max(aPerformance.audience - 30, 0)
        if playFor(aPerformance).type == "comedy" {
            result += aPerformance.audience / 5
        }
        return result
    }
    
    func totalVolumeCredits() -> Int {
        var result = 0
        for perf in invoice.performances {
            result += volumCreditsFor(perf)
        }
        return result
    }
    
    func totalAmount() -> Int {
        var result = 0
        for perf in invoice.performances {
            result += amountFor(perf)
        }
        return result
    }
}
