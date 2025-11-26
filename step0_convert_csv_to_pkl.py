# -*- coding: utf-8 -*-
"""
Step 0: 원시 CSV 데이터를 Pickle 형식으로 변환

목적:
- CSV (47MB) → PKL (135MB) 변환
- 빠른 로딩 속도를 위해 pickle 형식으로 저장
- 데이터 타입 정보 보존

입력: Data/2023년 제7차 근로환경조사 원시자료.csv
출력: Data/kwcs_full.pkl
"""

import pandas as pd
import os
import time
from datetime import datetime

print("=" * 100)
print(" " * 30 + "CSV → PKL 변환 스크립트")
print("=" * 100)
print(f"\n실행 시작: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

# 파일 경로
INPUT_CSV = "Data/2023년 제7차 근로환경조사 원시자료.csv"
OUTPUT_PKL = "Data/kwcs_full.pkl"

# Step 1: 원시 CSV 파일 존재 확인
print("[1] 원시 데이터 파일 확인")
print("-" * 100)

if not os.path.exists(INPUT_CSV):
    print(f"❌ 오류: {INPUT_CSV} 파일이 존재하지 않습니다.")
    print("\n다음 파일이 필요합니다:")
    print("  - Data/2023년 제7차 근로환경조사 원시자료.csv")
    print("\n출처: 산업안전보건연구원 (KWCS 제7차, 2023)")
    exit(1)

file_size_mb = os.path.getsize(INPUT_CSV) / (1024 * 1024)
print(f"✓ 원시 데이터 파일 확인: {INPUT_CSV}")
print(f"✓ 파일 크기: {file_size_mb:.1f} MB")

# Step 2: CSV 파일 로드
print("\n[2] CSV 파일 로드 중...")
print("-" * 100)
start_time = time.time()

try:
    # 인코딩: cp949 (한국어 Windows 기본 인코딩)
    df = pd.read_csv(INPUT_CSV, encoding='cp949', low_memory=False)
    load_time = time.time() - start_time

    print(f"✓ 로딩 완료 (소요 시간: {load_time:.1f}초)")
    print(f"✓ 데이터 크기: N = {len(df):,}행 × {len(df.columns):,}열")

except Exception as e:
    print(f" CSV 로딩 실패: {e}")
    print("\n다른 인코딩을 시도해보세요:")
    print("  - encoding='utf-8'")
    print("  - encoding='euc-kr'")
    exit(1)

# Step 3: 기본 정보 확인
print("\n[3] 데이터 기본 정보")
print("-" * 100)
print(f"행 수 (표본 크기): {len(df):,}명")
print(f"열 수 (변수 개수): {len(df.columns):,}개")
print(f"결측치 비율: {df.isnull().sum().sum() / (len(df) * len(df.columns)) * 100:.2f}%")

print("\n처음 5개 열:")
print(df.columns.tolist()[:5])

print("\n데이터 미리보기:")
print(df.head(3).to_string())

# Step 4: PKL 형식으로 저장
print("\n[4] PKL 형식으로 저장 중...")
print("-" * 100)
start_time = time.time()

try:
    df.to_pickle(OUTPUT_PKL)
    save_time = time.time() - start_time

    pkl_size_mb = os.path.getsize(OUTPUT_PKL) / (1024 * 1024)

    print(f"✓ 저장 완료: {OUTPUT_PKL}")
    print(f"✓ 파일 크기: {pkl_size_mb:.1f} MB")
    print(f"✓ 소요 시간: {save_time:.1f}초")

except Exception as e:
    print(f" PKL 저장 실패: {e}")
    exit(1)

# Step 5: 저장된 파일 검증
print("\n[5] 저장된 PKL 파일 검증")
print("-" * 100)
start_time = time.time()

try:
    df_test = pd.read_pickle(OUTPUT_PKL)
    load_pkl_time = time.time() - start_time

    print(f"✓ PKL 파일 로딩 성공")
    print(f"✓ PKL 로딩 시간: {load_pkl_time:.1f}초")
    print(f"✓ 데이터 무결성 확인: N = {len(df_test):,}행 × {len(df_test.columns):,}열")

    # CSV vs PKL 속도 비교
    speed_improvement = load_time / load_pkl_time
    print(f"\n⚡ 속도 향상: CSV 대비 {speed_improvement:.1f}배 빠름")
    print(f"   - CSV 로딩 시간: {load_time:.1f}초")
    print(f"   - PKL 로딩 시간: {load_pkl_time:.1f}초")

except Exception as e:
    print(f" PKL 파일 검증 실패: {e}")
    exit(1)

# 완료 메시지
print("\n" + "=" * 100)
print(" " * 35 + "변환 완료!")
print("=" * 100)
print(f"\n✓ 원본 CSV: {INPUT_CSV} ({file_size_mb:.1f} MB)")
print(f"✓ 변환된 PKL: {OUTPUT_PKL} ({pkl_size_mb:.1f} MB)")
print(f"\n다음 단계: step1_preprocessing_full_sample.py 실행")
print("=" * 100)
print(f"\n실행 종료: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
