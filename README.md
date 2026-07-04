# 📊 Retail Sales Analysis & Interactive Dashboard (R Project)

## 🎯 Objective
Analyze retail sales data to identify core revenue drivers, regional performance trends, and dynamic customer behavior patterns. This project advances from localized exploratory scripts into a fully interactive web application (`shinydashboard`), providing stakeholders with live analytical deep-dives and modular filtering mechanics.

## 🛠️ Tools & Tech Stack
* **Core Language & Engine:** R (v3.6+)
* **Interactive Framework:** `shiny` & `shinydashboard` (Reactive backend logic)
* **Data Engineering & Manipulation:** `tidyverse` (`dplyr`, `readr`, `tidyr`), `janitor`, `lubridate`
* **Advanced Visualizations:** `ggplot2`, `scales` (currency metrics), `ggrepel` (label collision prevention)

## 💾 Dataset
* **Source:** Superstore Sales Dataset (Kaggle)

---

## 🔍 Key Analysis & Business Insights

### 1. Sales by Category
<figure>
<img src="visuals/sales_by_category.png" alt="Sales by Category" />
<figcaption aria-hidden="true">Sales by Category</figcaption>
</figure>

**Insight:** Technology generates the highest sales, indicating strong customer demand and making it the primary revenue driver for the business, followed by Office Supplies and Furniture.

### 2. Sales by Region
<figure>
<img src="visuals/sales_by_region.png" alt="Sales by Region" />
<figcaption aria-hidden="true">Sales by Region</figcaption>
</figure>

**Insight:** The West region leads in total sales, suggesting higher market demand or a stronger corporate presence in that geographical area.

### 3. Time Series & Seasonal Trends

#### 3.1 Monthly Sales Trend by Year
<figure>
<img src="monthly_sales_trend_by_year.png" alt="Monthly Trend By Year" />
<figcaption aria-hidden="true">Monthly Trend By Year</figcaption>
</figure>

**Insight:** Sales show distinct seasonal patterns with noticeable peaks in early months and August, followed by a mid-year dip. Trends remain consistent across financial years.

#### 3.2 Sales Trend with Rise and Drops by Year
<figure>
<img src="visuals/sales_trend_rise_drop_by_year.png" alt="Sales Trend with Rise and Drops by Year" />
<figcaption aria-hidden="true">Sales Trend with Rise and Drops by Year</figcaption>
</figure>

**Insight:** Feature-engineered time components extracted from core transaction dates enable longitudinal Year-over-Year (YoY) evaluations to quickly identify peak and low-performing macro months.

#### 3.3 Sales of Categories Trend over Years
<figure>
<img src="visuals/sales_by_category_over_time.png" alt="Sales of Categories Trend over Years" />
<figcaption aria-hidden="true">Sales of Categories Trend over Years</figcaption>
</figure>

**Insight:** Revenue across all divisions presents an upward trajectory, demonstrating firm baseline growth. Technology is the fastest-growing categorical component, while Office Supplies maintains a highly reliable, low-variance performance baseline. Furniture exhibits the highest volatility, indicating exposure to logistical, pricing, or demand fluctuations.

#### 3.4 Monthly Sales by Category with Peaks and Dips Over Years
<figure>
<img src="visuals/monthly_sales_by_category_over_time.png" alt="Monthly Sales by Category with Peaks and Dips Over Years" />
<figcaption aria-hidden="true">Monthly Sales by Category with Peaks and Dips Over Years</figcaption>
</figure>

**Insight:** Granular tracking isolates unique peaks and nadirs across micro-seasons. While Technology hits higher performance ceilings, synchronous fluctuations across all sectors signal clear opportunities for targeted marketing campaigns during peak periods.

---

### 4. Customer Analytics & Cohort Profiles

#### 4.1 Top Customers
<figure>
<img src="visuals/top_10_customers_by_sales.png" alt="Top Customers" />
<figcaption aria-hidden="true">Top Customers</figcaption>
</figure>

**Insight:** A small, highly concentrated cluster of accounts generates a disproportionate share of total revenue, illustrating the business necessity for VIP client retention workflows.

#### 4.2 Revenue Contribution by Customer Type (Loyal, Returning, One-time)
<figure>
<img src="visuals/revenue_contribution_customer_type_1.png" alt="Revenue Contribution by Customer Type 1" />
<figcaption aria-hidden="true">Revenue Contribution by Customer Type 1</figcaption>
</figure>

<figure>
<img src="visuals/revenue_contribution_customer_type_2.png" alt="Revenue Contribution by Customer Type 2" />
<figcaption aria-hidden="true">Revenue Contribution by Customer Type 2</figcaption>
</figure>

**Insight:** Cohort segmentation tracks cross-year interaction to divide consumer records into behavioral brackets (*Highly Loyal*, *Returning*, *One-time*). The overwhelming concentration of revenue within repeat customer bases proves that optimization of client retention paths generates significantly higher corporate ROI than solo acquisition metrics.

---

## 💻 Interactive Dashboard Architecture

The project contains an interactive `shinydashboard` platform designed to display these visual metrics dynamically using reactive data pipelines.

* **Overview & Sales Tab:** Features high-visibility KPI value boxes mapping total revenue, top product categories, and top regions alongside categorical bar charts.
* **Trends & Seasonality Tab:** Incorporates interactive monthly trend visualizers allowing users to compare performance years dynamically.
* **Customer Analytics Tab:** Merges top horizontal customer rankings side-by-side with dynamic, reactive cohort donut visualizations.
* **Global Sidebar Controls:** Enables live, structural data segmentation across different **Years** and **Regions** simultaneously.

---

## 📦 Project Directory Structure
```text
Sales-Analysis-R/
├── data/
│   └── train.csv               # Core transactional dataset
├── visuals/                    # Rendered exploratory visual PNG outputs
├── app.R                       # Reactive R Shiny application engine
├── run.R                       # Automated browser-launch script 
├── Sales Analysis Project.R    # Comprehensive exploratory script asset
└── README.md                   # Project documentation