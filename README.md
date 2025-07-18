# High-Frequency Inflation Forecasting: A Two-Step Machine Learning Methodology

**Published in the [Latin American Journal of Central Banking](https://www.sciencedirect.com/science/article/pii/S2666143825000109)**

This repository contains the code supporting the paper:
**"High-Frequency Inflation Forecasting: A Two-Step Machine Learning Methodology"**.

## Overview

This study proposes a novel two-step machine learning framework for generating high-frequency (daily and weekly) inflation forecasts in developing economies, where official inflation data is typically released only at monthly intervals and with significant delays. Here, high-frequency forecasting is interpreted as nowcasting or interpolation — providing real-time predictions ahead of official releases or within-period estimates using mixed-frequency indicators — and also as a data augmentation technique.

In the first step, high-frequency predictors are aggregated to construct monthly-aligned features for training machine learning models. The second step involves rigorous feature selection and hyperparameter tuning across multiple machine learning algorithms. Through systematic evaluation, the final model — Ridge regression trained on an L1-regularized feature subset — was selected for its superior out-of-sample performance.

This model is deployed to generate daily and weekly year-on-year CPI inflation nowcasts. The resulting forecasts closely track observed monthly values, with distributional equivalence between official and high-frequency estimates confirmed by Kolmogorov–Smirnov tests. Compared to traditional econometric benchmarks, this approach delivers improved accuracy, providing timely and granular insights for forward-looking monetary policy decisions.

## Contents

* All code necessary to reproduce the results from the published paper
* Scripts for data preprocessing, feature engineering, model training, and evaluation
