// lib/app/theme/colors.dart
import 'package:flutter/material.dart';

/// Color palette for the application based on the PRD requirements.
class AppColors {
  // Base background colors
  static const Color appBackground = Color(0xFF1A1A1A); // "really dark gray" per PRD
  static const Color moduleBackground = Color(0xFF252525); // "slightly darker gray" per PRD
  
  // Session card colors
  static const Color sessionCardBackground = Color(0xFF1A1A1A);
  static const Color sessionCardBorder = Color(0xFF3A3A3A);
  static const Color personalSessionContainer = Color(0xFF1C1C1C);
  static const Color personalSessionCardBackground = Color(0xFF252525);
  
  // Text colors
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFAAAAAA);
  
  // Status colors
  static const Color active = Color(0xFFE53935); // Accent color for active state
  static const Color activeText = Color(0xFFFFFFFF);
  static const Color break_ = Color(0xFF777777); // Dimmed color for break state
  static const Color breakText = Color(0xFFDDDDDD);
  static const Color idle = Color(0xFF444444); // Even more dimmed for idle
  static const Color idleText = Color(0xFF999999);
  
  // Custom button states
  static const Color inactive = Color(0xFF444444); // For disabled buttons
  static const Color inactiveText = Color(0xFF777777); // Text color for disabled buttons
  
  // Border thickness level colors (can be the same but with different opacity)
  static const Color borderLevel1 = Color(0xFF3A3A3A); // 5 minutes
  static const Color borderLevel8 = Color(0xFFE53935); // 300 minutes (5 hours)
  
  // Feedback colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
  
  // Connection status
  static const Color connected = Color(0xFF4CAF50);
  static const Color connecting = Color(0xFFFFC107);
  static const Color disconnected = Color(0xFFE53935);
  
  // Input field colors
  static const Color inputBackground = Color(0xFF2A2A2A);
  static const Color disabledBackground = Color(0xFF222222); // Background for disabled fields
  static const Color inputBorder = Color(0xFF3A3A3A);
  static const Color inputFocusBorder = Color(0xFFE53935);
  static const Color placeholder = Color(0xFF777777);
}

/// Username color options for customization
class UsernameColors {
  // Default white color (same as primaryText)
  static const Color white = Color(0xFFE9EDF2);
  
  // Additional color options
  static const Color blue = Color(0xFF3E95FF);
  static const Color green = Color(0xFF26D07C);
  static const Color purple = Color(0xFFB264F8);
  static const Color orange = Color(0xFF8C38FF);
  static const Color yellow = Color(0xFFFFD02F);
  static const Color pink = Color(0xFFFF6B9E);
  
  // Current selected color (default is white)
  static Color currentColor = white;
  
  // Get all available colors as a map
  static Map<String, Color> getAllColors() {
    return {
      'white': white,
      'blue': blue,
      'green': green, 
      'purple': purple,
      'orange': orange,
      'yellow': yellow,
      'pink': pink,
    };
  }
  
  // Set the current color
  static void setColor(Color color) {
    currentColor = color;
  }
}