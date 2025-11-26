# -*- coding: utf-8 -*-
"""
전체 표본 분석 - 새로운 연구 모형
독립변수: 심리적 위험 (Psychological Hazards) - 7점 척도
종속변수: 건강 문제 (Health Problems) - 2점 척도 (1=예, 2=아니오)
조절변수: 업무몰입 (Work Engagement) - 5점 척도

KWCS 코딩 규칙:
- 8 = 모름
- 9 = 무응답/해당없음
→ 8, 9는 결측으로 처리
"""

import pandas as pd
import numpy as np
from scipy import stats
import warnings
warnings.filterwarnings('ignore')

print("=" * 100)
print(" " * 25 + "전체 표본 분석: 심리적 위험 → 건강 문제")
print("=" * 100)

# 데이터 로드
print("\n[1] 데이터 로드")
# 상대 경로 사용 (Final_result 디렉토리 기준)
df = pd.read_pickle("Data/kwcs_full.pkl")
print(f"✓ 전체 표본: N = {len(df):,}명")

# [1-1] 8, 9 값을 결측으로 처리 (KWCS 코딩 규칙)
print("\n[1-1] 8, 9 값 결측 처리 (모름/무응답)")
print("-" * 100)

psy_hazard_vars = ['hazard_psy1', 'hazard_psy2', 'hazard_psy3']
health_prob_vars = ['heal_prob1', 'heal_prob2', 'heal_prob3']
engagement_vars = ['weng1', 'weng2', 'weng3']

all_scale_vars = psy_hazard_vars + health_prob_vars + engagement_vars

for col in all_scale_vars:
    n_before = df[col].notna().sum()
    df[col] = df[col].replace([8, 9], np.nan)
    n_after = df[col].notna().sum()
    if n_before != n_after:
        print(f"  {col}: {n_before - n_after:,}개 결측 처리 (8, 9 값)")

print("✓ 결측 처리 완료")
print()
print("처리 후 척도 범위:")
print(f"  심리적 위험: 1~7 (7점 척도)")
print(f"  건강 문제: 1~2 (2점 척도, 1=예/2=아니오)")
print(f"  업무몰입: 1~5 (5점 척도)")

# Cronbach's Alpha 계산 함수
def cronbach_alpha(df, columns):
    """Cronbach's Alpha 계산"""
    df_numeric = df[columns].copy()
    for col in columns:
        df_numeric[col] = pd.to_numeric(df_numeric[col], errors='coerce')

    df_items = df_numeric.dropna()
    if len(df_items) < 10:
        return None, 0, len(df_items)

    item_vars = df_items.var(axis=0, ddof=1)
    total_var = df_items.sum(axis=1).var(ddof=1)
    n_items = len(columns)

    if total_var == 0:
        return None, 0, len(df_items)

    alpha = (n_items / (n_items - 1)) * (1 - item_vars.sum() / total_var)

    corr_matrix = df_items.corr()
    n = len(columns)
    if n > 1:
        mean_corr = (corr_matrix.sum().sum() - n) / (n * (n - 1))
    else:
        mean_corr = 0

    return alpha, mean_corr, len(df_items)

# 변수 정의 (이미 위에서 정의됨)
# psy_hazard_vars, health_prob_vars, engagement_vars

print("\n[2] 변수 구성 및 신뢰도 확인")
print("-" * 100)

# 심리적 위험 (독립변수)
alpha_psy, corr_psy, n_psy = cronbach_alpha(df, psy_hazard_vars)
print(f"심리적 위험 (Psychological Hazards):")
print(f"  - 문항: hazard_psy1, hazard_psy2, hazard_psy3")
print(f"  - N = {n_psy:,}명")
print(f"  - Cronbach's α = {alpha_psy:.3f}")
print(f"  - 평균 상관 = {corr_psy:.3f}")

# 건강 문제 (종속변수)
alpha_health, corr_health, n_health = cronbach_alpha(df, health_prob_vars)
print(f"\n건강 문제 (Health Problems):")
print(f"  - 문항: heal_prob1, heal_prob2, heal_prob3")
print(f"  - N = {n_health:,}명")
print(f"  - Cronbach's α = {alpha_health:.3f}")
print(f"  - 평균 상관 = {corr_health:.3f}")

# 업무몰입 (조절변수)
alpha_eng, corr_eng, n_eng = cronbach_alpha(df, engagement_vars)
print(f"\n업무몰입 (Work Engagement):")
print(f"  - 문항: weng1, weng2, weng3")
print(f"  - N = {n_eng:,}명")
print(f"  - Cronbach's α = {alpha_eng:.3f}")
print(f"  - 평균 상관 = {corr_eng:.3f}")

