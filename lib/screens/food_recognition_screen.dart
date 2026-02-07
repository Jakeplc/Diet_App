import 'package:flutter/material.dart';
import '../models/food_recognition.dart';
import '../services/food_recognition_service.dart';

class FoodRecognitionScreen extends StatefulWidget {
  final Function(RecognizedFood, int) onFoodSelected;

  const FoodRecognitionScreen({super.key, required this.onFoodSelected});

  @override
  State<FoodRecognitionScreen> createState() => _FoodRecognitionScreenState();
}

class _FoodRecognitionScreenState extends State<FoodRecognitionScreen> {
  RecognitionResult? _recognitionResult;
  bool _isProcessing = false;
  int _selectedServingSize = 100;
  RecognizedFood? _selectedFood;

  Future<void> _simulatePhotoCapture() async {
    setState(() => _isProcessing = true);

    try {
      // Simulate taking a photo
      final result = await FoodRecognitionService.recognizeFood(
        'simulated_photo.jpg',
      );

      setState(() {
        _recognitionResult = result;
        _selectedFood = result.suggestions.first;
        _selectedServingSize = _selectedFood!.servingSizeGrams;
        _isProcessing = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Recognition failed: $e')));
      setState(() => _isProcessing = false);
    }
  }

  void _selectFood(RecognizedFood food) {
    setState(() {
      _selectedFood = food;
      _selectedServingSize = food.servingSizeGrams;
    });
  }

  void _confirmFood() {
    if (_selectedFood != null) {
      widget.onFoodSelected(_selectedFood!, _selectedServingSize);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_recognitionResult == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Food Recognition'), elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 60,
                  color: Colors.blue[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Snap & Recognize',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Take a photo of your food to identify it instantly',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _simulatePhotoCapture,
                icon: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.camera),
                label: Text(_isProcessing ? 'Recognizing...' : 'Take Photo'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber[700], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Works best with clear, well-lit photos of single food items',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Recognition Results'), elevation: 0),
      body: Column(
        children: [
          // Processing info
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.green[50],
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recognition Complete',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      Text(
                        'Processing took ${_recognitionResult!.processingTime.toStringAsFixed(0)}ms',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Suggestions
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _recognitionResult!.suggestions.length,
              itemBuilder: (context, index) {
                final food = _recognitionResult!.suggestions[index];
                final isSelected = _selectedFood?.id == food.id;

                return GestureDetector(
                  onTap: () => _selectFood(food),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        width: isSelected ? 2 : 0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      food.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      food.foodType,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getConfidenceColor(food.confidence),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${(food.confidence * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildNutrientInfo(
                                  '🔥',
                                  '${food.caloriesPer100g}',
                                ),
                              ),
                              Expanded(
                                child: _buildNutrientInfo(
                                  '💪',
                                  '${food.protein}g',
                                ),
                              ),
                              Expanded(
                                child: _buildNutrientInfo(
                                  '🌾',
                                  '${food.carbs}g',
                                ),
                              ),
                              Expanded(
                                child: _buildNutrientInfo(
                                  '🥑',
                                  '${food.fats}g',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'per 100g',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            Text(
                              'Serving Size',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text('${_selectedServingSize}g'),
                                      ),
                                      Text(
                                        food.servingSize,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Slider(
                                    value: _selectedServingSize.toDouble(),
                                    min: 25,
                                    max: 500,
                                    divisions: 19,
                                    onChanged: (value) {
                                      setState(
                                        () => _selectedServingSize = value
                                            .toInt(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Nutrition for selected serving
                            _buildSelectedNutrition(),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Confirm button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedFood != null ? _confirmFood : null,
                icon: const Icon(Icons.check),
                label: const Text('Add to Meal'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientInfo(String emoji, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSelectedNutrition() {
    if (_selectedFood == null) return const SizedBox.shrink();

    final nutrition = FoodRecognitionService.calculateNutrition(
      _selectedFood!,
      _selectedServingSize,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '${nutrition['calories']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('cal', style: TextStyle(fontSize: 10)),
            ],
          ),
          Column(
            children: [
              Text(
                '${nutrition['protein']}g',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('protein', style: TextStyle(fontSize: 10)),
            ],
          ),
          Column(
            children: [
              Text(
                '${nutrition['carbs']}g',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('carbs', style: TextStyle(fontSize: 10)),
            ],
          ),
          Column(
            children: [
              Text(
                '${nutrition['fats']}g',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('fats', style: TextStyle(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.90) return Colors.green;
    if (confidence >= 0.80) return Colors.blue;
    if (confidence >= 0.70) return Colors.amber;
    return Colors.red;
  }
}
