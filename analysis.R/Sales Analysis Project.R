# ============================================================
# 📊 RETAIL SALES ANALYSIS PROJECT (R)
# ============================================================
# Objective:
# Analyze sales data to identify revenue drivers, trends,
# and customer behavior.
# ============================================================


# ============================================================
# 1. LOAD LIBRARIES
# ============================================================

# Install packages if not already installed
# install.packages("tidyverse")
# install.packages("janitor")
# install.packages("lubridate")

library(tidyverse)
library(janitor)
library(lubridate)


# ============================================================
# 2. LOAD DATA
# ============================================================

# Load dataset
train <- read_csv("data/train.csv")

# Preview dataset
head(train)
glimpse(train)
str(train)


# ============================================================
# 3. DATA CLEANING
# ============================================================

# Clean column names
train <- train %>%
  clean_names()

# Convert order date to Date format
train$order_date <- as.Date(train$order_date, format = "%m/%d/%Y")

# Check missing values
colSums(is.na(train))

# Remove duplicate rows
train <- train %>%
  distinct()


# ============================================================
# 4. FEATURE ENGINEERING
# ============================================================

# Extract month and year for trend analysis
train <- train %>%
  mutate(
    year = year(order_date),
    month = month(order_date, label = TRUE)
  )


# ============================================================
# 5. EXPLORATORY DATA ANALYSIS (EDA)
# ============================================================

# ------------------------------------------------------------
# 5.1 Total Sales
# ------------------------------------------------------------
total_sales <- sum(train$sales)

# Insight:
# Total revenue generated across all transactions


# ------------------------------------------------------------
# 5.2 Sales by Category
# ------------------------------------------------------------
sales_category <- train %>%
  group_by(category) %>%
  summarise(total_sales = sum(sales)) %>%
  arrange(desc(total_sales))

sales_category_year <- train %>%
  mutate(Year = year(order_date)) %>%
  group_by(Year, category) %>%
  summarise(total_sales = sum(sales), .groups = "drop")

sales_category_year <- sales_category_year %>%
  filter(!is.na(Year))

sales_category_year_month <- train %>%
  mutate(
    Year = year(order_date),
    Month = month(order_date, label = TRUE)  # better for plotting
  ) %>%
  group_by(Year, Month, category) %>%
  summarise(
    total_sales = sum(sales) / 10000,
    .groups = "drop"
  )

sales_category_year_month <- sales_category_year_month %>%
  filter(!is.na(Year))

sales_category_year_month$Month <- factor(
  sales_category_year_month$Month,
  levels = month.abb
)

highlight_points_category <- sales_category_year_month %>%
  group_by(category, Year) %>%
  
  summarise(
    peak_sales = max(total_sales),
    peak_month = as.character(Month[which.max(total_sales)]),
    
    dip_sales = min(total_sales),
    dip_month  = as.character(Month[which.min(total_sales)]),
    
    .groups = "drop"
  ) %>%
  
  pivot_longer(
    cols = c(peak_sales, dip_sales),
    names_to = "type",
    values_to = "total_sales"
  ) %>%
  
  mutate(
    Month = ifelse(type == "peak_sales", peak_month, dip_month),
    type = ifelse(type == "peak_sales", "Peak", "Dip"),
    label = as.character(Month)
  ) %>%
  
  select(category, Year, Month, total_sales, type, label)


# Insight:
# Identify which product categories generate the most revenue
# Analyze the rise and drops over years by different categories

# ------------------------------------------------------------
# 5.3 Sales by Region
# ------------------------------------------------------------
sales_region <- train %>%
  group_by(region) %>%
  summarise(total_sales = sum(sales)) %>%
  arrange(desc(total_sales))

# Insight:
# Determine top-performing regions


# ------------------------------------------------------------
# 5.4 Monthly Sales Trend
# ------------------------------------------------------------
monthly_sales_new_2 <- train %>%
  mutate(YearMonth = floor_date(order_date, "month")) %>%
  group_by(YearMonth) %>%
  summarise(total_sales = sum(sales), .groups = "drop")

monthly_sales_new_2 <- monthly_sales_new_2 %>%
  mutate(Year = year(YearMonth))


sale_trends_10th <- train %>% 
  mutate(
    Year = year(order_date),
    Month = month(order_date, label = TRUE)
  ) %>% 
  group_by(Year, Month) %>% 
  summarise(Total_Sales = sum(sales)/10000, .groups = "drop")


