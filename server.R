server <- function(input, output, session) {
  # Reactive filtered data
  filtered_data <- reactive({
    data <- cwur_data %>%
      filter(year == input$yearInput)

    if (input$continentInput != "All") {
      data <- data %>% filter(continent == input$continentInput)
    }
    data
  })

  # Detailed Metric Analysis
  output$metricAnalysis <- renderPlotly({
    metric_name <- names(which(metrics == input$metricInput))
    top_unis <- filtered_data() %>%
      arrange(desc(!!sym(input$metricInput))) %>%
      head(input$topN)

    plot_ly() %>%
      add_bars(
        data = top_unis,
        x = ~reorder(institution, get(input$metricInput)),
        y = ~get(input$metricInput),
        marker = list(
          color = ~get(input$metricInput),
          colorscale = list(c(0,'rgb(255,235,235)'), c(1,'rgb(255,0,0)'))
        ),
        hovertext = ~paste(
          "Institution:", institution,
          "<br>", metric_name, ":", round(get(input$metricInput), 2),
          "<br>World Rank:", world_rank
        ),
        hoverinfo = 'text'
      ) %>%
      layout(
        xaxis = list(
          title = "",
          tickangle = 45,
          ticktext = ~institution,
          tickvals = ~institution
        ),
        yaxis = list(title = metric_name),
        showlegend = FALSE,
        margin = list(b = 100)
      )
  })

  # Enhanced World Map
  output$worldMap <- renderPlotly({
    data <- filtered_data() %>%
      group_by(country) %>%
      summarise(
        universities = n(),
        avg_score = mean(score, na.rm = TRUE),
        top_uni = first(institution[which.min(world_rank)]),
        best_rank = min(world_rank),
        .groups = 'drop'
      )

    plot_ly(data,
            type = 'choropleth',
            locations = ~country,
            locationmode = 'country names',
            z = ~universities,
            text = ~paste(
              "Country:", country,
              "<br>Number of Top Universities:", universities,
              "<br>Average Score:", round(avg_score, 1),
              "<br>Top Institution:", top_uni,
              "<br>Best World Rank:", best_rank
            ),
            colorscale = list(c(0,'rgb(255,235,235)'), c(1,'rgb(255, 58, 82)')),
            marker = list(
              line = list(
                color = 'rgb(227, 36, 60)',
                width = 0
              )
            )) %>%
      layout(
        geo = list(
          showframe = FALSE,
          projection = list(type = 'natural earth'),
          showcoastlines = TRUE,
          coastlinecolor = 'rgb(255, 255, 255)',
          showland = TRUE,
          landcolor = 'rgb(242, 242, 242)'
        ),
        margin = list(l = 0, r = 0, t = 30, b = 0)
      )
  })

  # Regional Evolution Trend
  output$regionTrend <- renderPlotly({
    trend_data <- continent_summary %>%
      group_by(year, continent) %>%
      summarise(
        universities = sum(count),
        avg_score = mean(avg_score),
        .groups = 'drop'
      )

    plot_ly(trend_data, x = ~year, y = ~universities, color = ~continent,
            type = 'scatter', mode = 'lines+markers',
            line = list(width = 2),
            marker = list(size = 8)) %>%
      layout(
        xaxis = list(title = "Year"),
        yaxis = list(title = "Number of Universities"),
        showlegend = TRUE,
        hovermode = 'closest'
      )
  })

  # Performance Comparison
  output$performanceComp <- renderPlotly({
    metric_data <- filtered_data() %>%
      group_by(continent) %>%
      summarise(
        across(
          c(quality_of_education, alumni_employment,
            quality_of_faculty, publications, citations),
          mean,
          na.rm = TRUE
        )
      ) %>%
      gather(metric, value, -continent)

    plot_ly(metric_data,
            type = 'scatter',
            mode = 'markers',
            x = ~continent,
            y = ~value,
            color = ~metric,
            size = ~value,
            sizes = c(20, 50),
            marker = list(opacity = 0.6),
            hoverinfo = 'text',
            text = ~paste(
              "Region:", continent,
              "<br>Metric:", metric,
              "<br>Value:", round(value, 2)
            )
    ) %>%
      layout(
        showlegend = TRUE,
        xaxis = list(title = "Region"),
        yaxis = list(title = "Score")
      )
  })

  # Rankings Table
  output$rankingTable <- renderDT({
    filtered_data() %>%
      select(
        Rank = world_rank,
        Institution = institution,
        Country = country,
        Region = continent,
        Score = score,
        `Education Quality` = quality_of_education,
        `Employment` = alumni_employment,
        `Faculty Quality` = quality_of_faculty
      ) %>%
      datatable(
        options = list(
          pageLength = 25,
          dom = 'Bfrtip',
          buttons = c('copy', 'csv', 'excel'),
          scrollY = "800px",
          scrollCollapse = TRUE
        ),
        rownames = FALSE,
        style = 'bootstrap',
        class = 'cell-border stripe',
        caption = paste("Global University Rankings -", input$yearInput)
      ) %>%
      formatStyle(
        'Score',
        background = styleColorBar(c(0,100), '#ff3a52'),
        backgroundSize = '98% 88%',
        backgroundRepeat = 'no-repeat',
        backgroundPosition = 'center'
      ) %>%
      formatRound(
        c('Score', 'Education Quality', 'Employment', 'Faculty Quality'),
        digits = 1
      )
  })
}
