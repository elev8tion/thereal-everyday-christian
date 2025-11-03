import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/reading_plan.dart';
import 'database_service.dart';

/// Service for loading curated thematic reading plans from JSON
class CuratedReadingPlanLoader {
  final DatabaseService _database;
  final _uuid = const Uuid();

  CuratedReadingPlanLoader(this._database);

  /// Load all curated plans from JSON and insert into database
  Future<void> loadCuratedPlans() async {
    try {
      // Load JSON file from assets
      final jsonString = await rootBundle.loadString(
        'assets/reading_plans/curated_thematic_plans.json',
      );
      final List<dynamic> plansJson = json.decode(jsonString);

      // Process each plan
      for (final planData in plansJson) {
        await _insertPlanWithReadings(planData);
      }
    } catch (e) {
      throw Exception('Failed to load curated reading plans: $e');
    }
  }

  /// Insert a single plan and its daily readings
  Future<void> _insertPlanWithReadings(Map<String, dynamic> planData) async {
    final db = await _database.database;

    // Check if plan already exists
    final existing = await db.query(
      'reading_plans',
      where: 'id = ?',
      whereArgs: [planData['id']],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      // Plan already exists, skip insertion
      return;
    }

    // Insert the plan
    await db.insert('reading_plans', {
      'id': planData['id'],
      'title': planData['title'],
      'description': planData['description'],
      'duration': planData['duration'],
      'category': planData['category'],
      'difficulty': planData['difficulty'],
      'estimated_time_per_day': planData['estimatedTimePerDay'],
      'total_readings': planData['totalReadings'],
      'completed_readings': 0,
      'is_started': 0,
      'start_date': null,
    });

    // Insert daily readings
    final List<dynamic> readings = planData['readings'];
    for (final reading in readings) {
      await db.insert('daily_readings', {
        'id': _uuid.v4(),
        'plan_id': planData['id'],
        'title': reading['title'],
        'description': reading['description'],
        'book': reading['book'],
        'chapters': reading['chapters'],
        'estimated_time': reading['estimatedTime'],
        'date': DateTime.now()
            .add(Duration(days: reading['day'] - 1))
            .millisecondsSinceEpoch,
        'is_completed': 0,
        'completed_date': null,
      });
    }
  }

  /// Check if curated plans have been loaded
  Future<bool> areCuratedPlansLoaded() async {
    final db = await _database.database;

    // Check if any of the curated plan IDs exist
    final curatedPlanIds = [
      'plan_30_days_grace',
      'plan_peace_anxiety',
      'plan_advent_journey',
      'plan_identity_christ',
    ];

    for (final planId in curatedPlanIds) {
      final result = await db.query(
        'reading_plans',
        where: 'id = ?',
        whereArgs: [planId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  /// Load curated plans if not already loaded (idempotent)
  Future<void> ensureCuratedPlansLoaded() async {
    final alreadyLoaded = await areCuratedPlansLoaded();
    if (!alreadyLoaded) {
      await loadCuratedPlans();
    }
  }
}
