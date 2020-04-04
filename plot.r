mincases <- 30

plot_repronum <- function(estimates, country_name, language) {
    estimates <- estimates %>%
        filter(tot.cases > mincases)

    strings <- list(
        en = list(
            repno = "reproduction number",
            est_repno = "estimated reproduction number",
            ci = "95% confidence interval",
            new_cases = "newly reported cases",
            title = "Estimated reproduction number / newly reported cases",
            date = "date",
            xaxis = "date of infection / reporting date"
        ),
        de = list(
            repno = "Reproduktionszahl",
            est_repno = "geschätzte Reproduktionszahl",
            ci = "95% Konfidenzintervall",
            new_cases = "neu gemeldete Fälle",
            title = "Geschätzte Reproduktionszahl / neu gemeldete Fälle",
            date = "Datum",
            xaxis = "Infektionsdatum / Meldedatum"
        )
    )

    translations <- strings[[language]]
    

    first_monday <- ymd("2020-01-06")
    plot_ly(estimates, x= ~date, y= ~repronum) %>%
        add_lines(
            name = translations$repno,
            hovertemplate = paste0(
                "<b>", translations$date, "</b>: %{x|%d/%m/%Y}",
                "<br><b>", translations$est_repno, "</b>: %{y:.2f}",
                "<br><b>", translations$ci, "</b>: %{text}",
                "<extra></extra>" # remove extra information
            ),
            text = ~sprintf("[%.2f, %.2f]", ci.lower, ci.upper),
            hoverinfo = "text"
        ) %>%
        add_ribbons(
            ymin = ~ci.lower,
            ymax = ~ci.upper,
            opacity = .5,
            hoverinfo = "none",
            name = translations$ci
        ) %>%
        add_lines(
            y = ~1,
            name = "R = 1",
            opacity = .3,
            hoverinfo = "none",
            line = list(dash = "dash")
        ) %>%
        add_bars(
            y = ~new.cases,
            yaxis = "y2",
            opacity = .1,
            hovertemplate = paste0(
                "<b>", translations$date ,"</b>: %{x}",
                "<br><b>", translations$new_cases, "</b>: %{y:.0f}",
                "<extra></extra>" # remove extra information
            ),
            hoverinfo = "text",
            name = translations$new_cases
        ) %>%
        layout(
            title = translations$title,
            yaxis = list(
                type = "log",
                title = translations$repno,
                tickmode = "array",
                tickvals = 1:10,
                range = log(c(min(c(0.3, estimates$ci.lower), na.rm = TRUE), 10), base = 10),
                gridcolor = "#00000018"
                ),
            colorway = c("black", "grey", "red", "blue"),
            yaxis2 = list(
                overlaying = "y",
                side = "right",
                title = translations$new_cases,
                fixedrange = TRUE,
                gridcolor = "#FFFFFF00"
                ),
            xaxis =  list(
                ticks = "outside",
                tickvals = seq(first_monday, today(), by = "1 week"),
                showline = TRUE,
                showgrid = TRUE,
                type = "date",
                tickformat = "%d/%m",
                title = translations$xaxis,
                gridcolor = "#00000040"
                ),
            legend = list(
                x = 0.2,
                y = -0.23,
                font = list(size = 10),
                bgcolor = "#FFFFFF00",
                orientation = "h",
                itemclick = FALSE,
                itemdoubleclick = FALSE
                ),
            margin = list(r = 60, t = 100),
            shapes = lapply(seq(min(estimates$date), today(), by = "1 day"), function (day) {
                list(
                    type = "line",
                    y0 = 0,
                    y1 = 1,
                    yref = "paper",
                    x0 = day,
                    x1 = day,
                    line = list(color = "#eee", width = 1),
                    layer = "below"
                )
            })

        )
}
