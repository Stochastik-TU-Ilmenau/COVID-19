plot_repronum <- function(estimates, country_name) {
    estimates <- estimates %>%
        filter(tot.cases > 30)

    first_monday <- ymd("2020-01-06")
    plot_ly(estimates, x= ~date, y= ~repronum) %>%
        add_lines(name = "reproduction number") %>%
        add_ribbons(ymin = ~ci.lower, ymax = ~ci.upper, opacity = .5, name = "95% confidence interval") %>%
        add_bars(y = ~new.cases, yaxis = "y2", opacity = .1, name = "new cases") %>%
        layout(
            shapes = list(
                list(
                    type = "line",
                    x0 = 0, x1 = 1,
                    xref = "paper",
                    y0 = 1, y1 = 1,
                    line = list(color = "red", dash = "dot")
                )#,
                #                list(
                #                    type = "line",
                #                    x0 = 0, x1 = 1,
                #                    xref = "paper",
                #                    y0 = 2.4, y1 = 2.4,
                #                    line = list(color = "red", dash = "dot")
                #                )
                ),
            yaxis = list(
                type = "log",
                title = "reproduction rate",
                tickmode = "array",
                tickvals = 1:10,
                range = log(c(min(c(0.3, estimates$ci.lower), na.rm = TRUE), 10), base = 10)
                ),
            colorway = c("black", "grey", "blue"),
            yaxis2 = list(
                overlaying = "y",
                side = "right",
                title = "new cases"
                ),
            xaxis =  list(
                ticks = "outside",
                tickvals = seq(first_monday, today(), by = "1 week"),
                showline = TRUE,
                showgrid = TRUE,
                type = "date",
                tickformat = "%d/%m"
                ),
            legend = list(
                x = 0,
                y = -0.3,
                font = list(size = 10),
                bgcolor = "#FFFFFF00"
                ),
            margin = list(r = 60)
        )
}
