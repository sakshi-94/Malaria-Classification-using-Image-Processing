# Malaria Classification Using Image Processing Techniques

![Malaria Detection Banner](https://via.placeholder.com/800x200?text=Automated+Malaria+Cell+Classification)

## 📌 Overview
This project develops an automated system to classify malaria-infected red blood cells (RBCs) in microscopic blood smear images using MATLAB and OpenCV. It detects and categorizes infection severity (Low/Medium/High Parasitaemia) through advanced image processing techniques like edge detection, morphological operations, and feature extraction.

## 🎯 Key Features
- **Automated Detection**: Identifies malaria-infected RBCs with 90%+ accuracy
- **Severity Classification**: Categorizes cells as:
  - LP (Low Parasitaemia)
  - MP (Medium Parasitaemia) 
  - HP (High Parasitaemia)
- **Quantitative Analysis**: Measures cellular features (area, perimeter, eccentricity)
- **SDG-3 Alignment**: Supports global health goals by enabling rapid diagnosis in resource-limited settings

## 🛠️ Technical Stack
| Component          | Tools/Techniques                          |
|--------------------|-------------------------------------------|
| Image Preprocessing| Median Filtering, Grayscale Conversion    |
| Edge Detection     | Canny Edge Algorithm                      |
| Feature Extraction | Area, Perimeter, Form Factor, Circularity |
| Classification     | Threshold-based (MATLAB/OpenCV)           |
| Hardware           | Digital Microscope (Olympus BX 63)        |

## 📂 Project Structure
Malaria_Classification/
├── Dataset/ # Blood smear images (Normal/LP/MP/HP)
├── Code/
│ ├── Preprocessing.m # Image normalization & noise reduction
│ ├── Segmentation.m # Cell isolation algorithms
│ ├── Feature_Extraction.m # Measures cellular parameters
│ └── Classification.m # Infection severity classifier
├── Results/ # Output images with labeled cells
├── Docs/ # Project report & references
└── README.md # This file
