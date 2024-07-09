import Foundation
// MARK: - Statement
func usd(_ number: Int) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    numberFormatter.locale = Locale(identifier: "en_US")
    numberFormatter.minimumFractionDigits = 2
    return numberFormatter.string(from: NSNumber(value: Double(number) / 100.0)) ?? ""
}

func statement(invoice: Invoice, plays: [String: Play]) -> String {
    return renderPlainText(data: createStatementData(invoice: invoice, plays: plays))
}

func renderPlainText(data: StatementData) -> String {
    var result = "청구 내역 (고객명: \(data.customer))\n"
    for perf in data.performances {
        result += "\(perf.play!.name): \(usd(perf.amount!)) (\(perf.audience)석)\n"
    }
    result += "총액: \(usd(data.totalAmount!))\n"
    result += "적립 포인트: \(data.totalVolumeCredits!)점\n"
    return result
}

func htmlStatement(invoice: Invoice, plays: [String: Play]) -> String {
    return renderHtml(data: createStatementData(invoice: invoice, plays: plays))
}

func renderHtml(data: StatementData) -> String {
    var result = "<h1>청구 내역 (고객명: \(data.customer))</h1>\n"
    result += "<table>\n"
    result += "<tr><th>연극</th><th>좌석 수</th><th>금액</th></tr>\n"
    
    for perf in data.performances {
        result += "<tr><td>\(perf.play!.name)</td><td>\(perf.audience)석</td>"
        result += "<td>$\(usd(perf.amount!))</td></tr>\n"
    }
    
    result += "</table>\n"
    result += "<p>총액: <em>$\(usd(data.totalAmount!))</em></p>\n"
    result += "<p>적립 포인트: <em>\(data.totalVolumeCredits!)</em></p>\n"
    
    return result
}

// MARK: - CreateStatementData
func createStatementData(invoice: Invoice, plays: [String: Play]) -> StatementData {
    var statementData: StatementData = StatementData()
    statementData.customer = invoice.customer
    statementData.performances = invoice.performances.map(enrichPerformance(aPerformance:))
    statementData.totalAmount = totalAmount(data: statementData)
    statementData.totalVolumeCredits = totalVolumeCredits(data: statementData)
    return statementData
    
    
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
        return data.performances.reduce(0) { $0 + ($1.volumeCredits ?? 0) }
    }
    
    func totalAmount(data: StatementData) -> Int {
        return data.performances.reduce(0) { $0 + ($1.amount ?? 0) }
    }
}
