import 'package:flutter/material.dart';

/// Icons available for categories. The key is what's stored in the database,
/// so keys must never be renamed once released.
const Map<String, IconData> categoryIcons = {
  'restaurant': Icons.restaurant_rounded,
  'coffee': Icons.local_cafe_rounded,
  'fuel': Icons.local_gas_station_rounded,
  'parking': Icons.local_parking_rounded,
  'transport': Icons.directions_bus_rounded,
  'motorcycle': Icons.two_wheeler_rounded,
  'car': Icons.directions_car_rounded,
  'groceries': Icons.local_grocery_store_rounded,
  'shopping': Icons.shopping_bag_rounded,
  'entertainment': Icons.movie_rounded,
  'bills': Icons.receipt_long_rounded,
  'health': Icons.favorite_rounded,
  'snack': Icons.icecream_rounded,
  'phone': Icons.smartphone_rounded,
  'internet': Icons.wifi_rounded,
  'electricity': Icons.bolt_rounded,
  'home': Icons.home_rounded,
  'education': Icons.school_rounded,
  'gift': Icons.card_giftcard_rounded,
  'pet': Icons.pets_rounded,
  'sport': Icons.fitness_center_rounded,
  'travel': Icons.flight_rounded,
  'baby': Icons.child_friendly_rounded,
  'charity': Icons.volunteer_activism_rounded,
  'salary': Icons.payments_rounded,
  'allowance': Icons.account_balance_wallet_rounded,
  'freelance': Icons.laptop_mac_rounded,
  'business': Icons.storefront_rounded,
  'investment': Icons.trending_up_rounded,
  'savings': Icons.savings_rounded,
  'bank': Icons.account_balance_rounded,
  'other': Icons.category_rounded,
};

IconData iconForKey(String key) => categoryIcons[key] ?? Icons.category_rounded;

/// Colors offered when creating or editing a category (ARGB values).
const List<int> categoryColors = [
  0xFFF97316, // orange
  0xFF92400E, // brown
  0xFFEF4444, // red
  0xFF3B82F6, // blue
  0xFF06B6D4, // cyan
  0xFF22C55E, // green
  0xFF84CC16, // lime
  0xFFEC4899, // pink
  0xFF8B5CF6, // violet
  0xFFF59E0B, // amber
  0xFF14B8A6, // teal
  0xFF6366F1, // indigo
  0xFF64748B, // slate
  0xFF0EA5E9, // sky
];
