library(shiny)
library(shinydashboard)
library(tidyverse)
library(janitor)
library(lubridate)
library(ggrepel)
library(scales)

# ==========================================
# 1. DATA PREPARATION LAYER (Executed Once)
# ==========================================
# Read and clean the data exactly as your project specified
train <- read_csv("data/train.csv") %>% clean_names()
train$order_date <- as.Date(train$order_date, format = "%m/%d/%Y")

# Feature Engineering
train <- train %>%
  mutate(
    year = year(order_date),
    month = month(order_date, label = TRUE)
  )

# Pre-calculate Customer Types for Segmentation Analysis
customer_sales <- train %>%
  group_by(year, category, customer_name) %>%
  summarise(total_sales = sum(sales), .groups = "drop")

repeat_customers <- customer_sales %>%
  group_by(customer_name) %>%
  summarise(n_years = n_distinct(year), .groups = "drop")

repeat_customers1 <- repeat_customers %>%
  mutate(
    customer_type = case_when(
      n_years >= 3 ~ "Highly Loyal",
      n_years == 2 ~ "Returning",
      TRUE ~ "One-time"
    )
  )

train <- train %>% 
  left_join(repeat_customers1, by = "customer_name") %>%
  mutate(customer_type = ifelse(is.na(customer_type), "One-time", customer_type))

# Extract unique years for the sidebar filter dropdown
available_years <- sort(unique(train$year), decreasing = TRUE)


# ==========================================
# 2. USER INTERFACE (UI) LAYOUT
# ==========================================
ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(title = "Retail Sales Insights"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview & Sales", tabName = "overview", icon = icon("chart-bar")),
      menuItem("Trends & Seasonality", tabName = "trends", icon = icon("chart-line")),
      menuItem("Customer Analytics", tabName = "customers", icon = icon("users"))
    ),
    hr(),
    # Dynamic Dashboard Control Filters
    selectInput("year_select", "Select Year Option:", choices = c("All Years", available_years)),
    selectInput("region_select", "Select Region Filter:", choices = c("All Regions", unique(train$region)))
  ),
  
  dashboardBody(
    tabItems(
      # --- TAB 1: OVERVIEW & SALES ---
      tabItem(tabName = "overview",
        fluidRow(
          valueBoxOutput("total_sales_box", width = 4),
          valueBoxOutput("top_category_box", width = 4),
          valueBoxOutput("top_region_box", width = 4)
        ),
        fluidRow(
          box(title = "Sales Breakdown by Category", status = "primary", solidHeader = TRUE, plotOutput("category_plot")),
          box(title = "Regional Sales Contribution", status = "primary", solidHeader = TRUE, plotOutput("region_plot"))
        )
      ),
      
      # --- TAB 2: TRENDS & SEASONALITY ---
      tabItem(tabName = "trends",
        fluidRow(
          box(title = "Monthly Sales Volatility Profile", status = "warning", solidHeader = TRUE, width = 12, plotOutput("trend_plot"))
        )
      ),
      
      # --- TAB 3: CUSTOMER ANALYTICS ---
      tabItem(tabName = "customers",
        fluidRow(
          box(title = "Top 10 Revenue Generating Customers", status = "info", solidHeader = TRUE, plotOutput("top_customers_plot")),
          box(title = "Revenue Share by Retention Profile", status = "info", solidHeader = TRUE, plotOutput("customer_share_plot"))
        )
      )
    )
  )
)


