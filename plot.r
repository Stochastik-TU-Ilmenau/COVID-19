library(plotly)
library(magrittr)
library(lubridate)

mincases <- 30

plot_repronum <- function(estimates, country_name, language, unreliable = 0) {
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
            xaxis = "date of infection / reporting date",
            unreliable = "this data is unreliable, as it may be updated in the future"
        ),
        de = list(
            repno = "Reproduktionszahl",
            est_repno = "geschätzte Reproduktionszahl",
            ci = "95% Konfidenzintervall",
            new_cases = "neu gemeldete Fälle",
            title = "Geschätzte Reproduktionszahl / neu gemeldete Fälle",
            date = "Datum",
            xaxis = "Infektionsdatum / Meldedatum",
            unreliable = "Dieser Datenpunkt ist unzuverlässig"
        )
    )

    n_dates <- nrow(estimates)
    last_estimate <- max(which(!is.na(estimates$repronum)))
    translations <- strings[[language]]

    if (unreliable > 0) {
        unreliable_estimates <- estimates[
            seq(last_estimate - unreliable - 1, n_dates),
            c("date", "repronum", "ci.lower", "ci.upper")
            ]
        unreliable_cases <- estimates[
            seq(n_dates - unreliable, n_dates),
            c("date", "new.cases")
            ]
        estimates[seq(n_dates - unreliable, n_dates), c("new.cases")] <- NA
        estimates[
            seq(last_estimate - unreliable, n_dates),
            c("repronum", "ci.lower", "ci.upper")
            ] <- NA
    }



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
        ) %>% {
            if (unreliable > 0) {
                add_lines(.,
                    data = unreliable_estimates,
                    name = translations$repno,
                    x = ~date,
                    y = ~repronum,
                    hovertemplate = paste0(
                        "<b>", translations$date, "</b>: %{x|%d/%m/%Y}",
                        "<br><b>", translations$est_repno, "</b>: %{y:.2f}",
                        "<br><b>", translations$ci, "</b>: %{text}",
                        "<br><i>", translations$unreliable, "</i>",
                        "<extra></extra>" # remove extra information
                    ),
                    text = ~sprintf("[%.2f, %.2f]", ci.lower, ci.upper),
                    hoverinfo = "text",
                    showlegend = FALSE,
                    opacity = 0.3
                    ) %>%
                add_ribbons(
                    data = unreliable_estimates,
                    x = ~date,
                    ymin = ~ci.lower,
                    ymax = ~ci.upper,
                    opacity = .1,
                    hoverinfo = "none",
                    showlegend = FALSE
                ) %>%
                add_bars(
                    data = unreliable_cases,
                    y = ~new.cases,
                    yaxis = "y2",
                    opacity = .05,
                    hovertemplate = paste0(
                        "<b>", translations$date, "</b>: %{x}",
                        "<br><b>", translations$new_cases, "</b>: %{y:.0f}",
                        "<br><i>", translations$unreliable, "</i>",
                        "<extra></extra>" # remove extra information
                    ),
                    hoverinfo = "text",
                    name = translations$new_cases,
                    showlegend = FALSE
                )
            }
            else {
                .
            }
        } %>%
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
            colorway = c("black", "grey", "red", "blue", "black", "grey", "blue"),
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
                itemdoubleclick = FALSE,
                traceorder = "normal"
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
            }),
            barmode = "stack"
        )
}
