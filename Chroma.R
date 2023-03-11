# load data in 'global' chunk so it can be shared by all users of the dashboard
library(tidyverse)
library(spotifyr) 
library(ggplot2)
library(hrbrthemes)
library(compmus)


playlist <- get_playlist_audio_features('', '5qpd9dnhtOojDgdA29BhfO') 
playlist$release <- as.Date(playlist$track.album.release_date, format = "%Y-%m-%d")


wood <-
  get_tidy_audio_analysis("5qpd9dnhtOojDgdA29BhfO") |>
  compmus_align(bars, segments) |>                     # Change `bars`
  select(bars) |>                                      #   in all three
  unnest(bars) |>                                      #   of these lines.
  mutate(
    pitches =
      map(segments,
          compmus_summarise, pitches,
          method = "rms", norm = "euclidean"              # Change summary & norm.
      )
  ) |>
  mutate(
    timbre =
      map(segments,
          compmus_summarise, timbre,
          method = "rms", norm = "euclidean"              # Change summary & norm.
      )
  )


wood |>
  mutate(pitches = map(pitches, compmus_normalise, "euclidean")) |>
  compmus_gather_chroma() |> 
  ggplot(
    aes(
      x = start + duration / 2,
      width = duration,
      y = pitch_class,
      fill = value
    )
  ) +
  geom_tile() +
  labs(x = "Time (s)", y = NULL, fill = "Magnitude") +
  theme(aspect.ratio=9/16, legend.position="bottom") +
  scale_fill_viridis_c()