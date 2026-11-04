# Hospital Quality Statistical Analysis Using SQL & Python

## Project Overview

This project analyzes publicly reported hospital quality data from the Centers for Medicare & Medicaid Services (CMS) to examine hospital mortality scores, reporting completeness, geographic variation, and statistically unusual observations.

The analysis combines **SQL Server for data preparation** with **Python for exploratory data analysis, statistical testing, and visualization**.

The goal is to turn healthcare quality data into interpretable insights while recognizing the limitations of comparing hospital performance using a single quality measure.

## Business Questions

- How many hospitals report usable mortality scores?
- What is the distribution of hospital mortality scores?
- Which states and territories have higher average reported scores?
- How complete is mortality score reporting across geographic locations?
- Are there statistically significant differences between Puerto Rico and other locations?
- Which hospitals have unusually high or low reported scores?

## Tools & Technologies

- **SQL Server / SSMS:** Data validation, cleaning, and analytical views
- **Python:** Pandas, NumPy, SciPy, Matplotlib
- **Jupyter Notebook:** Exploratory and statistical analysis
- **VS Code:** Development environment

## Dataset

**Source:** CMS — Complications and Deaths Hospital dataset

The imported dataset contains:

| Metric | Value |
|---|---:|
| Total records | 95,800 |
| Unique hospitals | 4,790 |
| Quality measures | 20 |
| Hospitals with valid Hybrid_HWM scores | 4,261 |
| Hospitals without valid Hybrid_HWM scores | 529 |
| Mortality score availability | 88.96% |

The primary mortality analysis focuses on the `Hybrid_HWM` measure. The scores are risk-standardized mortality estimates and should not be interpreted as raw patient death counts.

## Methodology

### SQL Data Preparation

- Imported CMS hospital quality data into SQL Server.
- Validated record counts and hospital identifiers.
- Converted reported scores into numeric values where applicable.
- Created reusable SQL views for cleaned hospital quality data and mortality analysis.
- Preserved missing-score information for reporting completeness analysis.

### Python Statistical Analysis

- Examined missing values and score availability.
- Calculated descriptive statistics, including mean, median, standard deviation, and quartiles.
- Analyzed mortality score distributions and skewness.
- Identified outliers using the interquartile range (IQR) method.
- Compared geographic differences in reported mortality scores.
- Conducted a Mann–Whitney U test comparing Puerto Rico with other locations.
- Created statistical visualizations to communicate findings.

## Key Findings

### Mortality Score Distribution

| Statistic | Value |
|---|---:|
| Mean | 4.04 |
| Median | 3.90 |
| Standard deviation | 0.84 |
| Minimum | 1.60 |
| Maximum | 12.80 |
| Skewness | 1.92 |

The distribution is positively skewed, indicating that a smaller number of hospitals have substantially higher reported scores.

### Outlier Detection

Using the IQR method:

- Lower threshold: 2.15
- Upper threshold: 5.75
- Outliers identified: 138
- Percentage of scored hospitals: 3.24%

These observations warrant further investigation but do not, by themselves, establish poor hospital performance.

### Geographic Variation

Puerto Rico had an average reported mortality score of **7.47**, compared with approximately **4.00** across other locations.

A Mann–Whitney U test identified a statistically significant difference between the two groups:

**p ≈ 2.49 × 10⁻²⁶**

This result indicates an association in the observed data, not a causal explanation for the difference.

### Reporting Completeness

Approximately **88.96%** of hospitals had a valid score for the selected mortality measure.

Reporting completeness also varied by state, highlighting the importance of assessing missing data before interpreting geographic comparisons.

## Limitations

- The analysis focuses primarily on one hospital mortality measure.
- Differences may reflect patient populations, case mix, reporting practices, or other unobserved factors.
- Missing values may affect geographic comparisons.
- Statistical significance does not establish causation.
- Results should not be used as standalone hospital rankings or clinical recommendations.

## Project Structure

```text
Hospital-Quality-Statistical-Analysis/
├── data/
├── notebooks/
│   ├── 01_data_exploration.ipynb
│   └── 02_hospital_quality_statistical_analysis.ipynb
├── sql/
├── reports/
├── README.md
├── requirements.txt
└── .gitignore
```

## Conclusion

This project demonstrates an end-to-end analytical workflow, from healthcare data preparation in SQL Server to statistical analysis and interpretation in Python.

The findings highlight the importance of examining both reported mortality scores and data completeness, applying appropriate statistical methods, and communicating healthcare analytics results with careful consideration of their limitations.