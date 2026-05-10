import 'package:flutter/material.dart';

/// A central file for legacy design constants.
///
/// These values were used in early versions of the app and are kept for
/// backward compatibility. For any new UI work, prefer [HealthCareColors]
/// from `core/utils/colors.dart` and the values from the active [ThemeData].
///
/// **Why separate from the theme?**
/// Flutter's [ThemeData] is the correct, scalable way to manage design tokens.
/// Constants defined here are plain Dart [const] values, which are faster to
/// access but are not reactive to theme changes (light/dark mode, etc.).

/// The background color used for card surfaces in the legacy dashboard layout.
const cardBackgroundColor = Color(0xFF21222D);

/// The primary accent color for the legacy design.
const primaryColor = Color(0xFF2697FF);

/// The secondary/contrast color, typically used for text on dark backgrounds.
const secondaryColor = Color(0xFFFFFFFF);

/// The primary background color for the app canvas in the legacy design.
const backgroundColor = Color(0xFF15131C);

/// A soft teal/green color used to highlight selected or active items.
const selectionColor = Color(0xFF88B2AC);

/// The standard spacing unit used for padding and margins throughout the app.
///
/// By using a single constant, all screens share consistent breathing room
/// and any global spacing change requires only one edit here.
const defaultPadding = 20.0;

/// The standard duration for most transitions and micro-animations.
///
/// A 250ms duration sits in the sweet spot — fast enough to feel snappy,
/// slow enough to be perceivable and polished.
const defaultDuration = Duration(milliseconds: 250);

/// The standard corner radius for cards, buttons, and containers.
///
/// Using a consistent border radius keeps the UI cohesive. 12px is a
/// modern, friendly radius that suits both cards and input fields.
const defaultBorderRadius = 12.0;