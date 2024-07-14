import Foundation

// MARK: - 팩터리 메서드
func createPerformanceCalculator(_ aPerformance: Performance, _ aPlay: Play) -> PerformanceCalculator {
    switch(aPlay.type) {
    case "tragedy":
        return TragedyCalculator(aPerformance, aPlay)
    case "comedy":
        return ComedyCalculator(aPerformance, aPlay)
    default:
        fatalError("알 수 없는 장르: \(aPlay.type)")
    }
}

// MARK: - 공연료 계산기
class PerformanceCalculator {
    var performance: Performance
    var play: Play
    init(_ aPerformance: Performance, _ aPlay: Play) {
        performance = aPerformance
        play = aPlay
    }
    
    func amount() -> Int {
        fatalError("서브클래스에서 처리하도록 설계")
    }
    
    func volumCredits() -> Int {
        var result = 0
        result += max(performance.audience - 30, 0)
        if play.type == "comedy" {
            result += performance.audience / 5
        }
        return result
    }
}

class TragedyCalculator: PerformanceCalculator {
    override func amount() -> Int {
        var result = 40000
        if performance.audience > 30 {
            result += 1000 * (performance.audience - 30)
        }
        return result
    }
}

class ComedyCalculator: PerformanceCalculator {
    override func amount() -> Int {
        var result = 30000
        if performance.audience > 20 {
            result += 10000 + 500 * (performance.audience - 20)
        }
        result += 300 * performance.audience
        return result
    }
}

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
        let calculator = createPerformanceCalculator(aPerformance, playFor(aPerformance))
        var result = aPerformance
        result.play = calculator.play
        result.amount = calculator.amount()
        result.volumeCredits = calculator.volumCredits()
        return result
    }
    
    func playFor(_ aPerformance: Performance) -> Play {
        return plays[aPerformance.playID]!
    }
    
    func totalVolumeCredits(data: StatementData) -> Int {
        return data.performances.reduce(0) { $0 + ($1.volumeCredits ?? 0) }
    }
    
    func totalAmount(data: StatementData) -> Int {
        return data.performances.reduce(0) { $0 + ($1.amount ?? 0) }
    }
}