# Insight:
# Analyze seasonal patterns and growth trends by year
# Analyze the rise and drops over years


# ------------------------------------------------------------
# 5.5 Top 10 Customers
# ------------------------------------------------------------
top_customers <- train %>%
  group_by(customer_name) %>%
  summarise(total_sales = sum(sales)) %>%
  arrange(desc(total_sales)) %>%
  slice_head(n = 10)

# Insight:
# Identify high-value customers contributing most revenue



# ------------------------------------------------------------
# 5.6 Top Customers by Region
# ------------------------------------------------------------
top_customers_region <- train %>%
  group_by(region, customer_name) %>%
  summarise(total_sales = sum(sales), .groups = "drop") %>%
  group_by(region) %>%
  slice_max(total_sales, n = 5)

# Insight:
# Top customers vary across regions, enabling targeted strategies


# ------------------------------------------------------------
# 5.7 Top Customers by Category
# ------------------------------------------------------------
top_customers_category <- train %>%
  group_by(category, customer_name) %>%
  summarise(total_sales = sum(sales), .groups = "drop") %>%
  group_by(category) %>%
  slice_max(total_sales, n = 5)

# Insight:
# High-value customers differ by product category

# ------------------------------------------------------------
# 5.8 Revenue Contribution by Customer Type (Loyal, Returning, One-time)
# ------------------------------------------------------------
customer_sales <- train %>%
  mutate(Year = year(order_date)) %>%
  group_by(Year, category, customer_name) %>%
  summarise(
    total_sales = sum(sales),
    .groups = "drop"
  )

repeat_customers <- customer_sales %>%
  group_by(customer_name) %>%
  summarise(
    n_years = n_distinct(Year),
    .groups = "drop"
  ) %>%
  filter(n_years > 1) 

repeat_customers1 <- repeat_customers %>%
  mutate(
    customer_type = case_when(
      n_years >= 3 ~ "Highly Loyal",
      n_years == 2 ~ "Returning",
      TRUE ~ "One-time"
    )
  )
customer_type_sales <- customer_sales %>%
  left_join(repeat_customers1, by = "customer_name")
      
customer_type_sales <- customer_type_sales %>%
  mutate(
    customer_type = ifelse(is.na(customer_type), "One-time", customer_type)
        )
      
revenue_dist <- customer_type_sales %>%
  group_by(customer_type) %>%
    summarise(
      total_revenue = sum(total_sales),
      .groups = "drop"
      ) %>%
    mutate(
     percent = total_revenue / sum(total_revenue) * 100,
     label = paste0(customer_type, "\n", round(percent, 1), "%")
    )

# Insight:
# Analyze the importance of customer retention over customer acquisition

# ============================================================
# 6. DATA VISUALIZATION
# ============================================================

# ------------------------------------------------------------
# 6.1 Sales by Category
# ------------------------------------------------------------
ggplot(sales_category, aes(x = reorder(category, -total_sales), y = total_sales, fill = category)) +
  geom_col() +
  labs(
    title = "Total Sales by Category",
    x = "Category",
    y = "Total Sales"
  ) +
  geom_text(aes(label = round(total_sales, 0)), vjust = -0.5) +
  theme_minimal()

ggsave("Sales-Analysis-R/visuals/sales_by_Category.png")


# ------------------------------------------------------------
# 6.2 Sales by Region
# ------------------------------------------------------------
ggplot(sales_region, aes(x = reorder(region, -total_sales), y = total_sales, fill = region)) +
  geom_col() +
  labs(
    title = "Sales by Region",
    x = "Region",
    y = "Total Sales"
  ) +
  geom_text(aes(label = round(total_sales, 0)), vjust = -0.5) +
  theme_minimal()

ggsave("Sales-Analysis-R/visuals/sales_by_region.png")


# ------------------------------------------------------------
# 6.3 Monthly Sales Trend By Year
# ------------------------------------------------------------
ggplot(sale_trends_10th, aes(x = Month, y = Total_Sales, group = Year, color = factor(Year))) +
  geom_line(size = 1) +
  geom_point() +
  scale_y_log10() +
  labs(
    title = "Monthly Sales Trend by Year",
    y = "Sales (Thousands)",
    color = "Year"
  ) +
  theme_minimal()

ggsave("Sales-Analysis-R/visuals/monthly_sales_trend_by_year.png")


