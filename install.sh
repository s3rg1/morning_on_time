#!/bin/bash

# Morning On Time - Quick Install Script
# This script will build and install the app on your connected Android device

set -e  # Exit on error

echo "🌅 Morning On Time - Quick Install"
echo "=================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter from https://flutter.dev"
    exit 1
fi

echo "✓ Flutter found: $(flutter --version | head -1)"
echo ""

# Check if device is connected
echo "Checking for connected devices..."
DEVICES=$(flutter devices 2>&1)

if echo "$DEVICES" | grep -q "No devices detected"; then
    echo "❌ No devices connected"
    echo ""
    echo "Please connect your Android device via USB and:"
    echo "1. Enable Developer Options (tap Build Number 7 times)"
    echo "2. Enable USB Debugging in Developer Options"
    echo "3. Accept the USB debugging prompt on your device"
    exit 1
fi

echo "✓ Device(s) found"
echo ""

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build and install
echo ""
echo "🔨 Building and installing app..."
echo "This may take a few minutes..."
echo ""

flutter run --release

echo ""
echo "✅ Installation complete!"
echo ""
echo "📱 Next steps:"
echo "1. Open the Never Late app on your device"
echo "2. Grant notification permissions when prompted"
echo "3. Set your morning schedule (wake-up, leave, arrival times)"
echo "4. Optional: Add rewards in the Rewards section"
echo "5. Go to Settings > Apps > Never Late > Battery > Set to 'Unrestricted'"
echo ""
echo "🎯 The app will automatically activate tomorrow morning!"
echo "Good luck arriving on time! 🎉"
