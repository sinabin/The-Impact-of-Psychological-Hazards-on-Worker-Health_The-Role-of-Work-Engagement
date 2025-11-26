# =============================================================================
# 전체 표본 위계적 회귀분석 (N=50,195)
# DV: 건강 문제 (Health Problems)
# IV: 심리적 위험 (Psychological Hazards)
# Moderator: 업무몰입 (Work Engagement)
# =============================================================================

# Working Directory 자동 설정
cat("\n=== Working Directory 확인 및 설정 ===\n")
current_wd <- getwd()
cat(sprintf("현재 작업 디렉토리: %s\n", current_wd))

# 방법 1: RStudio에서 스크립트 위치로 자동 설정 (권장)
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  if (nzchar(script_path)) {
    setwd(script_path)
    cat(sprintf("✓ 작업 디렉토리를 스크립트 위치로 변경: %s\n", getwd()))
  }
} else {
  # 방법 2: 명령줄 실행 시 (Rscript)
  args <- commandArgs(trailingOnly = FALSE)
  script_path <- dirname(sub("--file=", "", args[grep("--file=", args)]))
  if (length(script_path) > 0 && nzchar(script_path)) {
    setwd(script_path)
    cat(sprintf("✓ 작업 디렉토리를 스크립트 위치로 변경: %s\n", getwd()))
  }
}

# 데이터 파일 존재 확인
data_file <- "data_for_r_analysis_FULL_SAMPLE.csv"
if (!file.exists(data_file)) {
  cat("\n오류: 데이터 파일을 찾을 수 없습니다!\n")
  cat(sprintf("   찾는 파일: %s\n", data_file))
  cat(sprintf("   현재 위치: %s\n", getwd()))
  cat("\n해결 방법:\n")
  cat("1. RStudio에서 step2_r_analysis_FULL_SAMPLE.R 파일을 열어서 실행\n")
  cat("2. 또는 수동으로 작업 디렉토리 설정:\n")
  cat("   setwd('C:/Users/sinab/OneDrive/바탕 화면/논문작성/MIS/Final_result')\n")
  cat("3. 또는 Final_result.Rproj 파일을 더블클릭하여 프로젝트 열기\n")
  stop("데이터 파일을 찾을 수 없습니다. 위 방법으로 해결하세요.")
}

cat(sprintf("✓ 데이터 파일 확인: %s\n", data_file))
cat("=====================================\n\n")

cat("\n", rep("=", 100), "\n")
cat(rep(" ", 25), "위계적 회귀분석 (N=50,195)\n")
cat(rep("=", 100), "\n\n")

# 데이터 로드
cat("[1] 데이터 로드\n")
df <- read.csv("data_for_r_analysis_FULL_SAMPLE.csv", fileEncoding = "UTF-8")
cat(sprintf("✓ N = %s명\n\n", format(nrow(df), big.mark = ",")))

# 범주형 변수 처리 (CRITICAL FIX)
cat("[1-1] 범주형 변수 변환\n")
cat(rep("-", 100), "\n")
df$Gender <- factor(df$Gender, levels = c(1, 2), labels = c("Male", "Female"))
df$EmpType <- factor(df$EmpType)
# Education은 순서형이지만 등간격 가정하여 연속형 유지 (한계로 명시)
cat("✓ Gender를 명목변수로 변환 (1=Male, 2=Female)\n")
cat("✓ EmpType을 명목변수로 변환\n")
cat("✓ Education은 순서형으로 연속 처리 (등간격 가정 한계 존재)\n\n")

# 기술통계
cat("[2] 기술통계\n")
cat(rep("-", 100), "\n")
desc_vars <- c("PsychologicalHazards", "HealthProblems", "WorkEngagement",
               "Gender", "Age", "Education", "EmpType")
print(summary(df[desc_vars]))

# 상관분석 (연속형 변수만)
cat("\n[3] 상관분석 (연속형 변수만)\n")
cat(rep("-", 100), "\n")
cor_vars <- c("PsychologicalHazards", "HealthProblems", "WorkEngagement", "Age")
cor_matrix <- cor(df[cor_vars])
cat("주: 범주형 변수(Gender, EmpType)는 Pearson 상관 부적절하여 제외\n")
cat("    Education은 순서형이나 등간격 가정 한계로 제외\n\n")
print(round(cor_matrix, 3))

# Model 1: 통제변수만
cat("\n[4] Model 1: 통제변수만\n")
cat(rep("-", 100), "\n")
model1 <- lm(HealthProblems ~ Gender + Age + Education + EmpType, data = df)
summary_m1 <- summary(model1)
print(summary_m1)

# Model 2: + 심리적 위험
cat("\n[5] Model 2: + 심리적 위험 (가설 1 검증)\n")
cat(rep("-", 100), "\n")
model2 <- lm(HealthProblems ~ Gender + Age + Education + EmpType + PH_centered, data = df)
summary_m2 <- summary(model2)
print(summary_m2)

