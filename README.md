# The Impact of Psychological Hazards on Worker Health: The Role of Work Engagement

**심리적 위험이 근로자 건강에 미치는 영향: 업무몰입의 역할**

충북대학교 경영정보학과 졸업논문 (2025)

---

## Overview

본 연구는 한국근로환경조사(KWCS) 2023년 데이터(N=49,897)를 활용하여 직장 내 심리적 위험이 근로자 건강에 미치는 영향과 업무몰입의 조절효과를 분석하였다.

### Research Model

```
심리적 위험(Psychological Hazards) → 건강 문제(Health Problems)
                    ↑
            업무몰입(Work Engagement) [조절변수]
```

### Key Findings

| 가설 | 결과 | 통계량 |
|------|------|--------|
| H1: 심리적 위험 → 건강 문제 (+) | 지지 | B = .009, p < .001 |
| H2: 업무몰입의 조절효과 | 지지 | B = -.011, p < .001 |

- 심리적 부담이 클수록 건강 문제 호소 빈도 증가
- 업무몰입이 높은 근로자는 심리적 부담의 부정적 영향을 덜 받음

---

## Repository Structure

```
├── 경영정보_졸업논문(이시우-2013026033).hwpx  # 최종 논문
├── Data/
│   └── kwcs_full.pkl                          # KWCS 원본 데이터
├── step0_convert_csv_to_pkl.py                # CSV→PKL 변환
├── step1_preprocessing_full_sample.py         # 데이터 전처리
├── step2_r_analysis_FULL_SAMPLE.R             # 위계적 회귀분석
├── data_for_r_analysis_FULL_SAMPLE.csv        # 분석용 데이터
├── reliability_results_FULL_SAMPLE.csv        # 신뢰도 결과
├── model_comparison_FULL_SAMPLE.csv           # 모형 비교
├── model4_coefficients_FULL_SAMPLE.csv        # 회귀계수
├── vif_results_FULL_SAMPLE.csv                # 다중공선성 진단
└── correlation_matrix_FULL_SAMPLE.csv         # 상관행렬
```

---

## Reproduction

### Requirements

- Python 3.11+
- R 4.5+

### Setup

```bash
# Python 패키지 설치
pip install -r requirements.txt

# 또는 직접 설치
pip install pandas numpy scipy
```

### Run Analysis

```bash
# Step 1: 데이터 전처리
python step1_preprocessing_full_sample.py

# Step 2: 위계적 회귀분석
Rscript step2_r_analysis_FULL_SAMPLE.R
```

### Expected Results

- Sample size: N = 49,897
- Cronbach's α: 심리적 위험(.666), 건강 문제(.777), 업무몰입(.819)
- All VIF < 10

---

## Theoretical Framework

본 연구는 **직무요구-자원 모형(Job Demands-Resources Model)**을 이론적 기반으로 한다.

---

## Author

이시우 (Lee Si-Woo)
충북대학교 경영대학 경영정보학과

