# ENRD Database

[![ArcGIS](https://img.shields.io/badge/ArcGIS-File%20Geodatabase-2C7A3D?logo=esri)](https://www.esri.com)

An **ArcGIS File Geodatabase** for the **Environment and Natural Resources Division (ENRD)** of the Province of **Agusan del Norte**, Philippines.

Contains geospatial data for provincial environmental and natural resources planning, including administrative boundaries, land classification, watersheds, mining claims, infrastructure, and survey controls.

---

## Feature Classes

### Administrative Boundaries
| Layer | Description |
|-------|-------------|
| `Adn_Province` | Agusan del Norte provincial boundary |
| `Adn_Province_DENR` | DENR-recognized provincial boundary |
| `Philippines` | National boundary reference |
| `Mindanao` | Regional boundary reference |

### Municipalities
Buenavista, Cabadbaran City, Carmen, Jabonga, Kitcharao, Las Nieves, Magallanes, Nasipit, Santiago, Tubay

### Land & Environment
| Layer | Description |
|-------|-------------|
| `Land_Classification` | Land classification data |
| `Protected_Area` | Protected areas (NIPAS) |
| `Protected_Area_PWWSCZM` | PWWSCZM protected areas |
| `Watershed_Delineation` | Watershed boundaries |
| `Soil_Map` | Soil type mapping |

### Mining & Geology
| Layer | Description |
|-------|-------------|
| `MGB_Area_Status` | MGB mining area status |
| `MPSA_2018` | Mineral Production Sharing Agreement |
| `Armoring` | Armoring/erosion control |

### Infrastructure
| Layer | Description |
|-------|-------------|
| `Road_Network` | Road network |
| `River_Creeks` | River and creek network |
| `Contour_10m` | 10-meter contour lines |
| `Infrastructure_1km` | 1km infrastructure buffer |

### Survey Controls
| Layer | Description |
|-------|-------------|
| `Control` | Survey control points |
| `Locators` | Survey locator points |
| `Post_recovered` | Recovered monuments |

### Cadastral
| Layer | Description |
|-------|-------------|
| `Parcel` | Land parcels |
| `Plot` | Plot boundaries |
| `CADT` | CADT/CADC areas |

---

## Related Projects

- [GeoForge](https://github.com/JunweakDGreit/GeoForge) — QGIS plugin for HEC-HMS hydrological modeling (uses ENRD watershed data)
