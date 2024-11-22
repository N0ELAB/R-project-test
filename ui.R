dashboardPage(
  skin = "red",
  dashboardHeader(
    title = span(img(src = "logo2.svg", height = 70, style = "padding: 2px;")),
    titleWidth = 230,
    dropdownMenu(
      type = "notifications",
      headerText = strong("About this project"),
      icon = icon("question"),
      badgeStatus = NULL,
      notificationItem(
        text = steps$text[2],
        icon = icon("chart-line")
      ),
      notificationItem(
        text = steps$text[3],
        icon = icon("filter")
      ),
      notificationItem(
        text = steps$text[4],
        icon = icon("filter")
      ),
      notificationItem(
        text = tags$em(steps$text[1]),
        icon = icon("building-columns")
      ),
      notificationItem(
        text = strong(steps$text[5]),
        icon = icon("user-group")
      )
    ),
    tags$li(
      a(
        strong("ABOUT THE BEST PROFESSOR <3"),
        height = 40,
        href = "https://www.tbs-education.com/teacher/archimbaud-aurore/",
        title = "",
        target = "_blank"
      ),
      class = "dropdown"
    )
  ),

  dashboardSidebar(
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")),
    sidebarMenu(id = "sidebar",
                menuItem("Rankings", tabName = "rankings", icon = icon("list-ol")),
                menuItem("Analysis", tabName = "analysis", icon = icon("chart-line"))
    ),
    selectInput("continentInput", "Select Region",
                choices = c("All", continents)),
    selectInput("yearInput", "Select Year",
                choices = years,
                selected = max(years)),
    conditionalPanel(
      condition = "input.sidebar == 'analysis'",
      selectInput("metricInput", "Compare Metric",
                  choices = metrics,
                  selected = "score"),
      sliderInput("topN", "Top N Universities",
                  min = 5, max = 50, value = 20)
    )
  ),

  dashboardBody(
    tags$head(
      tags$style(HTML("
        .content-wrapper { background-color: #ffffff; }
        .box { border-top-color: #ff3a52; }
      "))
    ),

    tabItems(
      # Analysis Tab
      tabItem(
        tabName = "analysis",
        fluidRow(
          box(plotlyOutput("regionTrend"), width = 6,
              title = "Regional Evolution in Top 100"),
          box(plotlyOutput("performanceComp"), width = 6,
              title = "Performance Metrics by Region")
        ),
        fluidRow(
          box(plotlyOutput("metricAnalysis"), width = 12,
              title = "Top Universities Performance Analysis")
        )
      ),

      # Rankings Tab
      tabItem(
        tabName = "rankings",
        fluidRow(
          box(plotlyOutput("worldMap"), width = 12, height = 350,
              title = "Global Distribution of Elite Universities")
        ),
        fluidRow(
          box(DTOutput("rankingTable"), width = 12,
              title = "Global University Rankings")
        )
      )
    )
  )
)