#-------------------------------------------------------------------
# 6.4 Sales Trend with Rise and Drops by Year
# ------------------------------------------------------------------
ggplot(monthly_sales_new_2, aes(x = YearMonth, y = total_sales)) +
  geom_line(color = "red", linewidth = 1) +
  scale_y_log10() +
  
  geom_point(
    data = highlight_points_2,
    aes(shape = type),
    size = 3,
    color = "black"
  ) +
  
  geom_text_repel(
    data = highlight_points,
    aes(label = label),
    size = 3,
    max.overlaps = 20
  ) +
  
  labs(
    title = "Sales Trend with Rise and Drops by Year",
    x = "Date",
    y = "Total Sales",
    shape = "Type"
  ) +
  theme_minimal()

ggsave("Sales-Analysis-R/visuals/sales_trend_rise_drop_by_year.png")

#-----------------------------------------------------------------------------
# 6.5 Sales of Categories Trend over Years
#-----------------------------------------------------------------------------

ggplot(sales_category_year, aes(x = Year, y = total_sales, color = category)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  
  scale_y_continuous(labels = scales::comma) +
  
  labs(
    title = "Sales by Category Over Time",
    x = "Year",
    y = "Total Sales",
    color = "Category"
  ) +
  theme_minimal()

ggsave("Sales-Analysis-R/visuals/sales_by_category_over_time.png")


ggplot(sales_category_year_month,
       aes(x = Month, y = total_sales, color = category, group = category)) +
  
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  
  # Peaks & dips ON the lines
  geom_point(
    data = highlight_points_category,
    aes(x = Month, y = total_sales, shape = type),
    size = 3,
    color = "black"
  ) +
  
  geom_text_repel(
    data = highlight_points_category,
    aes(x = Month, y = total_sales, label = label),
    size = 3,
    max.overlaps = 20
  ) +
  
  scale_y_continuous(labels = comma) +
  
  labs(
    title = "Monthly Sales by Category with Peaks and Dips Over Years",
    x = "Month",
    y = "Total Sales (x10,000)",
    color = "Category",
    shape = "Type"
  ) +  
  facet_wrap(~Year) +
  
  theme_minimal()

ggsave("Sales-Analysis-R/visuals/monthly_sales_by_category_over_time.png")

# ------------------------------------------------------------
# 6.4 Top Customers
# ------------------------------------------------------------
ggplot(top_customers, aes(x = reorder(customer_name, total_sales), y = total_sales, fill = customer_name)) +
  +     geom_col() +
  +     coord_flip() +
  +     labs(
    +         title = "Top 10 Customers by Sales",
    +         x = "Customer",
    +         y = "Total Sales"
    +     )
    + geom_text(aes(label = round(total_sales, 0)), vjust = -0.5) +
  +     theme_minimal()

ggsave("top_10_customers_by_sales.png")


# ------------------------------------------------------------
# 6.5 Revenue Contribution by Customer Type (loyal, returning, and one-time)
# ------------------------------------------------------------
ggplot(revenue_dist, 
       aes(x = "", y = percent, fill = customer_type)) +
  
  geom_col(width = 1, color = "white") +
  
  coord_polar(theta = "y") +
  
  geom_text(
    aes(label = paste0(round(percent, 1), "%")),
    position = position_stack(vjust = 0.5),
    size = 4
  ) +
  
  labs(
    title = "Revenue Contribution by Customer Type - Pie Chart",
    fill = "Customer Type"
  ) +
  
  theme_void()

ggsave("Sales-Analysis-R/visuals/revenue_contribution_customer_type_1.png")

ggplot(revenue_dist, 
       aes(x = 2, y = percent, fill = customer_type)) +
  
  geom_col(color = "white") +
  
  coord_polar(theta = "y") +
  xlim(0.5, 2.5) +
  
  geom_text(
    aes(label = paste0(round(percent, 1), "%")),
    position = position_stack(vjust = 0.5),
    size = 4
  ) +
  
  labs(
    title = "Revenue Contribution by Customer Type - Donut Chart"
  ) +
  
  theme_void()

ggsave("Sales-Analysis-R/visuals/revenue_contribution_customer_type_2.png")

# ============================================================
# 7. KEY INSIGHTS (FOR PORTFOLIO)
# ============================================================

# - Technology (or top category) drives the highest revenue
# - Certain regions outperform others in sales performance
# - Sales show seasonal trends across months
# - A small group of customers contributes significantly to revenue
# - Customer behavior varies across regions and categories


# ============================================================
# END OF PROJECT
# ============================================================