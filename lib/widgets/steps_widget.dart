import 'package:flutter/material.dart';

class StepsWidget extends StatelessWidget {
  final List<String> steps;

  const StepsWidget({Key? key, required this.steps}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Step-by-Step Solution',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 200,
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  final isHeader =
                      step.contains('Algorithm') || step.contains('Results:');
                  final isSubHeader =
                      step.contains('sorted') || step.contains('Time');

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      step,
                      style: TextStyle(
                        fontSize: isHeader ? 18 : (isSubHeader ? 14 : 13),
                        fontWeight: isHeader
                            ? FontWeight.bold
                            : (isSubHeader
                                  ? FontWeight.w600
                                  : FontWeight.normal),
                        color: isHeader ? Theme.of(context).primaryColor : null,
                        fontFamily: step.contains(':') && !isHeader
                            ? 'Courier'
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
