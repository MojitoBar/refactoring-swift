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

/// 연극 장르와 공연료 정책이 달라질 때마다 statement() 함수를 수정해야 한다.
/// 게다가 정책이 복잡해질수록 수정할 부분을 찾기 어려워지고 수정 과정에서도 실수할 가능성도 커진다.
/// 리팩터링이 필요한 이유는 바로 이러한 변경 때문이다.
/// 잘 작동하고 나중에 변경할 일이 없다면 코드를 현재 상태로 놔둬도 아무런 문제가 없다.
///
/// 리팩터링의 첫 단계
/// 리팩터링할 코드 영역을 꼼꼼하게 검사해줄 테스트 코드들부터 마련해야 한다.
