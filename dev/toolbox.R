plot_ts_covid <- function(data,
                          xcol,
                          ycol,
                          title = "",
                          col = NULL,
                          time_since = "2019-11-01",
                          time_until = "empty",
                          time_intercept = "2020-03-11",
                          intercept_color = "red",
                          lp = "none",
                          label_height = 0,
                          label_text = "",
                          label_hjust = 0,
                          label_vjust = 0,
                          label_size = 11,
                          date_breaks = "3 month",
                          date_labels = "%m-%y",
                          geom = geom_line) {
  time_var <- c(xcol)
  
  if (time_until != "empty") {
    data_plot <-
      data %>% filter((get(time_var) > ymd(time_since)) &
                        (get(time_var) <= ymd(time_until)))
  }
  
  else{
    data_plot <- data %>% filter((get(time_var) > ymd(time_since)))
  }
  
  plot <-
    data_plot %>% ggplot2::ggplot(ggplot2::aes_string(
      x = xcol,
      y = ycol,
      col = col,
      group = col
    )) + geom() + ggplot2::geom_vline(
      xintercept = ymd(time_intercept),
      color = intercept_color,
      lty = "dashed"
    ) + geom_text(
      aes(
        x = ymd(time_intercept),
        label = label_text,
        y = label_height
      ),
      colour = "red",
      nudge_x = label_hjust,
      nudge_y = label_vjust,
      size = label_size
    )  + scale_x_date(
      date_breaks = date_breaks,
      date_labels = date_labels,
      date_minor_breaks = "1 month"
    ) + ggplot2::theme_bw() + ggplot2::ggtitle(title) + ggplot2::theme(
      legend.position = lp
    ) + scale_color_brewer(palette = "Set1")
  return(plot)
}

plot_libor_mat <- function(ggplot_obj) {
  plot <-
    ggplot_obj + geom_path() + 
    scale_color_date(low = "purple", high = "lightgreen", guide = guide_colorbar(ticks = FALSE, label.position = "bottom", barwidth = 20)) + 
    ggplot2::theme_bw() + 
    ggplot2::theme(legend.position = "bottom")
  return(plot)
}


label_value_axis <- function(name, unit) {
  return(stringr::str_c(name, " ", "(", unit, ")"))
}
