# packages
# If you did not downloaded packages, run the code below
# install.packages("sf", "dplyr", "readr", "geodata", "ggplot2")
library(sf)
library(dplyr)
library(readr)
library(geodata)
library(ggplot2)


# Download South Korean map from GADM
subwaymap <- geodata::gadm(country="KOR", level=2, path=tempdir())
subwaymap <- sf::st_as_sf(subwaymap)  # sf로 변환됨 (보통 EPSG:4326)

# check coordinate system
st_crs(subwaymap) 

# 2) read subway station from csv file

subway <- read_csv("input/station.csv", show_col_types = FALSE)

# Assign point by latitude and longitude, using CRS same as GADM
subway_sf <- st_as_sf(subway, coords = c("long","lat"), crs = st_crs(subwaymap))

# 3) Creating linstring

if(all(c("line","station_id") %in% names(subway_sf))) {
  subway_sf <- subway_sf |> arrange(line, station_id)
}

# creating MULTIPOINT
subway_lines <- subway_sf |>
  group_by(line) |>
  summarise(geometry = st_combine(geometry), .groups = "drop") |>
  st_cast("LINESTRING")

# highlight jurisdiction 
gimpo_highlight    <- subset(subwaymap, NAME_2 == "Gimpo")
Seoul_highlight    <- subset(subwaymap, NAME_1 == "Seoul")
incheon_highlight  <- subset(subwaymap, NAME_1 == "Incheon")
gyeonggi_highlight <- subset(subwaymap, NAME_1 == "Gyeonggi-do" & NAME_2 != "Gimpo")

# label points
manual_labels <- data.frame(
  name = c("Gimpo","Seoul","Incheon","Gyeonggi-do", "Gyeonggi-do"),
  lon  = c(126.6,   126.9,  126.70,    126.85,    126.8 ),
  lat  = c( 37.7,    37.57,  37.53,     37.69,    37.40)
)
manual_labels_sf <- st_as_sf(manual_labels, coords = c("lon","lat"), crs = 4326) |>
  st_transform(st_crs(subwaymap))

# trnasliate line names into English
recode_map <- c(
  "5호선" = "Line 5",
  "9호선" = "Line 9",
  "김포골드라인" = "Gimpo Gold Line",
  "공항철도1호선" = "AREX",
  "서해선" = "Seohae Line"
)
if("line" %in% names(subway_sf))   subway_sf$line   <- dplyr::recode(subway_sf$line, !!!recode_map)
if("line" %in% names(subway_lines))subway_lines$line<- dplyr::recode(subway_lines$line, !!!recode_map)
# line type
line_ltys <- c(
  "Gimpo Gold Line" = "solid",
  "AREX"            = "longdash",
  "Line 5"          = "dotdash",
  "Line 9"          = "dotted",
  "Seohae Line"     = "twodash"
)

#  station shape
# 16=●, 15=■, 17=▲, 18=◆, 3=+
station_shapes <- c(
  "Gimpo Gold Line" = 16,
  "AREX"            = 15,
  "Line 5"          = 17,
  "Line 9"          = 18,
  "Seohae Line"     = 3
)


figure1 <- ggplot() +
  geom_sf(data = subwaymap,         fill = "grey95", color = "white") +
  geom_sf(data = gimpo_highlight,   fill = "grey80", color = "grey35", size = 0.7) +
  geom_sf(data = Seoul_highlight,   fill = "grey88", color = "grey45", size = 0.7) +
  geom_sf(data = incheon_highlight, fill = "grey90", color = "grey45", size = 0.7) +
  geom_sf(data = gyeonggi_highlight,fill = "grey92", color = "grey45", size = 0.7) +
  geom_sf(data = subway_lines, color = "white", size = 2.8, lineend = "round") +
  geom_sf(data = subway_lines, aes(linetype = line), color = "black", size = 1.2, lineend = "round") +
  geom_sf(data = subway_sf, aes(shape = line), size = 2.3, color = "black", stroke = 0.8) +
  geom_sf_label(data = manual_labels_sf, aes(label = name),
                size = 3.8, fontface = "bold", color = "black",
                fill = "white", label.size = 0.2, alpha = 0.9) +
  coord_sf(xlim = c(126.5, 127), ylim = c(37.3, 37.8), expand = FALSE) +
  scale_linetype_manual(values = line_ltys, guide = guide_legend(order = 1,
                                                                 override.aes = list(color = "black", size = 1.6))) +
  scale_shape_manual(values = station_shapes, guide = guide_legend(order = 2,
                                                                   override.aes = list(color = "black", size = 3))) +
  labs(linetype = "Lines", shape = "Stations") +
  theme_minimal(base_size = 12) +
  theme(axis.title = element_blank(),
        axis.text  = element_blank(),
        axis.ticks = element_blank(),
        legend.title = element_text(face = "bold"))
figure1
