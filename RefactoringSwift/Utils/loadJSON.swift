//
//  loadJson.swift
//  RefactoringSwift
//
//  Created by 주동석 on 7/8/24.
//

import Foundation

// JSON 파일에서 데이터를 읽고 파싱하는 함수
func loadJSON(filename: String) -> [String: Any]? {
    guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
        print(Bundle.main)
        print("JSON 파일을 찾을 수 없습니다.")
        return nil
    }
    
    do {
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        return json as? [String: Any]
    } catch {
        print("JSON 파싱 오류: \(error.localizedDescription)")
        return nil
    }
}