# Model 3: + 업무몰입
cat("\n[6] Model 3: + 업무몰입\n")
cat(rep("-", 100), "\n")
model3 <- lm(HealthProblems ~ Gender + Age + Education + EmpType + PH_centered + WE_centered, data = df)
summary_m3 <- summary(model3)
print(summary_m3)

# Model 4: + 상호작용항
cat("\n[7] Model 4: + 상호작용항 (가설 2 검증)\n")
cat(rep("-", 100), "\n")
model4 <- lm(HealthProblems ~ Gender + Age + Education + EmpType + PH_centered + WE_centered + PH_x_WE,
             data = df)
summary_m4 <- summary(model4)
print(summary_m4)

# VIF 진단 (수동 계산 - 표준 방법)
cat("\n[8] 다중공선성 진단 (VIF)\n")
cat(rep("-", 100), "\n")

# 표준 VIF 계산 함수
calculate_vif <- function(model) {
  # 모형 행렬 추출 (절편 제외)
  X <- model.matrix(model)[, -1]

  # 연속형 변수만 추출 (범주형 더미 제외)
  continuous_vars <- c("Age", "Education", "PH_centered", "WE_centered", "PH_x_WE")
  vif_results <- numeric(length(continuous_vars))
  names(vif_results) <- continuous_vars

  for (var in continuous_vars) {
    if (var %in% colnames(X)) {
      # 해당 변수를 종속변수로, 나머지를 독립변수로 회귀
      formula_str <- paste(var, "~", paste(setdiff(colnames(X), var), collapse = " + "))
      aux_model <- lm(as.formula(formula_str), data = as.data.frame(X))
      r_squared <- summary(aux_model)$r.squared
      vif_results[var] <- 1 / (1 - r_squared)
    }
  }

  # 범주형 변수 (Gender, EmpType)는 GVIF로 계산
  # Gender (1 df)
  gender_cols <- grep("^Gender", colnames(X), value = TRUE)
  if (length(gender_cols) > 0) {
    formula_str <- paste("cbind(", paste(gender_cols, collapse = ","), ") ~ .")
    # 간단히 평균 VIF 사용
    gender_vif <- mean(sapply(gender_cols, function(v) {
      aux <- lm(as.formula(paste(v, "~", paste(setdiff(colnames(X), gender_cols), collapse = " + "))),
                data = as.data.frame(X))
      1 / (1 - summary(aux)$r.squared)
    }))
    vif_results <- c(vif_results, Gender = gender_vif)
  }

  # EmpType (3 df)
  emptype_cols <- grep("^EmpType", colnames(X), value = TRUE)
  if (length(emptype_cols) > 0) {
    emptype_vif <- mean(sapply(emptype_cols, function(v) {
      aux <- lm(as.formula(paste(v, "~", paste(setdiff(colnames(X), emptype_cols), collapse = " + "))),
                data = as.data.frame(X))
      1 / (1 - summary(aux)$r.squared)
    }))
    vif_results <- c(vif_results, EmpType = emptype_vif)
  }

  return(vif_results)
}

vif_values <- calculate_vif(model4)
vif_df <- data.frame(
  Variable = names(vif_values),
  VIF = round(as.numeric(vif_values), 3)
)
print(vif_df)

if (max(vif_df$VIF, na.rm = TRUE) < 10) {
  cat("\n✓ 모든 VIF < 10: 다중공선성 문제 없음\n")
  cat(sprintf("  최대 VIF = %.3f\n", max(vif_df$VIF, na.rm = TRUE)))
} else {
  cat("\n⚠️ 일부 VIF ≥ 10: 다중공선성 의심\n")
}

# 모형 비교
cat("\n[9] 모형 비교\n")
cat(rep("-", 100), "\n")
model_comparison <- data.frame(
  Model = c("Model 1", "Model 2", "Model 3", "Model 4"),
  R_squared = c(summary_m1$r.squared, summary_m2$r.squared,
                summary_m3$r.squared, summary_m4$r.squared),
  Adj_R_squared = c(summary_m1$adj.r.squared, summary_m2$adj.r.squared,
                    summary_m3$adj.r.squared, summary_m4$adj.r.squared),
  F_statistic = c(summary_m1$fstatistic[1], summary_m2$fstatistic[1],
                  summary_m3$fstatistic[1], summary_m4$fstatistic[1])
)
model_comparison$Delta_R_squared <- c(0, diff(model_comparison$R_squared))
# 숫자 열만 반올림하여 출력
model_comparison_print <- model_comparison
model_comparison_print[, -1] <- round(model_comparison_print[, -1], 4)
print(model_comparison_print)

# 단순기울기 분석
cat("\n[10] 단순기울기 분석 (Simple Slope Analysis)\n")
cat(rep("-", 100), "\n")

beta_ph <- coef(model4)["PH_centered"]
beta_interaction <- coef(model4)["PH_x_WE"]
we_mean <- mean(df$WorkEngagement)
we_sd <- sd(df$WorkEngagement)

