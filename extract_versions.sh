#!/bin/bash

FILE_PATH="RefactoringSwift/Theater/TheaterMain.swift"
OUTPUT_DIR="output_versions"

# 출력 디렉토리 생성
mkdir -p "$OUTPUT_DIR"

# 커밋 목록을 오래된 순서부터 가져오기
git log --reverse --pretty=format:"%H" -- "$FILE_PATH" | while read commit
do
    # 커밋 날짜 가져오기
    date=$(git show -s --format=%ci $commit)
    # 날짜에서 공백을 언더스코어로 변경
    formatted_date=$(echo $date | sed 's/[: ]/_/g')
    
    # 커밋 메시지 가져오기
    commit_msg=$(git log --format=%B -n 1 $commit | sed -e 's/[^A-Za-z0-9._-]/_/g' | head -c 50)
    
    # 파일 내용 추출 및 저장
    git show $commit:"$FILE_PATH" > "$OUTPUT_DIR/${formatted_date}_${commit:0:7}_${commit_msg}.txt"
done

echo "모든 버전이 $OUTPUT_DIR 디렉토리에 저장되었습니다."
