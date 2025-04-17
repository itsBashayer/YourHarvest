# Hasadak


![4D951831-B7B0-4C0A-B4B4-81BB17E20884_1_201_a](https://github.com/user-attachments/assets/5024b538-af92-4f2e-95d0-6071f8143489)



**Hasadak is an intelligent application that uses artificial intelligence techniques for inventory management of vegetables and automatically calculates their quantities. The application relies on **CoreML Object Detector** to analyze images captured using the device's camera, providing accurate results about the vegetable quantity.**

## Project Contents

- **Research and Idea Selection**
- **Data Collection**
- **Training the Model with CoreML**
- **App Development using Swift**
- **Integration with CloudKit**
- **User Experience Design**

## Main Features

- **Vegetable Recognition:** The app uses CoreML Object Detector to recognize vegetables in images.
- **Automatic Counting:** The quantity of vegetables is determined programmatically based on the captured image.
- **Integration with CloudKit:** The app's data is synchronized and stored in CloudKit.
- **Simple and Easy-to-Use Interface:** The app is designed to be user-friendly, suitable for farmers and store owners.

## Technologies Used

- **Swift:** For app development.
- **CoreML Object Detector:** For image analysis and vegetable recognition.
- **CloudKit:** For cloud data storage.
- **Xcode:** The iOS app development environment.

## Usage Instructions

1. **Splash Screen:**  
   When opening the app, a splash screen will appear featuring a logo or short introductory image.

2. **Wedding Pages:**  
   After the splash screen, introductory pages will explain the app’s purpose and how to use it.

3. **Entering Name:**  
   After the introductory pages, the user will be prompted to enter their name, which will be saved for later use in the app.

4. **Camera Page:**  
   After entering the name, the camera page will open, featuring:
   - **Photography Instructions:** Tips on how to take photos properly, including lighting, angle, etc.
   - **Taking a Photo:** Once instructed, the user can capture the vegetable image.

5. **Saving the Photo in History:**  
   Once the photo is taken, it will be saved directly in the History section of the app.

6. **Viewing and Saving Results:**  
   In the History section, users can view all previously captured photos. By selecting any photo, detailed information about the image will be displayed.

7. **Exporting Results to PDF:**  
   By pressing the last captured photo, the user will have the option to export the image and details to a PDF to send it to other apps or print it.