# 데이터 전처리
print("\n[3] 데이터 전처리")
print("-" * 100)

# 모든 변수를 숫자로 변환
all_vars = psy_hazard_vars + health_prob_vars + engagement_vars + ['gender', 'age', 'edu', 'emp_type']

df_clean = df[all_vars].copy()
for col in all_vars:
    df_clean[col] = pd.to_numeric(df_clean[col], errors='coerce')

# 결측치 제거
df_clean = df_clean.dropna()
print(f"✓ 완전 응답자: N = {len(df_clean):,}명 (전체의 {len(df_clean)/len(df)*100:.1f}%)")

# 복합변수 생성 (평균)
df_clean['PsychologicalHazards'] = df_clean[psy_hazard_vars].mean(axis=1)
df_clean['HealthProblems'] = df_clean[health_prob_vars].mean(axis=1)
df_clean['WorkEngagement'] = df_clean[engagement_vars].mean(axis=1)

# 통제변수
df_clean['Gender'] = df_clean['gender']  # 1=남성, 2=여성
df_clean['Age'] = df_clean['age']
df_clean['Education'] = df_clean['edu']
df_clean['EmpType'] = df_clean['emp_type']

# 평균중심화 (다중공선성 방지)
df_clean['PH_centered'] = df_clean['PsychologicalHazards'] - df_clean['PsychologicalHazards'].mean()
df_clean['WE_centered'] = df_clean['WorkEngagement'] - df_clean['WorkEngagement'].mean()
df_clean['PH_x_WE'] = df_clean['PH_centered'] * df_clean['WE_centered']

print(f"✓ 심리적 위험 평균중심화 완료 (mean = {df_clean['PsychologicalHazards'].mean():.3f})")
print(f"✓ 업무몰입 평균중심화 완료 (mean = {df_clean['WorkEngagement'].mean():.3f})")
print(f"✓ 상호작용항 생성 완료")

# 기술통계
print("\n[4] 기술통계")
print("-" * 100)
desc_vars = ['PsychologicalHazards', 'HealthProblems', 'WorkEngagement', 'Gender', 'Age', 'Education', 'EmpType']
desc = df_clean[desc_vars].describe()
print(desc.round(3).to_string())

# 상관분석
print("\n[5] 상관분석")
print("-" * 100)
corr_matrix = df_clean[desc_vars].corr()
print(corr_matrix.round(3).to_string())

# 분석용 데이터 저장
print("\n[6] 분석용 데이터 저장")
print("-" * 100)

output_vars = ['HealthProblems', 'PsychologicalHazards', 'WorkEngagement',
               'PH_centered', 'WE_centered', 'PH_x_WE',
               'Gender', 'Age', 'Education', 'EmpType']
df_output = df_clean[output_vars].copy()

df_output.to_csv('data_for_r_analysis_FULL_SAMPLE.csv', index=False, encoding='utf-8-sig')
print(f"✓ 저장 완료: data_for_r_analysis_FULL_SAMPLE.csv (N={len(df_output):,}명)")

# 신뢰도 결과 저장
reliability_df = pd.DataFrame({
    'Scale': ['PsychologicalHazards', 'HealthProblems', 'WorkEngagement'],
    'Cronbach_Alpha': [alpha_psy, alpha_health, alpha_eng],
    'Mean_Inter_Item_Corr': [corr_psy, corr_health, corr_eng],
    'N_Items': [3, 3, 3],
    'N_Valid': [n_psy, n_health, n_eng],
    'Items': [
        ', '.join(psy_hazard_vars),
        ', '.join(health_prob_vars),
        ', '.join(engagement_vars)
    ]
})
reliability_df.to_csv('reliability_results_FULL_SAMPLE.csv', index=False, encoding='utf-8-sig')
print(f"✓ 신뢰도 결과 저장: reliability_results_FULL_SAMPLE.csv")

print("\n" + "=" * 100)
print(" " * 35 + "전처리 완료!")
print("=" * 100)
print(f"\n최종 표본: N = {len(df_output):,}명")
print(f"심리적 위험 α = {alpha_psy:.3f}")
print(f"건강 문제 α = {alpha_health:.3f}")
print(f"업무몰입 α = {alpha_eng:.3f}")
print("\n다음 단계: R로 위계적 회귀분석 수행")
print("=" * 100)