# ==========================================
# 3. SERVER COMPUTATION LOGIC
# ==========================================
server <- function(input, output, session) {
  
  # Reactive Data Filtering Expression
  filtered_data <- reactive({
    data <- train
    if (input$year_select != "All Years") {
      data <- data %>% filter(year == as.numeric(input$year_select))
    }
    if (input$region_select != "All Regions") {
      data <- data %>% filter(region == input$region_select)
    }
    return(data)
  })
  
  # --- VALUE BOXES COMPUTATIONS ---
  output$total_sales_box <- renderValueBox({
    total <- sum(filtered_data()$sales)
    valueBox(dollar(total), "Total Revenue Generated", icon = icon("dollar-sign"), color = "green")
  })
  
  output$top_category_box <- renderValueBox({
    cat_summary <- filtered_data() %>% group_by(category) %>% summarise(ts = sum(sales)) %>% arrange(desc(ts))
    top_cat <- if(nrow(cat_summary) > 0) cat_summary$category[1] else "None"
    valueBox(top_cat, "Top Performing Category", icon = icon("box"), color = "aqua")
  })
  
  output$top_region_box <- renderValueBox({
    reg_summary <- filtered_data() %>% group_by(region) %>% summarise(ts = sum(sales)) %>% arrange(desc(ts))
    top_reg <- if(nrow(reg_summary) > 0) reg_summary$region[1] else "None"
    valueBox(top_reg, "Top Active Region", icon = icon("map-marker-alt"), color = "yellow")
  })
  
  # --- CHART RENDERING LOGIC ---
  
  # Category Plot
  output$category_plot <- renderPlot({
    cat_df <- filtered_data() %>% group_by(category) %>% summarise(total_sales = sum(sales))
    ggplot(cat_df, aes(x = reorder(category, -total_sales), y = total_sales, fill = category)) +
      geom_col(show.legend = FALSE) +
      scale_y_continuous(labels = comma) +
      labs(x = "Category", y = "Sales ($)") +
      theme_minimal()
  })
  
  # Region Plot
  output$region_plot <- renderPlot({
    reg_df <- filtered_data() %>% group_by(region) %>% summarise(total_sales = sum(sales))
    ggplot(reg_df, aes(x = reorder(region, -total_sales), y = total_sales, fill = region)) +
      geom_col(show.legend = FALSE) +
      scale_y_continuous(labels = comma) +
      labs(x = "Region", y = "Sales ($)") +
      theme_minimal()
  })
  
  # Trend Plot
  output$trend_plot <- renderPlot({
    trend_df <- filtered_data() %>%
      group_by(year, month) %>%
      summarise(Total_Sales = sum(sales), .groups = "drop")
    
    ggplot(trend_df, aes(x = month, y = Total_Sales, group = factor(year), color = factor(year))) +
      geom_line(linewidth = 1) +
      geom_point(size = 2) +
      scale_y_continuous(labels = comma) +
      labs(x = "Month", y = "Revenue ($)", color = "Year") +
      theme_minimal()
  })
  
  # Top Customers Plot
  output$top_customers_plot <- renderPlot({
    cust_df <- filtered_data() %>% 
      group_by(customer_name) %>% 
      summarise(total_sales = sum(sales)) %>%
      arrange(desc(total_sales)) %>% 
      head(10)
    
    ggplot(cust_df, aes(x = reorder(customer_name, total_sales), y = total_sales, fill = customer_name)) +
      geom_col(show.legend = FALSE) +
      coord_flip() +
      scale_y_continuous(labels = comma) +
      labs(x = "Customer Name", y = "Accumulated Sales ($)") +
      theme_minimal()
  })
  
  # Customer Segment Share Plot
  output$customer_share_plot <- renderPlot({
    share_df <- filtered_data() %>%
      group_by(customer_type) %>%
      summarise(total_revenue = sum(sales), .groups = "drop") %>%
      mutate(percent = total_revenue / sum(total_revenue) * 100)
    
    ggplot(share_df, aes(x = 2, y = percent, fill = customer_type)) +
      geom_col(color = "white", show.legend = TRUE) +
      coord_polar(theta = "y") +
      xlim(0.5, 2.5) +
      geom_text(aes(label = paste0(round(percent, 1), "%")), position = position_stack(vjust = 0.5)) +
      labs(fill = "Segment") +
      theme_void()
  })
}

# ==========================================
# 4. LAUNCH INITIALIZATION
# ==========================================
shinyApp(ui = ui, server = server)