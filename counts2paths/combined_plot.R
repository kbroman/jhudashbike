plot_paths(paths=streets[acc_counts > 4], opacity=0.3, weight=4, group="accidents") %>%
    plot_paths(paths=streets[haz_counts > 15], opacity=0.3, col="slateblue", weight=4, group="hazards") %>%
    plot_paths(paths=streets[varr_counts > 15], opacity=0.3, col="green", weight=4, group="arrests") %>%
    addLayersControl(overlayGroups=c("accidents", "arrests", "hazards"),
                     options=layersControlOptions(collapsed=FALSE))