# 고/저 업무몰입 집단
we_low <- we_mean - we_sd
we_high <- we_mean + we_sd

# 단순기울기 계산
slope_low <- beta_ph + beta_interaction * (we_low - we_mean)
slope_high <- beta_ph + beta_interaction * (we_high - we_mean)

cat(sprintf("업무몰입 평균: %.3f\n", we_mean))
cat(sprintf("업무몰입 표준편차: %.3f\n", we_sd))
cat(sprintf("\n저업무몰입 집단 (M - 1SD = %.3f):\n", we_low))
cat(sprintf("  단순기울기 β = %.3f\n", slope_low))
cat(sprintf("\n고업무몰입 집단 (M + 1SD = %.3f):\n", we_high))
cat(sprintf("  단순기울기 β = %.3f\n", slope_high))
cat(sprintf("\n기울기 차이 Δβ = %.3f\n", slope_high - slope_low))

if (slope_high > slope_low) {
  cat("\n⚠️ 역설적 조절효과: 업무몰입이 높을수록 심리적 위험의 영향이 강화됨\n")
} else {
  cat("\n✓ 완충 효과: 업무몰입이 높을수록 심리적 위험의 영향이 완화됨\n")
}

# 결과 저장
cat("\n[11] 결과 저장\n")
cat(rep("-", 100), "\n")

# 모형 비교 저장
write.csv(model_comparison, "model_comparison_FULL_SAMPLE.csv",
          row.names = FALSE, fileEncoding = "UTF-8")
cat("✓ model_comparison_FULL_SAMPLE.csv 저장 완료\n")

# Model 4 계수 저장
model4_summary <- summary(model4)
model4_coef <- data.frame(
  Variable = rownames(model4_summary$coefficients),
  Estimate = model4_summary$coefficients[, "Estimate"],
  Std_Error = model4_summary$coefficients[, "Std. Error"],
  t_value = model4_summary$coefficients[, "t value"],
  p_value = model4_summary$coefficients[, "Pr(>|t|)"]
)
write.csv(model4_coef, "model4_coefficients_FULL_SAMPLE.csv",
          row.names = FALSE, fileEncoding = "UTF-8")
cat("✓ model4_coefficients_FULL_SAMPLE.csv 저장 완료\n")

# VIF 저장
write.csv(vif_df, "vif_results_FULL_SAMPLE.csv",
          row.names = FALSE, fileEncoding = "UTF-8")
cat("✓ vif_results_FULL_SAMPLE.csv 저장 완료\n")

# 상관표 저장 (연속형 변수만)
write.csv(round(cor_matrix, 3), "correlation_matrix_FULL_SAMPLE.csv",
          row.names = TRUE, fileEncoding = "UTF-8")
cat("✓ correlation_matrix_FULL_SAMPLE.csv 저장 완료\n")

cat("\n", rep("=", 100), "\n")
cat(rep(" ", 40), "분석 완료!\n")
cat(rep("=", 100), "\n\n")

# 최종 결과 요약
cat("최종 결과 요약:\n")
cat(rep("-", 100), "\n")
cat(sprintf("N = %s명\n", format(nrow(df), big.mark = ",")))
cat(sprintf("Model 4 R² = %.3f, Adj.R² = %.3f, F = %.3f\n",
            summary_m4$r.squared, summary_m4$adj.r.squared, summary_m4$fstatistic[1]))
cat(sprintf("\n가설 1 (심리적 위험 → 건강 문제):\n"))
cat(sprintf("  B = %.3f, t = %.3f, p = %.3f",
            beta_ph, summary_m4$coefficients["PH_centered", "t value"],
            summary_m4$coefficients["PH_centered", "Pr(>|t|)"]))
if (summary_m4$coefficients["PH_centered", "Pr(>|t|)"] < 0.001) {
  cat(" *** (유의)\n")
} else if (summary_m4$coefficients["PH_centered", "Pr(>|t|)"] < 0.01) {
  cat(" ** (유의)\n")
} else if (summary_m4$coefficients["PH_centered", "Pr(>|t|)"] < 0.05) {
  cat(" * (유의)\n")
} else {
  cat(" (비유의)\n")
}

cat(sprintf("\n가설 2 (업무몰입 조절효과):\n"))
cat(sprintf("  B = %.3f, t = %.3f, p = %.3f",
            beta_interaction, summary_m4$coefficients["PH_x_WE", "t value"],
            summary_m4$coefficients["PH_x_WE", "Pr(>|t|)"]))
if (summary_m4$coefficients["PH_x_WE", "Pr(>|t|)"] < 0.001) {
  cat(" *** (유의)\n")
} else if (summary_m4$coefficients["PH_x_WE", "Pr(>|t|)"] < 0.01) {
  cat(" ** (유의)\n")
} else if (summary_m4$coefficients["PH_x_WE", "Pr(>|t|)"] < 0.05) {
  cat(" * (유의)\n")
} else {
  cat(" (비유의)\n")
}

cat(rep("=", 100), "\n")
